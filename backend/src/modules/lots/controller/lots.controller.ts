import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  BadRequestException,
} from '@nestjs/common';
import { LotsService } from '../services/lots.service';
import { CreateLotDTO, UpdateLotDTO, LotFilterDTO, LotResponseDTO } from '../dto/lot.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@Controller('api/lots')
export class LotsController {
  constructor(private lotsService: LotsService) {}

  /**
   * POST /api/lots
   * Create a new lot (requires authentication)
   */
  @Post()
  @UseGuards(JwtAuthGuard)
  async createLot(@Body() createLotDTO: CreateLotDTO, @Request() req: any): Promise<LotResponseDTO> {
    return this.lotsService.createLot(createLotDTO, req.user.id);
  }

  /**
   * GET /api/lots
   * List all lots with optional filtering
   */
  @Get()
  async listLots(@Query() query: any): Promise<{ data: any[]; total: number }> {
    const page = parseInt(query.page) || 1;
    const limit = parseInt(query.limit) || 20;

    if (limit > 100) {
      throw new BadRequestException('Limit cannot exceed 100');
    }

    const filter: LotFilterDTO = {
      category: query.category,
      originCountry: query.originCountry,
      status: query.status,
      minPrice: query.minPrice ? parseFloat(query.minPrice) : undefined,
      maxPrice: query.maxPrice ? parseFloat(query.maxPrice) : undefined,
      gradeLevel: query.gradeLevel,
      searchTerm: query.search,
    };

    return this.lotsService.listLots(page, limit, filter);
  }

  /**
   * GET /api/lots/:id
   * Get specific lot details with full history
   */
  @Get(':id')
  async getLotDetails(@Param('id') lotId: string): Promise<any> {
    return this.lotsService.getLotFullDetails(lotId);
  }

  /**
   * GET /api/lots/:id/qr-code
   * Get QR code image for lot
   */
  @Get(':id/qr-code')
  async getQRCode(@Param('id') lotId: string): Promise<{ qrCodeImage: string }> {
    const qrCodeImage = await this.lotsService.getQRCodeImage(lotId);
    return { qrCodeImage };
  }

  /**
   * GET /api/lots/:id/traceability
   * Get complete traceability history
   */
  @Get(':id/traceability')
  async getTraceability(@Param('id') lotId: string): Promise<any> {
    return this.lotsService.getTraceabilityHistory(lotId);
  }

  /**
   * PUT /api/lots/:id
   * Update lot (only seller, only in draft status)
   */
  @Put(':id')
  @UseGuards(JwtAuthGuard)
  async updateLot(
    @Param('id') lotId: string,
    @Body() updateLotDTO: UpdateLotDTO,
    @Request() req: any,
  ): Promise<LotResponseDTO> {
    return this.lotsService.updateLot(lotId, updateLotDTO, req.user.id);
  }

  /**
   * POST /api/lots/:id/publish
   * Publish lot to marketplace
   */
  @Post(':id/publish')
  @UseGuards(JwtAuthGuard)
  async publishLot(@Param('id') lotId: string, @Request() req: any): Promise<LotResponseDTO> {
    return this.lotsService.publishLot(lotId, req.user.id);
  }

  /**
   * POST /api/lots/:id/archive
   * Archive lot
   */
  @Post(':id/archive')
  @UseGuards(JwtAuthGuard)
  async archiveLot(@Param('id') lotId: string, @Request() req: any): Promise<LotResponseDTO> {
    return this.lotsService.archiveLot(lotId, req.user.id);
  }

  /**
   * GET /api/lots/search
   * Search by batch number or QR code
   */
  @Get('search/query')
  async searchLot(@Query('query') query: string): Promise<any[]> {
    if (!query || query.length < 3) {
      throw new BadRequestException('Search query must be at least 3 characters');
    }
    return this.lotsService.searchByBatchOrQR(query);
  }

  /**
   * GET /api/lots/by-supplier/:supplierId
   * Get all lots by a specific supplier
   */
  @Get('by-supplier/:supplierId')
  async getLotsBySupplier(
    @Param('supplierId') supplierId: string,
    @Query() query: any,
  ): Promise<{ data: any[]; total: number }> {
    const page = parseInt(query.page) || 1;
    const limit = parseInt(query.limit) || 20;
    return this.lotsService.listLots(page, limit, { originCountry: supplierId });
  }
}
