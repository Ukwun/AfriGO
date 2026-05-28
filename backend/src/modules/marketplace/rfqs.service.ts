import { Injectable, BadRequestException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan, MoreThan, Like } from 'typeorm';
import { RFQ } from './rfq.entity';
import { RFQBid } from './rfq-bid.entity';
import { CreateRFQDTO, SubmitBidDTO, RFQFilterDTO, AwardBidDTO } from './rfq.dto';
import { User } from '../auth/user.entity';

@Injectable()
export class RFQsService {
  constructor(
    @InjectRepository(RFQ) private rfqRepository: Repository<RFQ>,
    @InjectRepository(RFQBid) private bidRepository: Repository<RFQBid>,
    @InjectRepository(User) private userRepository: Repository<User>,
  ) {}

  /**
   * Create new RFQ (buyer functionality)
   */
  async createRFQ(dto: CreateRFQDTO, buyerId: string): Promise<RFQ> {
    // Fetch buyer info for company name
    const buyer = await this.userRepository.findOne({ where: { id: buyerId } });
    if (!buyer) {
      throw new NotFoundException('Buyer not found');
    }

    // Validate deadline is in future
    const deadline = new Date(dto.deliveryDeadline);
    if (deadline <= new Date()) {
      throw new BadRequestException('Delivery deadline must be in the future');
    }

    // Calculate expiration (30 days from now)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30);

    // Create RFQ
    const rfq = this.rfqRepository.create({
      buyerId,
      buyerCompanyName: buyer.companyName || buyer.firstName,
      productCategory: dto.productCategory,
      productDescription: dto.productDescription,
      description: dto.description,
      quantity: dto.quantity,
      quantityUnit: dto.quantityUnit,
      originCountryPreference: dto.originCountryPreference,
      gradePreference: dto.gradePreference,
      deliveryLocation: dto.deliveryLocation,
      deliveryDeadline: deadline,
      paymentTerms: dto.paymentTerms,
      maxBidsExpected: dto.maxBidsExpected,
      status: 'open',
      expiresAt,
      submittedBids: [],
    });

    return this.rfqRepository.save(rfq);
  }

