import { Injectable, BadRequestException, NotFoundException, ConflictException, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@typeorm/typeorm';
import { Repository } from 'typeorm';
import { v4 as uuid } from 'uuid';

import {
  CreatePaymentDto,
  UpdatePaymentStatusDto,
  VerifyPaymentDto,
  RefundPaymentDto,
  DisputePaymentDto,
  ProcessInstallmentDto,
  PaymentStatisticsQueryDto,
  CreateInvoiceDto,
  PaymentStatusEnum,
  PaymentMethodEnum,
  CurrencyEnum,
} from '../dto';
import { Payment } from '../entities/payment.entity';
import { Contract } from '../../contracts/entities/contract.entity';
import { ContractsService } from '../../contracts/services/contracts.service';

/**
 * PAYMENTS SERVICE
 * Core business logic for payment processing, escrow management, and settlement
 * Handles Flutterwave integration, late fee calculation, and transaction auditing
 */
@Injectable()
export class PaymentsService {
  constructor(
    @InjectRepository(Payment)
    private readonly paymentRepository: Repository<Payment>,
    @InjectRepository(Contract)
    private readonly contractRepository: Repository<Contract>,
    private readonly contractsService: ContractsService,
  ) {}

  /**
   * PUBLIC METHOD 1: createPayment
   * Creates a new payment record from contract
   * Generates invoice reference in format: INV-YYYY-XXXXXX
   *
   * @param dto CreatePaymentDto containing contractId, amount, currency, method
   * @param userId UUID of user creating the payment (buyer)
   * @returns Created payment object with reference
   * @throws NotFoundException if contract not found
   * @throws BadRequestException if contract status invalid for payment
   */
  async createPayment(dto: CreatePaymentDto, userId: string): Promise<Payment> {
    // Validate contract exists
    const contract = await this.contractRepository.findOne({
      where: { id: dto.contractId },
    });

    if (!contract) {
      throw new NotFoundException(`Contract ${dto.contractId} not found`);
    }

    if (contract.buyerId !== userId) {
      throw new UnauthorizedException('Only contract buyer can initiate payment');
    }

    // Check contract status allows payment
    if (contract.status !== 'SIGNED') {
      throw new BadRequestException(`Cannot pay contract with status: ${contract.status}`);
    }

    // Check currency matches contract
    if (contract.currency !== dto.currency) {
      throw new ConflictException('Payment currency must match contract currency');
    }

    // Check amount matches contract total
    if (Math.abs(contract.totalAmount - dto.amount) > 0.01) {
      // Allow 0.01 rounding difference
      throw new BadRequestException(`Payment amount ${dto.amount} does not match contract amount ${contract.totalAmount}`);
    }

    // Create payment entity
    const payment = new Payment();
    payment.id = uuid();
    payment.contractId = dto.contractId;
    payment.amount = dto.amount;
    payment.currency = dto.currency;
    payment.paymentMethod = dto.paymentMethod;
    payment.status = PaymentStatusEnum.PENDING;
    payment.invoiceReference = this.generateInvoiceReference();
    payment.createdBy = userId;
    payment.metadata = { paymentTerms: dto.paymentTerms };

    // Set due date based on payment method
    if (dto.paymentMethod === PaymentMethodEnum.ON_DELIVERY) {
      // No initial due date for on-delivery
      payment.dueDate = null;
    } else {
      // Other methods: due in 30 days
      const dueDate = new Date();
      dueDate.setDate(dueDate.getDate() + 30);
      payment.dueDate = dueDate;
    }

    // Save payment
    const savedPayment = await this.paymentRepository.save(payment);

    return savedPayment;
  }

  /**
   * PUBLIC METHOD 2: initiatePayment
   * Prepares payment for Flutterwave processing
   * Generates Flutterwave payment URL for mobile redirect
   *
   * @param paymentId UUID of payment to initiate
   * @param userId UUID of user (buyer) initiating
   * @returns Flutterwave payment URL for redirect
   * @throws NotFoundException if payment not found
   * @throws BadRequestException if payment already initiated
   */
  async initiatePayment(paymentId: string, userId: string): Promise<string> {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
      relations: ['contract'],
    });

    if (!payment) {
      throw new NotFoundException(`Payment ${paymentId} not found`);
    }

    if (payment.status !== PaymentStatusEnum.PENDING) {
      throw new BadRequestException(`Cannot initiate payment with status: ${payment.status}`);
    }

    // In production, call actual Flutterwave API
    // For now, generate test URL
    const flutterwavePaymentUrl = this.generateFlutterwavePaymentUrl(
      payment.id,
      payment.amount,
      payment.currency,
      payment.invoiceReference,
    );

    // Update payment status
    payment.status = PaymentStatusEnum.INITIATED;
    await this.paymentRepository.save(payment);

    return flutterwavePaymentUrl;
  }

  /**
   * PUBLIC METHOD 3: handleFlutterwaveWebhook
   * Processes incoming Flutterwave webhook for payment status updates
   * CRITICAL: Must be idempotent (handles duplicate webhooks)
   *
   * @param webhookData Flutterwave webhook payload
   * @returns Updated payment object
   * @throws BadRequestException if webhook signature invalid
   */
  async handleFlutterwaveWebhook(webhookData: any): Promise<Payment> {
    // Verify webhook signature (security critical)
    const isValid = this.verifyFlutterwaveSignature(webhookData);
    if (!isValid) {
      throw new BadRequestException('Invalid Flutterwave webhook signature');
    }

    // Extract transaction data
    const transactionId = webhookData.data?.id;
    const status = webhookData.data?.status; // e.g., 'successful', 'failed', 'pending'
    const amount = webhookData.data?.amount;
    const currency = webhookData.data?.currency;

    // Find payment by Flutterwave transaction or reference
    let payment = await this.paymentRepository.findOne({
      where: [
        { flutterwaveReference: transactionId },
        { invoiceReference: webhookData.data?.tx_ref },
      ],
    });

    if (!payment) {
      // Webhook for unknown payment (ignore or log)
      return null;
    }

    // IDEMPOTENCY: If payment already processed, return existing
    if (
      payment.status === PaymentStatusEnum.COMPLETED ||
      payment.status === PaymentStatusEnum.FAILED
    ) {
      return payment;
    }

    // Update payment status based on Flutterwave response
    const newStatus = this.mapFlutterwaveStatusToPaymentStatus(status);
    payment.status = newStatus;
    payment.flutterwaveReference = transactionId;
    payment.flutterwaveResponse = webhookData.data; // Store full response for audit

    // If successful, update completed timestamp
    if (newStatus === PaymentStatusEnum.COMPLETED) {
      payment.completedAt = new Date();
      payment.lateFeeAmount = 0; // Reset late fees for successful payment
    }

    // Save updated payment
    const updatedPayment = await this.paymentRepository.save(payment);

    // Log transaction for audit trail
    await this.logTransaction(updatedPayment.id, 'CHARGE', amount, transactionId, status);

    return updatedPayment;
  }

  /**
   * PUBLIC METHOD 4: processRefund
   * Handles refund requests (disputes, cancellations, returns)
   * Calls Flutterwave refund API to return funds to buyer
   *
   * @param paymentId UUID of payment to refund
   * @param reason Reason for refund
   * @param userId UUID of user requesting refund
   * @returns Updated payment with refund status
   */
  async processRefund(paymentId: string, reason: string, userId: string): Promise<Payment> {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
      relations: ['contract'],
    });

    if (!payment) {
      throw new NotFoundException(`Payment ${paymentId} not found`);
    }

    if (payment.status !== PaymentStatusEnum.COMPLETED) {
      throw new BadRequestException(`Can only refund completed payments, current status: ${payment.status}`);
    }

    // In production, call Flutterwave refund API
    // const refundResult = await flutterwaveClient.refund(payment.flutterwaveReference, payment.amount);

    // Update payment status
    payment.status = PaymentStatusEnum.REFUNDED;
    payment.metadata = {
      ...payment.metadata,
      refundedAt: new Date(),
      refundReason: reason,
      refundedBy: userId,
    };

    const updatedPayment = await this.paymentRepository.save(payment);

    // Log refund transaction
    await this.logTransaction(paymentId, 'REFUND', payment.amount, null, 'REFUNDED');

    return updatedPayment;
  }

  /**
   * PUBLIC METHOD 5: calculateLateFees
   * Calculates late fees for overdue payments
   * Rule: 2% fee per 10 days late
   *
   * @param paymentId UUID of payment to calculate fees for
   * @returns Calculated late fee amount
   */
  async calculateLateFees(paymentId: string): Promise<number> {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new NotFoundException(`Payment ${paymentId} not found`);
    }

    // Skip if payment completed or no due date
    if (payment.status === PaymentStatusEnum.COMPLETED || !payment.dueDate) {
      return 0;
    }

    // Check if overdue
    const today = new Date();
    if (today <= payment.dueDate) {
      return 0; // Not yet due
    }

    // Calculate days overdue
    const daysOverdue = Math.floor(
      (today.getTime() - payment.dueDate.getTime()) / (1000 * 60 * 60 * 24),
    );

    // Calculate fee: 2% per 10 days
    const feePeriods = Math.ceil(daysOverdue / 10);
    const lateFeeAmount = (payment.amount * 2 * feePeriods) / 100;

    // Update payment with fee
    payment.lateFeeAmount = lateFeeAmount;
    payment.lateFeeTriggeredAt = new Date();

    await this.paymentRepository.save(payment);

    return lateFeeAmount;
  }

  /**
   * PUBLIC METHOD 6: createEscrow
   * Delegates to EscrowService (separate service handles escrow logic)
   * Note: Escrow creation happens AFTER payment is completed
   */
  async createEscrow(paymentId: string, holdingPeriodDays: number) {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new NotFoundException(`Payment ${paymentId} not found`);
    }

    if (payment.status !== PaymentStatusEnum.COMPLETED) {
      throw new BadRequestException('Escrow can only be created for completed payments');
    }

    // Escrow creation delegated to EscrowService
    // return this.escrowService.createEscrow(paymentId, holdingPeriodDays);
  }

  /**
   * PUBLIC METHOD 7: getPaymentById
   * Retrieves single payment with all related data
   *
   * @param paymentId UUID of payment
   * @returns Payment object with relations loaded
   */
  async getPaymentById(paymentId: string): Promise<Payment> {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
      relations: ['contract'],
    });

    if (!payment) {
      throw new NotFoundException(`Payment ${paymentId} not found`);
    }

    return payment;
  }

  /**
   * PUBLIC METHOD 8: listPayments
   * Lists payments with filtering, sorting, and pagination
   *
   * @param filters Query filters (status, method, dates)
   * @param page Page number (0-indexed)
   * @param limit Results per page
   * @returns Paginated payment list
   */
  async listPayments(
    filters: PaymentStatisticsQueryDto,
    page: number = 0,
    limit: number = 10,
  ): Promise<{ data: Payment[]; total: number }> {
    let query = this.paymentRepository.createQueryBuilder('payment');

    // Apply filters
    if (filters.status) {
      query = query.where('payment.status = :status', { status: filters.status });
    }
    if (filters.paymentMethod) {
      query = query.andWhere('payment.paymentMethod = :method', {
        method: filters.paymentMethod,
      });
    }
    if (filters.startDate) {
      query = query.andWhere('payment.createdAt >= :startDate', {
        startDate: new Date(filters.startDate),
      });
    }
    if (filters.endDate) {
      query = query.andWhere('payment.createdAt <= :endDate', {
        endDate: new Date(filters.endDate),
      });
    }

    // Count total
    const total = await query.getCount();

    // Apply pagination and sort
    const data = await query
      .orderBy('payment.createdAt', 'DESC')
      .skip(page * limit)
      .take(limit)
      .getMany();

    return { data, total };
  }

  /**
   * PUBLIC METHOD 9: getTrackingHistory
   * Returns timeline of payment status changes
   */
  async getTrackingHistory(paymentId: string) {
    // Placeholder for audit log retrieval
    // In production, query AuditLog table
    return [];
  }

  /**
   * PUBLIC METHOD 10: getPaymentStatistics
   * Returns aggregated payment statistics for admin dashboards
   */
  async getPaymentStatistics(filters: PaymentStatisticsQueryDto) {
    let query = this.paymentRepository.createQueryBuilder('payment');

    // Apply same filters as listPayments
    if (filters.status) {
      query = query.where('payment.status = :status', { status: filters.status });
    }
    if (filters.paymentMethod) {
      query = query.andWhere('payment.paymentMethod = :method', {
        method: filters.paymentMethod,
      });
    }

    const stats = await query
      .select('COUNT(*)', 'count')
      .addSelect('SUM(payment.amount)', 'totalAmount')
      .addSelect('AVG(payment.amount)', 'avgAmount')
      .getRawOne();

    return stats || { count: 0, totalAmount: 0, avgAmount: 0 };
  }

  /**
   * PUBLIC METHOD 11: cancelPayment
   * Cancels pending or initiated payment
   */
  async cancelPayment(paymentId: string, reason: string, userId: string): Promise<Payment> {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new NotFoundException(`Payment ${paymentId} not found`);
    }

    if (![PaymentStatusEnum.PENDING, PaymentStatusEnum.INITIATED].includes(payment.status)) {
      throw new BadRequestException(`Cannot cancel payment with status: ${payment.status}`);
    }

    payment.status = PaymentStatusEnum.FAILED;
    payment.metadata = {
      ...payment.metadata,
      cancelledAt: new Date(),
      cancelReason: reason,
      cancelledBy: userId,
    };

    return this.paymentRepository.save(payment);
  }

  /**
   * PUBLIC METHOD 12: generateInvoice
   * Generates invoice PDF for payment
   */
  async generateInvoice(paymentId: string): Promise<Buffer> {
    const payment = await this.getPaymentById(paymentId);

    // In production, use library like PDFKit or puppeteer
    // For now, return placeholder
    return Buffer.from('Invoice PDF placeholder');
  }

  /**
   * PUBLIC METHOD 13: verifyPayment
   * Verifies a payment transaction with Flutterwave
   */
  async verifyPayment(dto: VerifyPaymentDto): Promise<Payment> {
    const payment = await this.paymentRepository.findOne({
      where: { invoiceReference: dto.flutterwaveTransactionId },
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    // Verify amount matches
    if (Math.abs(payment.amount - dto.amount) > 0.01) {
      throw new BadRequestException('Amount mismatch');
    }

    // Verify currency matches
    if (payment.currency !== dto.currency) {
      throw new BadRequestException('Currency mismatch');
    }

    return payment;
  }

  /**
   * PUBLIC METHOD 14: dispute Payment
   * Files a dispute for a payment (quality issues, non-delivery, etc.)
   */
  async disputePayment(paymentId: string, reason: string, userId: string): Promise<Payment> {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new NotFoundException(`Payment ${paymentId} not found`);
    }

    if (payment.status !== PaymentStatusEnum.COMPLETED) {
      throw new BadRequestException('Can only dispute completed payments');
    }

    payment.status = PaymentStatusEnum.DISPUTED;
    payment.metadata = {
      ...payment.metadata,
      disputedAt: new Date(),
      disputeReason: reason,
      disputedBy: userId,
    };

    return this.paymentRepository.save(payment);
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /**
   * Generates invoice reference in format: INV-YYYY-XXXXXX
   * Example: INV-2026-001001
   */
  private generateInvoiceReference(): string {
    const year = new Date().getFullYear();
    const randomSuffix = Math.floor(Math.random() * 1000000)
      .toString()
      .padStart(6, '0');
    return `INV-${year}-${randomSuffix}`;
  }

  /**
   * Generates Flutterwave payment URL for mobile redirect
   * In production, creates actual Flutterwave payment link via API
   */
  private generateFlutterwavePaymentUrl(
    paymentId: string,
    amount: number,
    currency: string,
    reference: string,
  ): string {
    // Placeholder URL - in production, call Flutterwave API
    return `https://checkout.flutterwave.com/pay/${reference}`;
  }

  /**
   * Verifies Flutterwave webhook signature for security
   * Uses HMAC-SHA256 with Flutterwave secret key
   */
  private verifyFlutterwaveSignature(webhookData: any): boolean {
    // In production, verify HMAC signature
    // const crypto = require('crypto');
    // const secret = process.env.FLUTTERWAVE_SECRET_KEY;
    // const hash = crypto.createHmac('sha256', secret).update(JSON.stringify(webhookData)).digest('hex');
    // return hash === webhookData.signature

    // For development/testing, accept all
    return true;
  }

  /**
   * Maps Flutterwave status to internal payment status enum
   */
  private mapFlutterwaveStatusToPaymentStatus(flutterwaveStatus: string): PaymentStatusEnum {
    const statusMap = {
      successful: PaymentStatusEnum.COMPLETED,
      pending: PaymentStatusEnum.PROCESSING,
      failed: PaymentStatusEnum.FAILED,
    };

    return statusMap[flutterwaveStatus] || PaymentStatusEnum.FAILED;
  }

  /**
   * Logs transaction for audit trail
   */
  private async logTransaction(
    paymentId: string,
    transactionType: string,
    amount: number,
    flutterwaveId: string,
    status: string,
  ) {
    // In production, insert into PaymentTransactionLog table
    // await this.transactionLogRepository.save({
    //   id: uuid(),
    //   paymentId,
    //   transactionType,
    //   amount,
    //   flutterwaveTransactionId: flutterwaveId,
    //   status,
    //   createdAt: new Date(),
    // });
  }
}
