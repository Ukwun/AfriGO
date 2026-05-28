import { Injectable, BadRequestException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThan, LessThan } from 'typeorm';
import { Shipment, ShipmentStatus } from './shipment.entity';
import { ShipmentTracking, TrackingEventType } from './shipment-tracking.entity';
import { DeliveryProof } from './delivery-proof.entity';
import { Contract } from '../contracts/contract.entity';
import { User } from '../users/user.entity';
import {
  CreateShipmentDTO,
  AssignDriverDTO,
  UpdateShipmentStatusDTO,
  AddTrackingEventDTO,
  CaptureDeliveryProofDTO,
  RescheduleDeliveryDTO,
  ShipmentResponseDTO,
  ShipmentListResponseDTO,
  ShipmentDetailsResponseDTO,
  ShipmentSummaryDTO,
} from './shipment.dto';

@Injectable()
export class ShipmentsService {
  constructor(
    @InjectRepository(Shipment)
    private shipmentRepo: Repository<Shipment>,
    @InjectRepository(ShipmentTracking)
    private trackingRepo: Repository<ShipmentTracking>,
    @InjectRepository(DeliveryProof)
    private proofRepo: Repository<DeliveryProof>,
    @InjectRepository(Contract)
    private contractRepo: Repository<Contract>,
    @InjectRepository(User)
    private userRepo: Repository<User>,
  ) {}

  /**
   * Create shipment from contract
   * Generates reference: SHP-YYYY-XXXXXX
   * Creates initial PENDING status tracking event
   */
  async createShipment(dto: CreateShipmentDTO, userId: string): Promise<ShipmentResponseDTO> {
    const contract = await this.contractRepo.findOne({
      where: { id: dto.contractId },
      relations: ['buyer', 'seller'],
    });

    if (!contract) {
      throw new NotFoundException(`Contract ${dto.contractId} not found`);
    }

    // Only contract parties or admin can create shipment
    if (contract.buyerId !== userId && contract.sellerId !== userId) {
      throw new ForbiddenException('Only contract parties can create shipments');
    }

    // Verify contract is active or signed
    if (contract.status !== 'SIGNED' && contract.status !== 'ACTIVE') {
      throw new BadRequestException('Contract must be signed or active to create shipment');
    }

    // Generate shipment reference: SHP-2026-001001 (SHP-YYYY-XXXXXX)
    const year = new Date().getFullYear();
    const count = await this.shipmentRepo.count();
    const shipmentReference = `SHP-${year}-${String(count + 1).padStart(6, '0')}`;

    // Create shipment
    const shipment = this.shipmentRepo.create({
      ...dto,
      shipmentReference,
      status: ShipmentStatus.PENDING,
      contractId: dto.contractId,
      pickupDate: new Date(dto.pickupDate),
      expectedDeliveryDate: new Date(dto.expectedDeliveryDate),
    });

    const saved = await this.shipmentRepo.save(shipment);

    // Create initial tracking event
    await this.trackingRepo.save(
      this.trackingRepo.create({
        shipmentId: saved.id,
        eventType: TrackingEventType.CREATED,
        message: `Shipment ${shipmentReference} created`,
        latitude: dto.pickupLatitude,
        longitude: dto.pickupLongitude,
        locationName: dto.pickupLocationName,
      }),
    );

    return this.formatShipmentResponse(saved);
  }

  /**
   * Assign driver to shipment
   * Updates driver, vehicle info
   * Creates ASSIGNED_DRIVER tracking event
   */
  async assignDriver(shipmentId: string, dto: AssignDriverDTO, userId: string): Promise<ShipmentResponseDTO> {
    const shipment = await this.shipmentRepo.findOne({ where: { id: shipmentId } });

    if (!shipment) {
      throw new NotFoundException(`Shipment ${shipmentId} not found`);
    }

    const driver = await this.userRepo.findOne({ where: { id: dto.driverId } });
    if (!driver) {
      throw new NotFoundException(`Driver ${dto.driverId} not found`);
    }

    // Update shipment
    shipment.driverId = dto.driverId;
    shipment.driver = driver;
    if (dto.vehicleRegistration) shipment.vehicleRegistration = dto.vehicleRegistration;
    if (dto.vehicleType) shipment.vehicleType = dto.vehicleType;
    if (dto.driverLicenseNumber) shipment.driverLicenseNumber = dto.driverLicenseNumber;

    const updated = await this.shipmentRepo.save(shipment);

    // Create tracking event
    await this.trackingRepo.save(
      this.trackingRepo.create({
        shipmentId,
        eventType: TrackingEventType.ASSIGNED_DRIVER,
        message: `Driver ${driver.name} assigned to shipment`,
      }),
    );

    return this.formatShipmentResponse(updated);
  }

