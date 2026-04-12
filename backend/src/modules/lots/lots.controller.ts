import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { LotsService } from './lots.service';
import { CreateLotDto, UpdateLotDto, LotSearchQueryDto, LotResponseDto } from './dtos/lot.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('api/lots')
export class LotsController {
  constructor(private readonly lotsService: LotsService) {}

  /**
   * POST /api/lots
   * Create a new lot (product listing)
   * Requires authentication
   */
  @UseGuards(JwtAuthGuard)
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createLot(
    @Request() req,
    @Body() createLotDto: CreateLotDto,
  ): Promise<LotResponseDto> {
    return this.lotsService.createLot(req.user.id, createLotDto);
  }

  /**
   * GET /api/lots
   * List all active lots with filtering, searching, and pagination
   * Public endpoint
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  async getLots(
    @Query() query: LotSearchQueryDto,
  ): Promise<{
    data: LotResponseDto[];
    total: number;
    page: number;
    limit: number;
  }> {
    return this.lotsService.getAllLots(query);
  }

  /**
   * GET /api/lots/:id
   * Get single lot by ID
   * Public endpoint
   */
  @Get(':id')
  @HttpCode(HttpStatus.OK)
  async getLotById(@Param('id') lotId: string): Promise<LotResponseDto> {
    return this.lotsService.getLotById(lotId);
  }

  /**
   * GET /api/lots/qr/:code
   * Get lot by QR code (for verification)
   * Public endpoint
   */
  @Get('qr/:code')
  @HttpCode(HttpStatus.OK)
  async getLotByQRCode(@Param('code') qrCode: string): Promise<LotResponseDto> {
    return this.lotsService.getLotByQRCode(qrCode);
  }

  /**
   * PUT /api/lots/:id
   * Update lot (seller only)
   * Requires authentication
   */
  @UseGuards(JwtAuthGuard)
  @Put(':id')
  @HttpCode(HttpStatus.OK)
  async updateLot(
    @Request() req,
    @Param('id') lotId: string,
    @Body() updateLotDto: UpdateLotDto,
  ): Promise<LotResponseDto> {
    return this.lotsService.updateLot(lotId, req.user.id, updateLotDto);
  }

  /**
   * DELETE /api/lots/:id
   * Delete lot (soft delete, seller only)
   * Requires authentication
   */
  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async deleteLot(
    @Request() req,
    @Param('id') lotId: string,
  ): Promise<{ message: string }> {
    return this.lotsService.deleteLot(lotId, req.user.id);
  }

  /**
   * GET /api/lots/search
   * Search lots (full-text search)
   * Public endpoint
   */
  @Get('search/:query')
  @HttpCode(HttpStatus.OK)
  async searchLots(
    @Param('query') searchQuery: string,
    @Query('limit') limit: number = 20,
  ): Promise<LotResponseDto[]> {
    return this.lotsService.searchLots(searchQuery, limit);
  }

  /**
   * POST /api/lots/:id/verify
   * Verify lot (admin only)
   * Requires authentication and admin role
   */
  @UseGuards(JwtAuthGuard)
  @Post(':id/verify')
  @HttpCode(HttpStatus.OK)
  async verifyLot(
    @Param('id') lotId: string,
    @Body() body: { approved: boolean },
  ): Promise<LotResponseDto> {
    // TODO: Add admin role check
    return this.lotsService.verifyLot(lotId, body.approved);
  }

  /**
   * GET /api/lots/location/:latitude/:longitude
   * Get lots by geographic location
   * Public endpoint
   */
  @Get('location/:latitude/:longitude')
  @HttpCode(HttpStatus.OK)
  async getLotsByLocation(
    @Param('latitude') latitude: number,
    @Param('longitude') longitude: number,
    @Query('radius') radius: number = 50,
  ): Promise<LotResponseDto[]> {
    return this.lotsService.getLotsByLocation(latitude, longitude, radius);
  }

  /**
   * GET /api/lots/seller/me
   * Get current user's lots (seller dashboard)
   * Requires authentication
   */
  @UseGuards(JwtAuthGuard)
  @Get('seller/me')
  @HttpCode(HttpStatus.OK)
  async getMyLots(
    @Request() req,
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 20,
  ): Promise<{
    data: LotResponseDto[];
    total: number;
  }> {
    return this.lotsService.getSellerLots(req.user.id, page, limit);
  }
}