  /**
   * List all open RFQs (public, for suppliers to see)
   */
  async listOpenRFQs(filters: RFQFilterDTO): Promise<{ data: RFQ[]; total: number }> {
    const { status = 'open', category, searchTerm, page = 1, limit = 20 } = filters;

    const query = this.rfqRepository
      .createQueryBuilder('rfq')
      .leftJoinAndSelect('rfq.submittedBids', 'bids')
      .leftJoinAndSelect('rfq.buyer', 'buyer')
      .where('rfq.status = :status', { status })
      .andWhere('rfq.expiresAt > :now', { now: new Date() });

    if (category) {
      query.andWhere('rfq.productCategory = :category', { category });
    }

    if (searchTerm) {
      query.andWhere(
        '(rfq.productDescription ILIKE :search OR rfq.productCategory ILIKE :search)',
        { search: `%${searchTerm}%` },
      );
    }

    // Count total
    const total = await query.getCount();

    // Paginate
    const data = await query
      .orderBy('rfq.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    return { data, total };
  }

  /**
   * Get RFQ details by ID
   */
  async getRFQById(rfqId: string): Promise<RFQ> {
    const rfq = await this.rfqRepository.findOne({
      where: { id: rfqId },
      relations: ['submittedBids', 'buyer', 'selectedSupplier'],
    });

    if (!rfq) {
      throw new NotFoundException('RFQ not found');
    }

    return rfq;
  }

  /**
   * Get all RFQs created by buyer
   */
  async getBuyerRFQs(buyerId: string, filters: RFQFilterDTO): Promise<{ data: RFQ[]; total: number }> {
    const { status, page = 1, limit = 20 } = filters;

    const query = this.rfqRepository
      .createQueryBuilder('rfq')
      .leftJoinAndSelect('rfq.submittedBids', 'bids')
      .where('rfq.buyerId = :buyerId', { buyerId });

    if (status) {
      query.andWhere('rfq.status = :status', { status });
    }

    const total = await query.getCount();

    const data = await query
      .orderBy('rfq.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    return { data, total };
  }

  /**
   * Get all bids submitted by supplier
   */
  async getSupplierBids(supplierId: string, filters: RFQFilterDTO): Promise<{ data: RFQBid[]; total: number }> {
    const { status, page = 1, limit = 20 } = filters;

    const query = this.bidRepository
      .createQueryBuilder('bid')
      .leftJoinAndSelect('bid.rfq', 'rfq')
      .leftJoinAndSelect('bid.supplier', 'supplier')
      .where('bid.supplierId = :supplierId', { supplierId });

    if (status) {
      query.andWhere('bid.status = :status', { status });
    }

    const total = await query.getCount();

    const data = await query
      .orderBy('bid.submittedAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    return { data, total };
  }

  /**
   * Get all bids for specific RFQ (buyer only)
   */
  async getRFQBids(rfqId: string, buyerId: string): Promise<RFQBid[]> {
    // Verify buyer owns the RFQ
    const rfq = await this.getRFQById(rfqId);
    if (rfq.buyerId !== buyerId) {
      throw new ForbiddenException('Only RFQ creator can view bids');
    }

    return this.bidRepository.find({
      where: { rfqId },
      relations: ['supplier'],
      order: { submittedAt: 'DESC' },
    });
  }

  /**
   * Submit bid for RFQ (supplier only)
   */
  async submitBid(dto: SubmitBidDTO, supplierId: string): Promise<RFQBid> {
    // Verify RFQ exists and is still open
    const rfq = await this.getRFQById(dto.rfqId);

    if (rfq.status !== 'open') {
      throw new BadRequestException('RFQ is no longer open for bids');
    }

    if (rfq.expiresAt <= new Date()) {
      throw new BadRequestException('RFQ has expired');
    }

    // Check if supplier already bid
    const existingBid = await this.bidRepository.findOne({
      where: { rfqId: dto.rfqId, supplierId },
    });

    if (existingBid) {
      throw new BadRequestException('You have already submitted a bid for this RFQ');
    }

    // Get supplier info
    const supplier = await this.userRepository.findOne({ where: { id: supplierId } });
    if (!supplier) {
      throw new NotFoundException('Supplier not found');
    }

    // Calculate total price
    const totalPrice = dto.pricePerUnit * rfq.quantity;

    // Validate estimated delivery is after RFQ deadline
    const estimatedDelivery = new Date(dto.estimatedDelivery);
    if (estimatedDelivery < rfq.deliveryDeadline) {
      throw new BadRequestException('Estimated delivery must be after or on RFQ deadline');
    }

    // Create bid
    const bid = this.bidRepository.create({
      rfqId: dto.rfqId,
      supplierId,
      supplierCompanyName: supplier.companyName || supplier.firstName,
      pricePerUnit: dto.pricePerUnit,
      totalPrice,
      originCountry: dto.originCountry,
      gradeLevel: dto.gradeLevel,
      estimatedDelivery,
      paymentMethod: dto.paymentMethod,
      specialTerms: dto.specialTerms,
      certificationsIncluded: dto.certificationsIncluded,
      status: 'pending',
    });

    return this.bidRepository.save(bid);
  }

  /**
   * Award bid to supplier (buyer only) - triggers contract creation
   */
  async awardBid(rfqId: string, dto: AwardBidDTO, buyerId: string): Promise<RFQ> {
    // Verify buyer owns the RFQ
    const rfq = await this.getRFQById(rfqId);
    if (rfq.buyerId !== buyerId) {
      throw new ForbiddenException('Only RFQ creator can award bids');
    }

    // Get the bid
    const bid = await this.bidRepository.findOne({
      where: { id: dto.bidId, rfqId },
      relations: ['supplier'],
    });

    if (!bid) {
      throw new NotFoundException('Bid not found');
    }

    // Update RFQ status
    rfq.status = 'awarded';
    rfq.selectedSupplierId = bid.supplierId;
    rfq.selectedSupplierBidId = bid.id;

    // Update bid status
    bid.status = 'awarded';

    // Reject all other bids
    const otherBids = await this.bidRepository.find({
      where: { rfqId },
    });
    for (const otherBid of otherBids) {
      if (otherBid.id !== dto.bidId) {
        otherBid.status = 'rejected';
        await this.bidRepository.save(otherBid);
      }
    }

    await this.bidRepository.save(bid);
    return this.rfqRepository.save(rfq);
  }

  /**
   * Close RFQ (buyer only)
   */
  async closeRFQ(rfqId: string, buyerId: string): Promise<RFQ> {
    const rfq = await this.getRFQById(rfqId);

    if (rfq.buyerId !== buyerId) {
      throw new ForbiddenException('Only RFQ creator can close it');
    }

    rfq.status = 'closed';
    return this.rfqRepository.save(rfq);
  }

  /**
   * Get bid statistics for RFQ
   */
  async getRFQStats(rfqId: string): Promise<{
    totalBids: number;
    averagePrice: number;
    minPrice: number;
    maxPrice: number;
  }> {
    const bids = await this.bidRepository.find({
      where: { rfqId, status: 'pending' },
    });

    if (bids.length === 0) {
      return {
        totalBids: 0,
        averagePrice: 0,
        minPrice: 0,
        maxPrice: 0,
      };
    }

    const prices = bids.map((b) => b.totalPrice);
    const sum = prices.reduce((a, b) => a + b, 0);

    return {
      totalBids: bids.length,
      averagePrice: sum / bids.length,
      minPrice: Math.min(...prices),
      maxPrice: Math.max(...prices),
    };
  }

  /**
   * Get recommended suppliers for RFQ (ML model would go here)
   */
  async getRecommendedSuppliers(rfqId: string, limit: number = 5): Promise<any[]> {
    const rfq = await this.getRFQById(rfqId);

    // Simple logic: find suppliers with products matching category and grade
    // In production: use ML model to rank by trust score, fulfillment rate, etc.
    return [];
  }
}