  /**
   * Update shipment status
   * Validates status transitions
   * Creates appropriate tracking event
   */
  async updateStatus(shipmentId: string, dto: UpdateShipmentStatusDTO, userId: string): Promise<ShipmentResponseDTO> {
    const shipment = await this.shipmentRepo.findOne({ where: { id: shipmentId } });

    if (!shipment) {
      throw new NotFoundException(`Shipment ${shipmentId} not found`);
    }

    // Validate status transition
    this.validateStatusTransition(shipment.status, dto.status);

    const previousStatus = shipment.status;
    shipment.status = dto.status;

    // Update dates based on status
    if (dto.status === ShipmentStatus.IN_TRANSIT && !shipment.departureTime) {
      shipment.departureTime = new Date();
    }

    if (dto.status === ShipmentStatus.ARRIVED_DESTINATION && !shipment.arrivedDestinationTime) {
      shipment.arrivedDestinationTime = new Date();
    }

    if (dto.status === ShipmentStatus.DELIVERED) {
      shipment.actualDeliveryDate = new Date();
    }

    if (dto.status === ShipmentStatus.FAILED_DELIVERY) {
      shipment.deliveryFailureReason = dto.deliveryFailureReason;
      shipment.deliveryAttemptCount = (shipment.deliveryAttemptCount || 0) + 1;
      // Can retry up to 3 times
      if (shipment.deliveryAttemptCount >= 3) {
        throw new BadRequestException('Maximum delivery attempts reached');
      }
    }

    const updated = await this.shipmentRepo.save(shipment);

    // Create tracking event
    const eventTypeMap = {
      [ShipmentStatus.SCHEDULED]: TrackingEventType.CREATED,
      [ShipmentStatus.IN_TRANSIT]: TrackingEventType.DEPARTED_PICKUP,
      [ShipmentStatus.ARRIVED_DESTINATION]: TrackingEventType.ARRIVED_DESTINATION,
      [ShipmentStatus.DELIVERED]: TrackingEventType.DELIVERED,
      [ShipmentStatus.FAILED_DELIVERY]: TrackingEventType.DELIVERY_FAILED,
      [ShipmentStatus.CANCELLED]: TrackingEventType.CANCELLED,
    };

    await this.trackingRepo.save(
      this.trackingRepo.create({
        shipmentId,
        eventType: eventTypeMap[dto.status] || TrackingEventType.EXCEPTION,
        message: dto.notes || `Status changed from ${previousStatus} to ${dto.status}`,
      }),
    );

    return this.formatShipmentResponse(updated);
  }

  /**
   * Add real-time tracking event with GPS location
   * Used by driver app to send location updates
   */
  async addTrackingEvent(shipmentId: string, dto: AddTrackingEventDTO, userId: string): Promise<any> {
    const shipment = await this.shipmentRepo.findOne({ where: { id: shipmentId } });

    if (!shipment) {
      throw new NotFoundException(`Shipment ${shipmentId} not found`);
    }

    const event = this.trackingRepo.create({
      shipmentId,
      eventType: dto.eventType,
      message: dto.message,
      latitude: dto.latitude,
      longitude: dto.longitude,
      locationName: dto.locationName,
      metadata: dto.metadata,
      notes: dto.notes,
      eventTime: new Date(),
    });

    const saved = await this.trackingRepo.save(event);

    // If near delivery, update shipment status
    if (dto.eventType === TrackingEventType.NEAR_DELIVERY && shipment.status === ShipmentStatus.IN_TRANSIT) {
      await this.updateStatus(
        shipmentId,
        {
          status: ShipmentStatus.ARRIVED_DESTINATION,
          notes: 'Driver near delivery location',
        },
        userId,
      );
    }

    return {
      id: saved.id,
      eventType: saved.eventType,
      message: saved.message,
      latitude: saved.latitude,
      longitude: saved.longitude,
      createdAt: saved.createdAt,
    };
  }

