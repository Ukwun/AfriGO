import { Injectable, BadRequestException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Lot, GradeLevel } from '../entities/lot.entity';
import { LotTraceability, TraceabilityEventType } from '../entities/lot-traceability.entity';
import { QualityReport } from '../entities/quality-report.entity';
import { CreateLotDTO, UpdateLotDTO, LotFilterDTO } from '../dto/lot.dto';
import * as QRCode from 'qrcode';
import * as crypto from 'crypto';

@Injectable()
export class LotsService {
  constructor(
    @InjectRepository(Lot) private lotRepository: Repository<Lot>,
    @InjectRepository(LotTraceability) private traceabilityRepository: Repository<LotTraceability>,
    @InjectRepository(QualityReport) private qualityReportRepository: Repository<QualityReport>,
  ) {}

  /**
   * Create a new lot
   */
  async createLot(createLotDTO: CreateLotDTO, currentUserId: string): Promise<Lot> {
    // Generate unique batch number and QR code
    const batchNumber = this.generateBatchNumber();
    const qrCode = this.generateQRCode(batchNumber);

    const totalValue = createLotDTO.quantity * createLotDTO.pricePerUnit;

    const lot = this.lotRepository.create({
      ...createLotDTO,
      sellerId: currentUserId,
      batchNumber,
      qrCode,
      totalValue,
      status: 'draft',
      verifyStatus: 'pending',
    });

    const savedLot = await this.lotRepository.save(lot);

    // Log creation event in traceability
    await this.addTraceabilityEvent(savedLot.id, TraceabilityEventType.CREATED, currentUserId, {
      description: `Lot created by seller`,
      metadata: { productName: createLotDTO.productName, quantity: createLotDTO.quantity },
    });

    return savedLot;
  }

  /**
   * Get lot by ID
   */
  async getLotById(lotId: string): Promise<Lot> {
    const lot = await this.lotRepository.findOne({ where: { id: lotId } });
    if (!lot) {
      throw new NotFoundException(`Lot ${lotId} not found`);
    }
    return lot;
  }

  /**
   * List lots with filtering
   */
  async listLots(page = 1, limit = 20, filter?: LotFilterDTO): Promise<{ data: Lot[]; total: number }> {
    const query = this.lotRepository.createQueryBuilder('lot');

    // Only show active or verified lots
    query.where('lot.status IN (:...statuses)', { statuses: ['active', 'sold', 'reserved'] });

    // Apply filters
    if (filter?.category) {
      query.andWhere('LOWER(lot.category) = LOWER(:category)', { category: filter.category });
    }

    if (filter?.originCountry) {
      query.andWhere('LOWER(lot.originCountry) = LOWER(:country)', { country: filter.originCountry });
    }

    if (filter?.gradeLevel) {
      query.andWhere('lot.gradeLevel = :grade', { grade: filter.gradeLevel });
    }

    if (filter?.minPrice) {
      query.andWhere('lot.pricePerUnit >= :minPrice', { minPrice: filter.minPrice });
    }

    if (filter?.maxPrice) {
      query.andWhere('lot.pricePerUnit <= :maxPrice', { maxPrice: filter.maxPrice });
    }

    if (filter?.searchTerm) {
      query.andWhere(`(
        LOWER(lot.productName) LIKE LOWER(:search) OR
        LOWER(lot.description) LIKE LOWER(:search) OR
        LOWER(lot.batchNumber) = LOWER(:search)
      )`, { search: `%${filter.searchTerm}%` });
    }

    // Pagination
    const offset = (page - 1) * limit;
    query.skip(offset).take(limit);

    // Order by most recent
    query.orderBy('lot.createdAt', 'DESC');

    const [data, total] = await query.getManyAndCount();

    return { data, total };
  }

  /**
   * Get QR code image
   */
  async getQRCodeImage(lotId: string): Promise<string> {
    const lot = await this.getLotById(lotId);
    
    // Generate QR code as data URL
    const qrCodeImage = await QRCode.toDataURL(lot.qrCode, {
      errorCorrectionLevel: 'H',
      type: 'image/png',
      width: 300,
      margin: 1,
    });

    return qrCodeImage;
  }

  /**
   * Update lot (only by seller, only in draft status)
   */
  async updateLot(lotId: string, updateLotDTO: UpdateLotDTO, currentUserId: string): Promise<Lot> {
    const lot = await this.getLotById(lotId);

    // Authorization check
    if (lot.sellerId !== currentUserId) {
      throw new ForbiddenException('You can only update your own lots');
    }

    // Only allow updates in draft status
    if (lot.status !== 'draft') {
      throw new BadRequestException('Can only update lots in draft status');
    }

    // Update fields
    Object.assign(lot, updateLotDTO);

    // Recalculate total value if quantity or price changed
    if (updateLotDTO.quantity || updateLotDTO.pricePerUnit) {
      lot.totalValue = lot.quantity * lot.pricePerUnit;
    }

    return this.lotRepository.save(lot);
  }

