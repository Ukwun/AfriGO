import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan, LessThan } from 'typeorm';
import { Order } from './entities/order.entity';
import { Quote } from './entities/quote.entity';
import { Lot } from '../lots/entities/lot.entity';
import { User } from '../users/entities/user.entity';
import {
  CreateOrderDto,
  UpdateOrderDto,
  OrderResponseDto,
  OrderSearchQueryDto,
} from './dtos/order.dto';
import {
  CreateQuoteDto,
  CounterQuoteDto,
  AcceptQuoteDto,
  RejectQuoteDto,
  QuoteResponseDto,
  QuoteSearchQueryDto,
} from './dtos/quote.dto';

@Injectable()
export class TradingService {
  constructor(
    @InjectRepository(Order)
    private readonly ordersRepository: Repository<Order>,
    @InjectRepository(Quote)
    private readonly quotesRepository: Repository<Quote>,
    @InjectRepository(Lot)
    private readonly lotsRepository: Repository<Lot>,
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
  ) {}

  // ============ ORDER METHODS ============

  /**
   * Create a new order (buyer requests lot)
   */
  async createOrder(buyerId: string, createOrderDto: CreateOrderDto): Promise<Order> {
    // Validate lot exists and is available
    const lot = await this.lotsRepository.findOne({
      where: { id: createOrderDto.lotId },
    });

    if (!lot) {
      throw new NotFoundException('Lot not found');
    }

    if (lot.deletedAt) {
      throw new BadRequestException('Lot is no longer available');
    }

    // Validate buyer is not the seller
    if (lot.sellerId === buyerId) {
      throw new BadRequestException('Cannot create order for your own lot');
    }

    // Validate quantity
    if (createOrderDto.quantity <= 0) {
      throw new BadRequestException('Quantity must be greater than 0');
    }

    if (createOrderDto.quantity > lot.availableQuantity) {
      throw new BadRequestException(
        `Only ${lot.availableQuantity} units available`,
      );
    }

    // Create order
    const order = new Order();
    order.lotId = createOrderDto.lotId;
    order.buyerId = buyerId;
    order.sellerId = lot.sellerId;
    order.quantity = createOrderDto.quantity;
    order.quantityUnit = createOrderDto.quantityUnit;
    order.pricePerUnit = lot.price;
    order.totalPrice = createOrderDto.quantity * lot.price;
    order.status = 'pending';
    order.paymentStatus = 'not_paid';

    const savedOrder = await this.ordersRepository.save(order);

    // Return with relations
    return this.getOrderById(savedOrder.id, buyerId);
  }

  /**
   * Get all orders for a buyer
   */
  async getOrdersByBuyer(
    buyerId: string,
    query: OrderSearchQueryDto,
  ): Promise<{ data: Order[]; total: number }> {
    const skip = query.skip || 0;
    const take = query.take || 20;

    const queryBuilder = this.ordersRepository
      .createQueryBuilder('order')
      .where('order.buyerId = :buyerId', { buyerId })
      .leftJoinAndSelect('order.lot', 'lot')
      .leftJoinAndSelect('order.seller', 'seller')
      .leftJoinAndSelect('order.buyer', 'buyer');

    // Apply filters
    if (query.statusEnum) {
      queryBuilder.andWhere('order.status = :status', {
        status: query.statusEnum,
      });
    }

    // Apply sorting
    const sortBy = query.sortBy || 'createdAt';
    const order = query.order || 'DESC';
    queryBuilder.orderBy(`order.${sortBy}`, order as 'ASC' | 'DESC');

    // Pagination
    queryBuilder.skip(skip).take(take);

    const [data, total] = await queryBuilder.getManyAndCount();
    return { data, total };
  }

  /**
   * Get all orders for a seller
   */
  async getOrdersBySeller(
    sellerId: string,
    query: OrderSearchQueryDto,
  ): Promise<{ data: Order[]; total: number }> {
    const skip = query.skip || 0;
    const take = query.take || 20;

    const queryBuilder = this.ordersRepository
      .createQueryBuilder('order')
      .where('order.sellerId = :sellerId', { sellerId })
      .leftJoinAndSelect('order.lot', 'lot')
      .leftJoinAndSelect('order.buyer', 'buyer')
      .leftJoinAndSelect('order.seller', 'seller');

    // Apply filters
    if (query.statusEnum) {
      queryBuilder.andWhere('order.status = :status', {
        status: query.statusEnum,
      });
    }

    // Apply sorting
    const sortBy = query.sortBy || 'createdAt';
    const order = query.order || 'DESC';
    queryBuilder.orderBy(`order.${sortBy}`, order as 'ASC' | 'DESC');

    // Pagination
    queryBuilder.skip(skip).take(take);

    const [data, total] = await queryBuilder.getManyAndCount();
    return { data, total };
  }