  /**
   * Capture delivery proof (signature, photo, ID)
   * Creates DeliveryProof record
   */
  async captureDeliveryProof(shipmentId: string, dto: CaptureDeliveryProofDTO, userId: string): Promise<any> {
    const shipment = await this.shipmentRepo.findOne({ where: { id: shipmentId } });

    if (!shipment) {
      throw new NotFoundException(`Shipment ${shipmentId} not found`);
    }

    const user = await this.userRepo.findOne({ where: { id: userId } });

    const proof = this.proofRepo.create({
      shipmentId,
      proofType: dto.proofType,
      description: dto.description,
      dataBlobUrl: dto.dataBlobUrl,
      signatureCanvas: dto.signatureCanvas,
      recipientName: dto.recipientName,
      recipientIdType: dto.recipientIdType,
      recipientIdNumber: dto.recipientIdNumber,
      recipientPhone: dto.recipientPhone,
      conditionAssessment: dto.conditionAssessment,
      latitude: dto.latitude,
      longitude: dto.longitude,
      notes: dto.notes,
      capturedById: userId,
      capturedBy: user,
      isVerified: false,
    });

    const saved = await this.proofRepo.save(proof);

    // If signature captured, create tracking event
    if (dto.proofType === 'SIGNATURE') {
      await this.trackingRepo.save(
        this.trackingRepo.create({
          shipmentId,
          eventType: TrackingEventType.DELIVERED,
          message: `Signature received from ${dto.recipientName}`,
          latitude: dto.latitude,
          longitude: dto.longitude,
        }),
      );

      // Auto-mark as delivered if signature captured
      if (shipment.status === ShipmentStatus.ARRIVED_DESTINATION) {
        shipment.status = ShipmentStatus.DELIVERED;
        shipment.actualDeliveryDate = new Date();
        await this.shipmentRepo.save(shipment);
      }
    }

    return {
      id: saved.id,
      proofType: saved.proofType,
      description: saved.description,
      recipientName: saved.recipientName,
      isVerified: saved.isVerified,
      createdAt: saved.createdAt,
    };
  }

  /**
   * Reschedule delivery
   * Updates expectedDeliveryDate
   * Creates RESCHEDULED tracking event
   */
  async rescheduleDelivery(shipmentId: string, dto: RescheduleDeliveryDTO, userId: string): Promise<ShipmentResponseDTO> {
    const shipment = await this.shipmentRepo.findOne({ where: { id: shipmentId } });

    if (!shipment) {
      throw new NotFoundException(`Shipment ${shipmentId} not found`);
    }

    const newDate = new Date(dto.newDeliveryDate);
    if (newDate <= new Date()) {
      throw new BadRequestException('New delivery date must be in the future');
    }

    shipment.expectedDeliveryDate = newDate;
    const updated = await this.shipmentRepo.save(shipment);

    // Create tracking event
    await this.trackingRepo.save(
      this.trackingRepo.create({
        shipmentId,
        eventType: TrackingEventType.RESCHEDULED,
        message: `Delivery rescheduled to ${newDate.toISOString()}. Reason: ${dto.reason}`,
        notes: dto.notes,
      }),
    );

    return this.formatShipmentResponse(updated);
  }

  /**
   * Get single shipment with full details
   */
  async getShipmentById(shipmentId: string): Promise<ShipmentDetailsResponseDTO> {
    const shipment = await this.shipmentRepo.findOne({
      where: { id: shipmentId },
      relations: ['contract', 'contract.buyer', 'contract.seller', 'trackingHistory', 'deliveryProofs', 'driver'],
    });

    if (!shipment) {
      throw new NotFoundException(`Shipment ${shipmentId} not found`);
    }

    return {
      id: shipment.id,
      shipmentReference: shipment.shipmentReference,
      status: shipment.status,
      transportMode: shipment.transportMode,
      pickupLocationName: shipment.pickupLocationName,
      deliveryLocationName: shipment.deliveryLocationName,
      pickupDate: shipment.pickupDate,
      expectedDeliveryDate: shipment.expectedDeliveryDate,
      actualDeliveryDate: shipment.actualDeliveryDate,
      daysInTransit: shipment.getDaysInTransit(),
      isDelayed: shipment.isDelayed(),
      driver: shipment.driver
        ? {
            id: shipment.driver.id,
            name: shipment.driver.name,
            phone: shipment.driver.phone,
          }
        : null,
      vehicleRegistration: shipment.vehicleRegistration,
      trackingUrl: shipment.trackingUrl,
      deliveryProofCount: shipment.deliveryProofs?.length || 0,
      contract: {
        id: shipment.contract.id,
        totalValue: Number(shipment.contract.totalValue),
        currency: shipment.contract.currency,
        buyer: { id: shipment.contract.buyer.id, name: shipment.contract.buyer.name },
        seller: { id: shipment.contract.seller.id, name: shipment.contract.seller.name },
      },
      trackingHistory: (shipment.trackingHistory || []).map((t) => ({
        id: t.id,
        eventType: t.eventType,
        message: t.message,
        latitude: t.latitude,
        longitude: t.longitude,
        locationName: t.locationName,
        metadata: t.metadata,
        createdAt: t.createdAt,
      })),
      deliveryProofs: (shipment.deliveryProofs || []).map((p) => ({
        id: p.id,
        proofType: p.proofType,
        description: p.description,
        dataBlobUrl: p.dataBlobUrl,
        recipientName: p.recipientName,
        recipientIdNumber: p.recipientIdNumber,
        conditionAssessment: p.conditionAssessment,
        latitude: p.latitude,
        longitude: p.longitude,
        isVerified: p.isVerified,
        createdAt: p.createdAt,
        capturedBy: { id: p.capturedBy.id, name: p.capturedBy.name },
      })),
      recipientName: shipment.recipientName,
      recipientPhone: shipment.recipientPhone,
      requiresSignature: shipment.requiresSignature,
      specialHandlingInstructions: shipment.specialHandlingInstructions,
      createdAt: shipment.createdAt,
      updatedAt: shipment.updatedAt,
    };
  }