  /**
   * Publish lot to marketplace
   */
  async publishLot(lotId: string, currentUserId: string): Promise<Lot> {
    const lot = await this.getLotById(lotId);

    // Authorization
    if (lot.sellerId !== currentUserId) {
      throw new ForbiddenException('You can only publish your own lots');
    }

    // Validation
    if (lot.status !== 'draft') {
      throw new BadRequestException('Only draft lots can be published');
    }

    // Must have at least one image
    if (!lot.images || lot.images.length === 0) {
      throw new BadRequestException('Lot must have at least one image');
    }

    // Update status
    lot.status = 'active';
    lot.listingDate = new Date();
    lot.expiresAt = new Date(Date.now() + 90 * 24 * 60 * 60 * 1000); // Expires in 90 days

    const updatedLot = await this.lotRepository.save(lot);

    // Log event
    await this.addTraceabilityEvent(lotId, TraceabilityEventType.LISTED, currentUserId, {
      description: 'Lot published to marketplace',
    });

    return updatedLot;
  }

  /**
   * Reserve quantity (when buyer creates RFQ)
   */
  async reserveQuantity(lotId: string, quantityToReserve: number, details: any): Promise<Lot> {
    const lot = await this.getLotById(lotId);

    // Check if enough quantity available
    const availableQuantity = lot.quantity - lot.quantityReserved;
    if (quantityToReserve > availableQuantity) {
      throw new BadRequestException(`Only ${availableQuantity} units available for reservation`);
    }

    lot.quantityReserved += quantityToReserve;
    if (lot.quantityReserved >= lot.quantity) {
      lot.status = 'reserved';
    }

    const updatedLot = await this.lotRepository.save(lot);

    // Log event
    await this.addTraceabilityEvent(lotId, TraceabilityEventType.RESERVED, details.userId, {
      description: `${quantityToReserve} ${lot.quantityUnit} reserved`,
      metadata: { reservedQuantity: quantityToReserve, rfsId: details.rfqId },
    });

    return updatedLot;
  }

  /**
   * Mark as sold (when order is completed)
   */
  async markAsSold(lotId: string, soldQuantity: number, details: any): Promise<Lot> {
    const lot = await this.getLotById(lotId);

    lot.quantitySold += soldQuantity;
    lot.quantityReserved -= soldQuantity;

    if (lot.quantitySold >= lot.quantity) {
      lot.status = 'sold';
    }

    const updatedLot = await this.lotRepository.save(lot);

    // Log event
    await this.addTraceabilityEvent(lotId, TraceabilityEventType.SOLD, details.userId, {
      description: `${soldQuantity} ${lot.quantityUnit} sold`,
      metadata: { soldQuantity, orderId: details.orderId },
    });

    return updatedLot;
  }

  /**
   * Add traceability event
   */
  async addTraceabilityEvent(
    lotId: string,
    eventType: TraceabilityEventType,
    performerId: string,
    details: { description?: string; location?: string; metadata?: any; lat?: number; lng?: number } = {},
  ): Promise<LotTraceability> {
    const event = this.traceabilityRepository.create({
      lotId,
      eventType,
      performerId,
      description: details.description,
      location: details.location,
      latitude: details.lat,
      longitude: details.lng,
      metadata: details.metadata || {},
      eventHash: this.generateEventHash(lotId, eventType),
    });

    return this.traceabilityRepository.save(event);
  }

  /**
   * Get traceability history for a lot
   */
  async getTraceabilityHistory(lotId: string): Promise<LotTraceability[]> {
    const events = await this.traceabilityRepository.find({
      where: { lotId },
      order: { createdAt: 'ASC' },
      relations: ['performer'],
    });

    return events;
  }

  /**
   * Get lot with full details (including traceability)
   */
  async getLotFullDetails(lotId: string) {
    const lot = await this.getLotById(lotId);
    
    const traceability = await this.getTraceabilityHistory(lotId);
    
    const qualityReport = await this.qualityReportRepository.findOne({
      where: { lotId },
      order: { createdAt: 'DESC' },
    });

    return {
      ...lot,
      traceabilityHistory: traceability,
      latestQualityReport: qualityReport,
    };
  }

  /**
   * Archive lot (seller action or automatic after expiry)
   */
  async archiveLot(lotId: string, currentUserId: string): Promise<Lot> {
    const lot = await this.getLotById(lotId);

    if (lot.sellerId !== currentUserId) {
      throw new ForbiddenException('You can only archive your own lots');
    }

    lot.status = 'archived';
    const updatedLot = await this.lotRepository.save(lot);

    await this.addTraceabilityEvent(lotId, TraceabilityEventType.ARCHIVED, currentUserId, {
      description: 'Lot archived by seller',
    });

    return updatedLot;
  }

  /**
   * Search lots by QR code or batch number
   */
  async searchByBatchOrQR(query: string): Promise<Lot[]> {
    return this.lotRepository.find({
      where: [{ batchNumber: query }, { qrCode: query }],
    });
  }

  /**
   * Helper: Generate unique batch number
   */
  private generateBatchNumber(): string {
    const timestamp = Date.now().toString(36).toUpperCase();
    const random = Math.random().toString(36).substring(2, 8).toUpperCase();
    return `BATCH-${timestamp}-${random}`;
  }

  /**
   * Helper: Generate QR code identifier (not the image, the code value)
   */
  private generateQRCode(batchNumber: string): string {
    // QR code contains: batch number + timestamp + hash
    const timestamp = Date.now();
    const hash = crypto.createHash('sha256').update(batchNumber + timestamp).digest('hex').substring(0, 12);
    return `${batchNumber}-${hash}`;
  }

  /**
   * Helper: Generate cryptographic hash for immutability
   */
  private generateEventHash(lotId: string, eventType: string): string {
    const data = `${lotId}-${eventType}-${Date.now()}`;
    return crypto.createHash('sha256').update(data).digest('hex');
  }
}
