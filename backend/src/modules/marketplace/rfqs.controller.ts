import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Query,
  UseGuards,
  Req,
  BadRequestException,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags, ApiPaginatedResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RFQsService } from './rfqs.service';
import { CreateRFQDTO, SubmitBidDTO, RFQFilterDTO, AwardBidDTO, RFQResponseDTO, RFQBidResponseDTO } from './rfq.dto';

@ApiTags('Marketplace - RFQs')
@Controller('api/rfqs')
export class RFQsController {
  constructor(private rfqsService: RFQsService) {}

  /**
   * Create new RFQ (buyer only)
   * POST /api/rfqs
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post()
  async createRFQ(@Body() dto: CreateRFQDTO, @Req() req: any) {
    const rfq = await this.rfqsService.createRFQ(dto, req.user.id);
    return {
      success: true,
      message: 'RFQ created successfully',
      data: this._formatRFQ(rfq),
    };
  }

  /**
   * List all open RFQs (public - suppliers browse)
   * GET /api/rfqs?status=open&category=Cocoa&page=1&limit=20
   */
  @Get()
  async listOpenRFQs(@Query() filters: RFQFilterDTO) {
    const { data, total } = await this.rfqsService.listOpenRFQs(filters);
    return {
      success: true,
      data: data.map((rfq) => this._formatRFQ(rfq)),
      pagination: {
        total,
        page: filters.page || 1,
        limit: filters.limit || 20,
        pages: Math.ceil(total / (filters.limit || 20)),
      },
    };
  }

  /**
   * Get RFQ details with all bids (public)
   * GET /api/rfqs/:id
   */
  @Get(':id')
  async getRFQDetails(@Param('id') rfqId: string) {
    const rfq = await this.rfqsService.getRFQById(rfqId);
    return {
      success: true,
      data: this._formatRFQ(rfq),
    };
  }

  /**
   * Get RFQ statistics (public)
   * GET /api/rfqs/:id/stats
   */
  @Get(':id/stats')
  async getRFQStats(@Param('id') rfqId: string) {
    const stats = await this.rfqsService.getRFQStats(rfqId);
    return {
      success: true,
      data: stats,
    };
  }

  /**
   * Get all bids for RFQ (buyer only)
   * GET /api/rfqs/:id/bids
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Get(':id/bids')
  async getRFQBids(@Param('id') rfqId: string, @Req() req: any) {
    const bids = await this.rfqsService.getRFQBids(rfqId, req.user.id);
    return {
      success: true,
      data: bids.map((bid) => this._formatBid(bid)),
    };
  }

  /**
   * Get buyer's own RFQs
   * GET /api/rfqs/buyer/my-rfqs?status=open&page=1&limit=20
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Get('buyer/my-rfqs')
  async getBuyerRFQs(@Query() filters: RFQFilterDTO, @Req() req: any) {
    const { data, total } = await this.rfqsService.getBuyerRFQs(req.user.id, filters);
    return {
      success: true,
      data: data.map((rfq) => this._formatRFQ(rfq)),
      pagination: {
        total,
        page: filters.page || 1,
        limit: filters.limit || 20,
        pages: Math.ceil(total / (filters.limit || 20)),
      },
    };
  }

  /**
   * Get supplier's bids
   * GET /api/rfqs/supplier/my-bids?status=pending&page=1&limit=20
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Get('supplier/my-bids')
  async getSupplierBids(@Query() filters: RFQFilterDTO, @Req() req: any) {
    const { data, total } = await this.rfqsService.getSupplierBids(req.user.id, filters);
    return {
      success: true,
      data: data.map((bid) => this._formatBid(bid)),
      pagination: {
        total,
        page: filters.page || 1,
        limit: filters.limit || 20,
        pages: Math.ceil(total / (filters.limit || 20)),
      },
    };
  }

  /**
   * Submit bid for RFQ (supplier only)
   * POST /api/rfqs/:id/bids
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post(':id/bids')
  async submitBid(@Param('id') rfqId: string, @Body() dto: SubmitBidDTO, @Req() req: any) {
    if (dto.rfqId !== rfqId) {
      throw new BadRequestException('RFQ ID mismatch');
    }
    const bid = await this.rfqsService.submitBid(dto, req.user.id);
    return {
      success: true,
      message: 'Bid submitted successfully',
      data: this._formatBid(bid),
    };
  }

  /**
   * Award bid to supplier (buyer only)
   * POST /api/rfqs/:id/award-bid
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post(':id/award-bid')
  async awardBid(@Param('id') rfqId: string, @Body() dto: AwardBidDTO, @Req() req: any) {
    const rfq = await this.rfqsService.awardBid(rfqId, dto, req.user.id);
    return {
      success: true,
      message: 'Bid awarded successfully. Contract will be auto-generated.',
      data: this._formatRFQ(rfq),
    };
  }

  /**
   * Close RFQ (buyer only)
   * POST /api/rfqs/:id/close
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post(':id/close')
  async closeRFQ(@Param('id') rfqId: string, @Req() req: any) {
    const rfq = await this.rfqsService.closeRFQ(rfqId, req.user.id);
    return {
      success: true,
      message: 'RFQ closed successfully',
      data: this._formatRFQ(rfq),
    };
  }

  /**
   * Get recommended suppliers for RFQ (AI-powered)
   * GET /api/rfqs/:id/recommended-suppliers
   */
  @Get(':id/recommended-suppliers')
  async getRecommendedSuppliers(@Param('id') rfqId: string) {
    const suppliers = await this.rfqsService.getRecommendedSuppliers(rfqId, 5);
    return {
      success: true,
      data: suppliers,
    };
  }

  // Helper methods
  private _formatRFQ(rfq: any): RFQResponseDTO {
    return {
      id: rfq.id,
      buyerId: rfq.buyerId,
      buyerEmail: rfq.buyer?.email || '',
      buyerCompanyName: rfq.buyerCompanyName,
      productCategory: rfq.productCategory,
      productDescription: rfq.productDescription,
      quantity: rfq.quantity,
      quantityUnit: rfq.quantityUnit,
      originCountryPreference: rfq.originCountryPreference,
      gradePreference: rfq.gradePreference,
      deliveryLocation: rfq.deliveryLocation,
      deliveryDeadline: rfq.deliveryDeadline,
      paymentTerms: rfq.paymentTerms,
      maxBidsExpected: rfq.maxBidsExpected,
      submittedBids: (rfq.submittedBids || []).map((bid) => this._formatBid(bid)),
      status: rfq.status,
      selectedSupplierId: rfq.selectedSupplierId,
      selectedSupplierBidId: rfq.selectedSupplierBidId,
      createdAt: rfq.createdAt,
      expiresAt: rfq.expiresAt,
      description: rfq.description,
    };
  }

  private _formatBid(bid: any): RFQBidResponseDTO {
    return {
      id: bid.id,
      rfqId: bid.rfqId,
      supplierId: bid.supplierId,
      supplierEmail: bid.supplier?.email || '',
      supplierCompanyName: bid.supplierCompanyName,
      pricePerUnit: bid.pricePerUnit,
      totalPrice: bid.totalPrice,
      originCountry: bid.originCountry,
      gradeLevel: bid.gradeLevel,
      estimatedDelivery: bid.estimatedDelivery,
      paymentMethod: bid.paymentMethod,
      specialTerms: bid.specialTerms,
      status: bid.status,
      submittedAt: bid.submittedAt,
      documentCount: bid.documentCount,
      certificationsIncluded: bid.certificationsIncluded,
    };
  }
}