  /**
   * Get a specific order by ID
   */
  async getOrderById(orderId: string, userId: string): Promise<Order> {
    const order = await this.ordersRepository.findOne({
      where: { id: orderId },
      relations: ['lot', 'seller', 'buyer'],
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    // Authorization: only buyer or seller can view
    if (order.buyerId !== userId && order.sellerId !== userId) {
      throw new ForbiddenException('Cannot access this order');
    }

    return order;
  }

  /**
   * Confirm an order (buyer confirms intention to purchase)
   */
  async confirmOrder(orderId: string, buyerId: string): Promise<Order> {
    const order = await this.ordersRepository.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.buyerId !== buyerId) {
      throw new ForbiddenException('Only buyer can confirm order');
    }

    if (order.status !== 'pending' && order.status !== 'quoted') {
      throw new BadRequestException(
        `Cannot confirm order in ${order.status} status`,
      );
    }

    order.status = 'confirmed';
    order.confirmedAt = new Date();

    return this.ordersRepository.save(order);
  }

  /**
   * Cancel an order
   */
  async cancelOrder(
    orderId: string,
    userId: string,
    reason?: string,
  ): Promise<Order> {
    const order = await this.ordersRepository.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.buyerId !== userId && order.sellerId !== userId) {
      throw new ForbiddenException('Cannot cancel this order');
    }

    // Can only cancel if not already shipped/delivered
    if (
      ['shipped', 'delivered', 'completed', 'disputed'].includes(order.status)
    ) {
      throw new BadRequestException(
        `Cannot cancel order in ${order.status} status`,
      );
    }

    order.status = 'cancelled';
    return this.ordersRepository.save(order);
  }

  /**
   * Mark order as shipped
   */
  async shipOrder(orderId: string, sellerId: string): Promise<Order> {
    const order = await this.ordersRepository.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.sellerId !== sellerId) {
      throw new ForbiddenException('Only seller can ship order');
    }

    if (order.status !== 'confirmed' && order.status !== 'paid') {
      throw new BadRequestException(
        `Cannot ship order in ${order.status} status`,
      );
    }

    order.status = 'shipped';
    order.shippedAt = new Date();

