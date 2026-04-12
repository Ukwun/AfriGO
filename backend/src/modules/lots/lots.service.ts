import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike, Between } from 'typeorm';
import { Lot } from './entities/lot.entity';
import { CreateLotDto, UpdateLotDto, LotResponseDto, LotSearchQueryDto } from './dtos/lot.dto';
import * as crypto from 'crypto';

@Injectable()
export class LotsService {
  constructor(
    @InjectRepository(Lot)
    private lotsRepository: Repository<Lot>,
  ) {}

  /**
   * Create a new lot (product listing)
   */
  async createLot(userId: string, createLotDto: CreateLotDto): Promise<LotResponseDto> {
    // Generate QR code (block hash for verification)
    const qrCode = this.generateQRCode(userId, createLotDto.productName);

    const lot = this.lotsRepository.create({
      ...createLotDto,
      sellerId: userId,
      qrCode,
      status: 'draft', // Start as draft
      verifyStatus: 'pending', // Awaiting admin verification
    });

    const savedLot = await this.lotsRepository.save(lot);
    return this.formatLotResponse(savedLot);
  }

  /**
   * Get all lots with filtering and pagination
   */
  async getAllLots(query: LotSearchQueryDto): Promise<{
    data: LotResponseDto[];
    total: number;
    page: number;
    limit: number;
  }> {
    const page = query.page || 1;
    const limit = Math.min(query.limit || 20, 100); // Max 100 per page
    const skip = (page - 1) * limit;

    // Build query filters
    const whereConditions: any = { status: 'active' }; // Only show active lots

    if (query.productName) {
      whereConditions.productName = ILike(`%${query.productName}%`);
    }

    if (query.minPrice || query.maxPrice) {
      whereConditions.pricePerUnit = Between(
        query.minPrice || 0,
        query.maxPrice || 999999,
      );
    }

    if (query.location) {
      whereConditions.pickupLocation = ILike(`%${query.location}%`);
    }

    // Determine sort order
    let order: any = { createdAt: 'DESC' }; // Default: newest first
    if (query.sortBy === 'oldest') {
      order = { createdAt: 'ASC' };
    } else if (query.sortBy === 'priceLow') {
      order = { pricePerUnit: 'ASC' };
    } else if (query.sortBy === 'priceHigh') {
      order = { pricePerUnit: 'DESC' };
    } else if (query.sortBy === 'ratings') {
      order = { averageRating: 'DESC' };
    }

    const [lots, total] = await this.lotsRepository.findAndCount({
      where: whereConditions,
      order,
      skip,
      take: limit,
      relations: ['seller'],
    });

    return {
      data: lots.map(lot => this.formatLotResponse(lot)),
      total,
      page,
      limit,
    };
  }

  /**
   * Get single lot by ID
   */
  async getLotById(lotId: string): Promise<LotResponseDto> {
    const lot = await this.lotsRepository.findOne({
      where: { id: lotId },
      relations: ['seller'],
    });

    if (!lot) {
      throw new NotFoundException(`Lot with ID ${lotId} not found`);
    }

    // Increment view count for analytics
    lot.viewCount += 1;
    await this.lotsRepository.save(lot);

    return this.formatLotResponse(lot);
  }

  /**
   * Get lot by QR code (for verification)
   */
  async getLotByQRCode(qrCode: string): Promise<LotResponseDto> {
    const lot = await this.lotsRepository.findOne({
      where: { qrCode },
      relations: ['seller'],
    });

    if (!lot) {
      throw new NotFoundException(`Lot with QR code ${qrCode} not found`);
    }

    return this.formatLotResponse(lot);
  }

  /**
   * Update lot (seller only)
   */
  async updateLot(
    lotId: string,
    userId: string,
    updateLotDto: UpdateLotDto,
  ): Promise<LotResponseDto> {
    const lot = await this.lotsRepository.findOne({
      where: { id: lotId },
      relations: ['seller'],
    });

    if (!lot) {
      throw new NotFoundException(`Lot with ID ${lotId} not found`);
    }

    // Only the seller can update their own lot
    if (lot.sellerId !== userId) {
      throw new ForbiddenException('You can only update your own lots');
    }

    // Cannot update sold or expired lots
    if (lot.status === 'sold' || lot.status === 'expired') {
      throw new BadRequestException(`Cannot update ${lot.status} lots`);
    }

    // Update the lot
    Object.assign(lot, updateLotDto);
    const updatedLot = await this.lotsRepository.save(lot);

    return this.formatLotResponse(updatedLot);
  }

