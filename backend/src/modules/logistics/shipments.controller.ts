import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  BadRequestException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Roles } from '../auth/roles.decorator';
import { RolesGuard } from '../auth/roles.guard';
import { ShipmentsService } from './shipments.service';
import {
  CreateShipmentDTO,
  AssignDriverDTO,
  UpdateShipmentStatusDTO,
  AddTrackingEventDTO,
  CaptureDeliveryProofDTO,
  RescheduleDeliveryDTO,
} from './shipment.dto';
import { ShipmentStatus } from './shipment.entity';

@Controller('api/shipments')
@UseGuards(AuthGuard('jwt'), RolesGuard)
export class ShipmentsController {
  constructor(private shipmentsService: ShipmentsService) {}

  /**
   * POST /api/shipments
   * Create new shipment from contract
   * Auth: Buyer, Seller (contract parties), Admin
   */
  @Post()
  @Roles('buyer', 'seller', 'admin')
  async createShipment(@Body() dto: CreateShipmentDTO, @Request() req: any) {
    return this.shipmentsService.createShipment(dto, req.user.id);
  }

  /**
   * POST /api/shipments/:id/assign-driver
   * Assign driver to shipment
   * Auth: Admin, Logistics Manager
   */
  @Post(':id/assign-driver')
  @Roles('admin', 'logistics_manager')
  async assignDriver(
    @Param('id') shipmentId: string,
    @Body() dto: AssignDriverDTO,
    @Request() req: any,
  ) {
    return this.shipmentsService.assignDriver(shipmentId, dto, req.user.id);
  }

  /**
   * PATCH /api/shipments/:id/status
   * Update shipment status
   * Validates status transitions
   * Auth: Driver, Admin, Logistics Manager
   */
  @Patch(':id/status')
  @Roles('driver', 'admin', 'logistics_manager')
  async updateStatus(
    @Param('id') shipmentId: string,
    @Body() dto: UpdateShipmentStatusDTO,
    @Request() req: any,
  ) {
    return this.shipmentsService.updateStatus(shipmentId, dto, req.user.id);
  }

  /**
   * GET /api/shipments/:id
   * Get complete shipment details
   * Includes tracking history and delivery proofs
   * Auth: All authenticated
   */
  @Get(':id')
  @Roles('buyer', 'seller', 'driver', 'admin', 'logistics_manager')
  async getShipment(@Param('id') shipmentId: string) {
    return this.shipmentsService.getShipmentById(shipmentId);
  }

  /**
   * GET /api/shipments
   * List shipments with filters
   * Query params: status, transportMode, driverId, contractId, limit, offset
   * Auth: All authenticated (user-scoped)
   */
  @Get()
  @Roles('buyer', 'seller', 'driver', 'admin', 'logistics_manager')
  async listShipments(
    @Query('status') status?: string,
    @Query('transportMode') transportMode?: string,
    @Query('driverId') driverId?: string,
    @Query('contractId') contractId?: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
    @Request() req?: any,
  ) {
    // Only admins can filter all shipments; others see only their own
    const userId = req.user.role === 'admin' ? undefined : req.user.id;

    return this.shipmentsService.listShipments({
      status: status as ShipmentStatus,
      transportMode,
      driverId,
      contractId,
      userId,
      limit: limit ? Math.min(parseInt(limit), 100) : 20,
      offset: offset ? parseInt(offset) : 0,
    });
  }

  /**
   * POST /api/shipments/:id/tracking-event
   * Add real-time tracking event with GPS location
   * Called by driver app periodically
   * Auth: Driver, Admin
   */
  @Post(':id/tracking-event')
  @Roles('driver', 'admin')
  async addTrackingEvent(
    @Param('id') shipmentId: string,
    @Body() dto: AddTrackingEventDTO,
    @Request() req: any,
  ) {
    return this.shipmentsService.addTrackingEvent(shipmentId, dto, req.user.id);
  }

  /**
   * GET /api/shipments/:id/tracking
   * Get complete tracking history for shipment
   * Auth: All authenticated
   */
  @Get(':id/tracking')
  @Roles('buyer', 'seller', 'driver', 'admin', 'logistics_manager')
  async getTrackingHistory(@Param('id') shipmentId: string) {
    return this.shipmentsService.getTrackingHistory(shipmentId);
  }

  /**
   * POST /api/shipments/:id/delivery-proof
   * Capture delivery proof (signature, photo, ID)
   * Auth: Driver, Admin
   */
  @Post(':id/delivery-proof')
  @Roles('driver', 'admin')
  async captureDeliveryProof(
    @Param('id') shipmentId: string,
    @Body() dto: CaptureDeliveryProofDTO,
    @Request() req: any,
  ) {
    return this.shipmentsService.captureDeliveryProof(shipmentId, dto, req.user.id);
  }

  /**
   * GET /api/shipments/:id/delivery-proofs
   * Get all delivery proofs for shipment
   * Auth: All authenticated
   */
  @Get(':id/delivery-proofs')
  @Roles('buyer', 'seller', 'driver', 'admin', 'logistics_manager')
  async getDeliveryProofs(@Param('id') shipmentId: string) {
    return this.shipmentsService.getDeliveryProofs(shipmentId);
  }

  /**
   * PATCH /api/shipments/:id/reschedule
   * Reschedule delivery to new date
   * Auth: Driver, Admin, Logistics Manager
   */
  @Patch(':id/reschedule')
  @Roles('driver', 'admin', 'logistics_manager')
  async rescheduleDelivery(
    @Param('id') shipmentId: string,
    @Body() dto: RescheduleDeliveryDTO,
    @Request() req: any,
  ) {
    return this.shipmentsService.rescheduleDelivery(shipmentId, dto, req.user.id);
  }

  /**
   * GET /api/shipments/:id/summary
   * Get shipment statistics (for dashboard)
   * Auth: All authenticated
   */
  @Get(':id/summary')
  @Roles('buyer', 'seller', 'admin', 'logistics_manager')
  async getShipmentStatistics(@Param('id') shipmentId: string) {
    return this.shipmentsService.getShipmentStatistics(shipmentId);
  }

  /**
   * DELETE /api/shipments/:id
   * Cancel shipment
   * Can only cancel non-delivered shipments
   * Auth: Admin, Logistics Manager
   */
  @Delete(':id')
  @Roles('admin', 'logistics_manager')
  @HttpCode(HttpStatus.OK)
  async cancelShipment(
    @Param('id') shipmentId: string,
    @Query('reason') reason?: string,
  ) {
    if (!reason) {
      throw new BadRequestException('Cancellation reason is required');
    }
    return this.shipmentsService.cancelShipment(shipmentId, reason);
  }

  /**
   * GET /api/shipments/statistics/overview
   * Get overall shipment statistics (for admin dashboard)
   * Auth: Admin
   */
  @Get('statistics/overview')
  @Roles('admin', 'logistics_manager')
  async getOverallStatistics() {
    return this.shipmentsService.getShipmentStatistics();
  }
}