  /**
   * List shipments with filters
   * Filters: status, transportMode, driverId, contractId
   */
  async listShipments(
    filters?: {
      status?: ShipmentStatus;
      transportMode?: string;
      driverId?: string;
      contractId?: string;
      userId?: string; // Filter to shipments where user is buyer or seller
      limit?: number;
      offset?: number;
    },
  ): Promise<ShipmentListResponseDTO> {
    const limit = Math.min(filters?.limit || 20, 100);
    const offset = filters?.offset || 0;

    const query = this.shipmentRepo
      .createQueryBuilder('s')
      .leftJoinAndSelect('s.contract', 'c')
      .leftJoinAndSelect('s.driver', 'd');

    if (filters?.status) {
      query.andWhere('s.status = :status', { status: filters.status });
    }

    if (filters?.transportMode) {
      query.andWhere('s.transportMode = :transportMode', { transportMode: filters.transportMode });
    }

    if (filters?.driverId) {
      query.andWhere('s.driverId = :driverId', { driverId: filters.driverId });
    }

    if (filters?.contractId) {
      query.andWhere('s.contractId = :contractId', { contractId: filters.contractId });
    }

    // User scoping: only show shipments where user is contract party
    if (filters?.userId) {
      query.andWhere('(c.buyerId = :userId OR c.sellerId = :userId)', { userId: filters.userId });
    }

    const [data, total] = await query
      .orderBy('s.createdAt', 'DESC')
      .limit(limit)
      .offset(offset)
      .getManyAndCount();

    return {
      data: data.map((s) => this.formatShipmentResponse(s)),
      pagination: {
        limit,
        offset,
        total,
        hasMore: offset + limit < total,
      },
    };
  }

  /**
   * Get shipment tracking history
   */
  async getTrackingHistory(shipmentId: string): Promise<any[]> {
    const events = await this.trackingRepo.find({
      where: { shipmentId },
      order: { createdAt: 'DESC' },
    });

    return events.map((e) => ({
      id: e.id,
      eventType: e.eventType,
      message: e.message,
      latitude: e.latitude,
      longitude: e.longitude,
      locationName: e.locationName,
      metadata: e.metadata,
      createdAt: e.createdAt,
    }));
  }

  /**
   * Get delivery proofs for shipment
   */
  async getDeliveryProofs(shipmentId: string): Promise<any[]> {
    const proofs = await this.proofRepo.find({
      where: { shipmentId },
      relations: ['capturedBy'],
      order: { createdAt: 'DESC' },
    });

    return proofs.map((p) => ({
      id: p.id,
      proofType: p.proofType,
      description: p.description,
      dataBlobUrl: p.dataBlobUrl,
      recipientName: p.recipientName,
      recipientIdType: p.recipientIdType,
      recipientIdNumber: p.recipientIdNumber,
      conditionAssessment: p.conditionAssessment,
      latitude: p.latitude,
      longitude: p.longitude,
      isVerified: p.isVerified,
      createdAt: p.createdAt,
      capturedBy: { id: p.capturedBy.id, name: p.capturedBy.name },
    }));
  }