    return this.ordersRepository.save(order);
  }

  /**
   * Mark order as delivered and allow buyer to rate
   */
  async deliverOrder(orderId: string, buyerId: string): Promise<Order> {
    const order = await this.ordersRepository.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.buyerId !== buyerId) {
      throw new ForbiddenException('Only buyer can confirm delivery');
    }

    if (order.status !== 'shipped') {
      throw new BadRequestException(
        `Cannot deliver order in ${order.status} status`,
      );
    }

    order.status = 'delivered';
    order.deliveredAt = new Date();

    return this.ordersRepository.save(order);
  }

  /**
   * Complete an order (after delivery and rating)
   */
  async completeOrder(orderId: string, userId: string): Promise<Order> {
    const order = await this.ordersRepository.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.buyerId !== userId && order.sellerId !== userId) {
      throw new ForbiddenException('Cannot complete this order');
    }

    if (order.status !== 'delivered') {
      throw new BadRequestException(
        `Cannot complete order in ${order.status} status`,
      );
    }

    order.status = 'completed';
    order.completedAt = new Date();

    return this.ordersRepository.save(order);
  }

  /**
   * Rate and review after order completion
   */
  async rateOrder(
    orderId: string,
    userId: string,
    rating: number,
    review: string,
  ): Promise<Order> {
    const order = await this.ordersRepository.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.status !== 'delivered' && order.status !== 'completed') {
      throw new BadRequestException(
        'Can only rate delivered or completed orders',
      );
    }

    // Validate rating
    if (rating < 1 || rating > 5) {
      throw new BadRequestException('Rating must be between 1 and 5');
    }

    // Buyer rates seller
    if (order.buyerId === userId) {
      order.sellerRating = rating;
      order.sellerReview = review;
    }
    // Seller rates buyer
    else if (order.sellerId === userId) {
      order.buyerRating = rating;
      order.buyerReview = review;
    } else {
      throw new ForbiddenException('Cannot rate this order');
    }

    return this.ordersRepository.save(order);
  }

  // ============ QUOTE METHODS ============

  /**
   * Create a quote (seller quotes to buyer)
   */
  async createQuote(
    sellerId: string,
    createQuoteDto: CreateQuoteDto,
  ): Promise<Quote> {
    // Get order
    const order = await this.ordersRepository.findOne({
      where: { id: createQuoteDto.orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.sellerId !== sellerId) {
      throw new ForbiddenException('Only seller can create quote');
    }

    if (order.status !== 'pending' && order.status !== 'quoted') {
      throw new BadRequestException(
        `Cannot quote order in ${order.status} status`,
      );
    }

    // Create quote
    const quote = new Quote();
    quote.orderId = createQuoteDto.orderId;
    quote.lotId = order.lotId;
    quote.fromUserId = sellerId;
    quote.toUserId = order.buyerId;
    quote.quoteType = 'seller_quote';
    quote.quotedPrice = createQuoteDto.quotedPrice;
    quote.quotedQuantity = createQuoteDto.quotedQuantity;
    quote.quantityUnit = createQuoteDto.quantityUnit;
    quote.termsAndConditions = createQuoteDto.termsAndConditions;
    quote.notes = createQuoteDto.notes;
    quote.deliveryLocation = createQuoteDto.deliveryLocation;
    quote.proposedDeliveryDate = createQuoteDto.proposedDeliveryDate;
    quote.status = 'pending';
    quote.expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days

    const savedQuote = await this.quotesRepository.save(quote);

    // Update order status
    order.status = 'quoted';
    await this.ordersRepository.save(order);

    return this.getQuoteById(savedQuote.id, order.buyerId);
  }

  /**
   * Get quotes for an order
   */
  async getQuotesByOrderId(
    orderId: string,
    userId: string,
  ): Promise<{ data: Quote[]; total: number }> {
    // Verify user has access to this order
    const order = await this.ordersRepository.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.buyerId !== userId && order.sellerId !== userId) {
      throw new ForbiddenException('Cannot access this order');
    }

    const [data, total] = await this.quotesRepository.findAndCount({
      where: { orderId },
      relations: ['fromUser', 'toUser'],
      order: { createdAt: 'DESC' },
    });

    return { data, total };
  }

  /**
   * Get quotes received by the user
   */
  async getReceivedQuotes(
    userId: string,
    query: QuoteSearchQueryDto,
  ): Promise<{ data: Quote[]; total: number }> {
    const skip = query.skip || 0;
    const take = query.take || 20;

    const queryBuilder = this.quotesRepository
      .createQueryBuilder('quote')
      .where('quote.toUserId = :userId', { userId })
      .leftJoinAndSelect('quote.fromUser', 'fromUser')
      .leftJoinAndSelect('quote.order', 'order');

    // Apply filters
    if (query.status) {
      queryBuilder.andWhere('quote.status = :status', {
        status: query.status,
      });
    }

    // Apply sorting
    const sortBy = query.sortBy || 'createdAt';
    const order = query.order || 'DESC';
    queryBuilder.orderBy(`quote.${sortBy}`, order as 'ASC' | 'DESC');

    // Pagination
    queryBuilder.skip(skip).take(take);

    const [data, total] = await queryBuilder.getManyAndCount();
    return { data, total };
  }

  /**
   * Get quotes sent by the user
   */
  async getSentQuotes(
    userId: string,
    query: QuoteSearchQueryDto,
  ): Promise<{ data: Quote[]; total: number }> {
    const skip = query.skip || 0;
    const take = query.take || 20;

    const queryBuilder = this.quotesRepository
      .createQueryBuilder('quote')
      .where('quote.fromUserId = :userId', { userId })
      .leftJoinAndSelect('quote.toUser', 'toUser')
      .leftJoinAndSelect('quote.order', 'order');

    // Apply filters
    if (query.status) {
      queryBuilder.andWhere('quote.status = :status', {
        status: query.status,
      });
    }

    // Apply sorting
    const sortBy = query.sortBy || 'createdAt';
    const order = query.order || 'DESC';
    queryBuilder.orderBy(`quote.${sortBy}`, order as 'ASC' | 'DESC');

    // Pagination
    queryBuilder.skip(skip).take(take);

    const [data, total] = await queryBuilder.getManyAndCount();
    return { data, total };
  }

  /**
   * Get a specific quote by ID
   */
  async getQuoteById(quoteId: string, userId: string): Promise<Quote> {
    const quote = await this.quotesRepository.findOne({
      where: { id: quoteId },
      relations: ['fromUser', 'toUser', 'order'],
    });

    if (!quote) {
      throw new NotFoundException('Quote not found');
    }

    // Authorization: only sender or receiver can view
    if (quote.fromUserId !== userId && quote.toUserId !== userId) {
      throw new ForbiddenException('Cannot access this quote');
    }

    return quote;
  }

  /**
   * Accept a quote
   */
  async acceptQuote(quoteId: string, userId: string): Promise<Quote> {
    const quote = await this.quotesRepository.findOne({
      where: { id: quoteId },
    });

    if (!quote) {
      throw new NotFoundException('Quote not found');
    }

    if (quote.toUserId !== userId) {
      throw new ForbiddenException('Only recipient can accept quote');
    }

    if (quote.status !== 'pending') {
      throw new BadRequestException(
        `Cannot accept quote in ${quote.status} status`,
      );
    }

    // Check if expired
    if (quote.expiresAt < new Date()) {
      quote.status = 'expired';
      quote.isExpired = true;
      await this.quotesRepository.save(quote);
      throw new BadRequestException('Quote has expired');
    }

    quote.status = 'accepted';
    quote.acceptedAt = new Date();
    const savedQuote = await this.quotesRepository.save(quote);

    // Update order status and pricing
    const order = await this.ordersRepository.findOne({
      where: { id: quote.orderId },
    });
    if (order) {
      order.status = 'confirmed';
      order.pricePerUnit = quote.quotedPrice;
      order.totalPrice = quote.quotedPrice * quote.quotedQuantity;
      order.quantity = quote.quotedQuantity;
      order.confirmedAt = new Date();
      await this.ordersRepository.save(order);
    }

    return this.getQuoteById(savedQuote.id, userId);
  }

  /**
   * Reject a quote
   */
  async rejectQuote(
    quoteId: string,
    userId: string,
    rejectDto: RejectQuoteDto,
  ): Promise<Quote> {
    const quote = await this.quotesRepository.findOne({
      where: { id: quoteId },
    });

    if (!quote) {
      throw new NotFoundException('Quote not found');
    }

    if (quote.toUserId !== userId) {
      throw new ForbiddenException('Only recipient can reject quote');
    }

    if (quote.status !== 'pending') {
      throw new BadRequestException(
        `Cannot reject quote in ${quote.status} status`,
      );
    }

    quote.status = 'rejected';
    quote.rejectedAt = new Date();
    quote.rejectionReason = rejectDto.rejectionReason;

    return this.quotesRepository.save(quote);
  }

  /**
   * Submit a counter quote
   */
  async submitCounterQuote(
    quoteId: string,
    userId: string,
    counterDto: CounterQuoteDto,
  ): Promise<Quote> {
    // Get original quote
    const originalQuote = await this.quotesRepository.findOne({
      where: { id: quoteId },
    });

    if (!originalQuote) {
      throw new NotFoundException('Quote not found');
    }

    if (originalQuote.toUserId !== userId) {
      throw new ForbiddenException('Only recipient can counter quote');
    }

    if (originalQuote.status !== 'pending') {
      throw new BadRequestException(
        `Cannot counter quote in ${originalQuote.status} status`,
      );
    }

    // Create counter quote
    const counterQuote = new Quote();
    counterQuote.orderId = originalQuote.orderId;
    counterQuote.lotId = originalQuote.lotId;
    counterQuote.fromUserId = userId; // Buyer is now the one quoting back
    counterQuote.toUserId = originalQuote.fromUserId; // Quote goes to seller
    counterQuote.quoteType = 'buyer_counter_offer';
    counterQuote.quotedPrice = counterDto.quotedPrice;
    counterQuote.quotedQuantity = counterDto.quotedQuantity;
    counterQuote.quantityUnit = counterDto.quantityUnit;
    counterQuote.termsAndConditions = counterDto.termsAndConditions;
    counterQuote.notes = counterDto.notes;
    counterQuote.deliveryLocation = counterDto.deliveryLocation;
    counterQuote.proposedDeliveryDate = counterDto.proposedDeliveryDate;
    counterQuote.counterQuoteId = quoteId; // Link to original
    counterQuote.status = 'pending';
    counterQuote.expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);

    const savedCounterQuote = await this.quotesRepository.save(counterQuote);

    // Update original quote status
    originalQuote.status = 'countered';
    await this.quotesRepository.save(originalQuote);

    // Update order status
    const order = await this.ordersRepository.findOne({
      where: { id: originalQuote.orderId },
    });
    if (order) {
      order.status = 'negotiating';
      await this.ordersRepository.save(order);
    }

    return this.getQuoteById(savedCounterQuote.id, userId);
  }

  /**
   * Clean up expired quotes (can be called by cron job)
   */
  async expireQuotes(): Promise<number> {
    const result = await this.quotesRepository.update(
      {
        expiresAt: LessThan(new Date()),
        status: 'pending',
      },
      {
        status: 'expired',
        isExpired: true,
      },
    );

    return result.affected || 0;
  }
}