  /**
   * Delete lot (soft delete)
   */
  async deleteLot(lotId: string, userId: string): Promise<{ message: string }> {
    const lot = await this.lotsRepository.findOne({
      where: { id: lotId },
    });

    if (!lot) {
      throw new NotFoundException(`Lot with ID ${lotId} not found`);
    }

    // Only the seller or admin can delete
    if (lot.sellerId !== userId) {
      throw new ForbiddenException('You can only delete your own lots');
    }

    // Soft delete
    lot.deletedAt = new Date();
    await this.lotsRepository.save(lot);

    return { message: 'Lot deleted successfully' };
  }

  /**
   * Search lots by full-text search
   */
  async searchLots(
    searchQuery: string,
    limit: number = 20,
  ): Promise<LotResponseDto[]> {
    const lots = await this.lotsRepository
      .createQueryBuilder('lot')
      .where('lot.status = :status', { status: 'active' })
      .andWhere(
        '(lot.productName ILIKE :query OR lot.description ILIKE :query OR lot.category ILIKE :query)',
        { query: `%${searchQuery}%` },
      )
      .orderBy('lot.viewCount', 'DESC')
      .limit(limit)
      .getMany();

    return lots.map(lot => this.formatLotResponse(lot));
  }

  /**
   * Verify lot (admin only)
   */
  async verifyLot(
    lotId: string,
    approved: boolean,
  ): Promise<LotResponseDto> {
    const lot = await this.lotsRepository.findOne({
      where: { id: lotId },
      relations: ['seller'],
    });

    if (!lot) {
      throw new NotFoundException(`Lot with ID ${lotId} not found`);
    }

    if (approved) {
      lot.verifyStatus = 'verified';
      lot.status = 'active'; // Auto-activate when verified
    } else {
      lot.verifyStatus = 'rejected';
      lot.status = 'draft'; // Revert to draft
    }

    const updatedLot = await this.lotsRepository.save(lot);
    return this.formatLotResponse(updatedLot);
  }

  /**
   * Get seller's lots
   */
  async getSellerLots(
    sellerId: string,
    page: number = 1,
    limit: number = 20,
  ): Promise<{
    data: LotResponseDto[];
    total: number;
  }> {
    const skip = (page - 1) * limit;

    const [lots, total] = await this.lotsRepository.findAndCount({
      where: { sellerId },
      order: { createdAt: 'DESC' },
      skip,
      take: limit,
      relations: ['seller'],
    });

    return {
      data: lots.map(lot => this.formatLotResponse(lot)),
      total,
    };
  }

  /**
   * Get lots by location (geographic search)
   */
  async getLotsByLocation(
    latitude: number,
    longitude: number,
    radiusKm: number = 50,
  ): Promise<LotResponseDto[]> {
    // Simple distance calculation (good enough for first version)
    // In production, use PostGIS for accurate geographic queries
    const lotDegrees = radiusKm / 111; // 1 degree ≈ 111 km

    const lots = await this.lotsRepository.find({
      where: {
        status: 'active',
        latitude: Between(latitude - lotDegrees, latitude + lotDegrees),
        longitude: Between(longitude - lotDegrees, longitude + lotDegrees),
      },
      order: { createdAt: 'DESC' },
      take: 50,
      relations: ['seller'],
    });

    return lots.map(lot => this.formatLotResponse(lot));
  }

  /**
   * Helper: Generate QR code (block hash)
   */
  private generateQRCode(sellerId: string, productName: string): string {
    const data = `${sellerId}-${productName}-${Date.now()}`;
    return crypto.createHash('sha256').update(data).digest('hex').substring(0, 12);
  }

  /**
   * Helper: Format lot response with seller info
   */
  private formatLotResponse(lot: Lot): LotResponseDto {
    return {
      id: lot.id,
      sellerId: lot.sellerId,
      sellerName: lot.seller?.firstName || 'Unknown',
      sellerRating: lot.seller?.trustScore || 0,
      productName: lot.productName,
      quantity: lot.quantity,
      quantityUnit: lot.quantityUnit,
      pricePerUnit: lot.pricePerUnit,
      description: lot.description,
      images: lot.images,
      pickupLocation: lot.pickupLocation,
      latitude: lot.latitude,
      longitude: lot.longitude,
      qrCode: lot.qrCode,
      status: lot.status,
      verifyStatus: lot.verifyStatus,
      certifications: lot.certifications,
      category: lot.category,
      viewCount: lot.viewCount,
      averageRating: lot.averageRating,
      ratingCount: lot.ratingCount,
      createdAt: lot.createdAt,
      updatedAt: lot.updatedAt,
    };
  }
}