  /**
   * Get shipment statistics
   */
  async getShipmentStatistics(contractId?: string): Promise<ShipmentSummaryDTO> {
    const query = this.shipmentRepo.createQueryBuilder('s');

    if (contractId) {
      query.andWhere('s.contractId = :contractId', { contractId });
    }

    const total = await query.getCount();

    const inTransit = await query
      .clone()
      .andWhere('s.status = :status', { status: ShipmentStatus.IN_TRANSIT })
      .getCount();

    const delivered = await query
      .clone()
      .andWhere('s.status = :status', { status: ShipmentStatus.DELIVERED })
      .getCount();

    const failed = await query
      .clone()
      .andWhere('s.status = :status', { status: ShipmentStatus.FAILED_DELIVERY })
      .getCount();

    // Calculate average delivery days (only for delivered shipments)
    const deliveredShipments = await query
      .clone()
      .andWhere('s.status = :status', { status: ShipmentStatus.DELIVERED })
      .andWhere('s.actualDeliveryDate IS NOT NULL')
      .andWhere('s.pickupDate IS NOT NULL')
      .getMany();

    const avgDeliveryDays =
      deliveredShipments.length > 0
        ? deliveredShipments.reduce((sum, s) => {
            const days = Math.floor((s.actualDeliveryDate.getTime() - s.pickupDate.getTime()) / (1000 * 60 * 60 * 24));
            return sum + days;
          }, 0) / deliveredShipments.length
        : 0;

    // Calculate on-time delivery rate
    const onTimeShipments = deliveredShipments.filter((s) => s.actualDeliveryDate <= s.expectedDeliveryDate).length;
    const onTimeDeliveryRate = deliveredShipments.length > 0 ? (onTimeShipments / deliveredShipments.length) * 100 : 0;

    return {
      totalShipments: total,
      inTransit,
      delivered,
      failed,
      avgDeliveryDays: Math.round(avgDeliveryDays * 100) / 100,
      onTimeDeliveryRate: Math.round(onTimeDeliveryRate * 100) / 100,
    };
  }

  /**
   * Cancel shipment
   */
  async cancelShipment(shipmentId: string, reason: string): Promise<ShipmentResponseDTO> {
    const shipment = await this.shipmentRepo.findOne({ where: { id: shipmentId } });

    if (!shipment) {
      throw new NotFoundException(`Shipment ${shipmentId} not found`);
    }

    if (shipment.status === ShipmentStatus.DELIVERED) {
      throw new BadRequestException('Cannot cancel delivered shipment');
    }

    shipment.status = ShipmentStatus.CANCELLED;

    const updated = await this.shipmentRepo.save(shipment);

    await this.trackingRepo.save(
      this.trackingRepo.create({
        shipmentId,
        eventType: TrackingEventType.CANCELLED,
        message: `Shipment cancelled. Reason: ${reason}`,
      }),
    );

    return this.formatShipmentResponse(updated);
  }

  // ======================== PRIVATE HELPERS ========================

  private validateStatusTransition(currentStatus: ShipmentStatus, newStatus: ShipmentStatus): void {
    const validTransitions: Record<ShipmentStatus, ShipmentStatus[]> = {
      [ShipmentStatus.PENDING]: [ShipmentStatus.SCHEDULED, ShipmentStatus.CANCELLED],
      [ShipmentStatus.SCHEDULED]: [ShipmentStatus.IN_TRANSIT, ShipmentStatus.CANCELLED],
      [ShipmentStatus.IN_TRANSIT]: [ShipmentStatus.ARRIVED_DESTINATION, ShipmentStatus.EXCEPTION],
      [ShipmentStatus.ARRIVED_DESTINATION]: [ShipmentStatus.DELIVERED, ShipmentStatus.FAILED_DELIVERY],
      [ShipmentStatus.DELIVERED]: [],
      [ShipmentStatus.FAILED_DELIVERY]: [ShipmentStatus.SCHEDULED, ShipmentStatus.CANCELLED],
      [ShipmentStatus.CANCELLED]: [],
    };

    if (!validTransitions[currentStatus] || !validTransitions[currentStatus].includes(newStatus)) {
      throw new BadRequestException(`Cannot transition from ${currentStatus} to ${newStatus}`);
    }
  }

  private formatShipmentResponse(shipment: Shipment): ShipmentResponseDTO {
    return {
      id: shipment.id,
      shipmentReference: shipment.shipmentReference,
      status: shipment.status,
      transportMode: shipment.transportMode,
      pickupLocationName: shipment.pickupLocationName,
      deliveryLocationName: shipment.deliveryLocationName,
      pickupDate: shipment.pickupDate,
      expectedDeliveryDate: shipment.expectedDeliveryDate,
      actualDeliveryDate: shipment.actualDeliveryDate,
      daysInTransit: shipment.getDaysInTransit(),
      isDelayed: shipment.isDelayed(),
      driver: shipment.driver
        ? {
            id: shipment.driver.id,
            name: shipment.driver.name,
            phone: shipment.driver.phone,
          }
        : null,
      vehicleRegistration: shipment.vehicleRegistration,
      trackingUrl: shipment.trackingUrl,
      deliveryProofCount: shipment.deliveryProofs?.length || 0,
      createdAt: shipment.createdAt,
      updatedAt: shipment.updatedAt,
    };
  }
}
