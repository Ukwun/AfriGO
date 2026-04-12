import {
  Injectable,
  BadRequestException,
  NotFoundException,
  ForbiddenException,
  InternalServerErrorException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import Stripe from 'stripe';
import { Payment } from './entities/payment.entity';
import { Order } from '../trading/entities/order.entity';
import { User } from '../auth/entities/user.entity';
import {
  CreatePaymentDto,
  ConfirmPaymentDto,
  RefundPaymentDto,
  PaymentResponseDto,
} from './dtos/payment.dto';

@Injectable()
export class PaymentsService {
  private stripe: Stripe;
  private stripePublishableKey: string;

  constructor(
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,
    @InjectRepository(Order)
    private orderRepository: Repository<Order>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private configService: ConfigService,
  ) {
    this.stripe = new Stripe(this.configService.get('STRIPE_SECRET_KEY'), {
      apiVersion: '2022-11-15',
    });
    this.stripePublishableKey = this.configService.get('STRIPE_PUBLISHABLE_KEY');
  }

  /**
   * Get Stripe publishable key for frontend
   */
  getPublishableKey(): string {
    return this.stripePublishableKey;
  }

  /**
   * Create a payment (initialize PaymentIntent with Stripe)
   */
  async createPayment(
    userId: string,
    createPaymentDto: CreatePaymentDto,
  ): Promise<PaymentResponseDto> {
    const { orderId, amount, currency, paymentMethodId, description } =
      createPaymentDto;

    // Validate order exists and user is buyer
    const order = await this.orderRepository.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    if (order.buyerId !== userId) {
      throw new ForbiddenException('Only buyer can pay for this order');
    }

    if (order.status !== 'pending' && order.status !== 'confirmed') {
      throw new BadRequestException('Cannot pay for order in this status');
    }

    // Check if payment already exists for this order
    const existingPayment = await this.paymentRepository.findOne({
      where: {
        orderId,
        status: 'succeeded',
      },
    });

    if (existingPayment) {
      throw new BadRequestException('Order already paid');
    }

    try {
      // Create Stripe PaymentIntent
      const paymentIntent = await this.stripe.paymentIntents.create({
        amount: Math.round(amount * 100), // Convert to cents
        currency: currency.toLowerCase(),
        payment_method: paymentMethodId,
        confirm: true, // Auto-confirm payment
        automatic_payment_methods: {
          enabled: true,
          allow_redirects: 'never',
        },
        metadata: {
          orderId,
          userId,
          description: 'AfriGo Payment',
        },
      });

      // Create payment record
      const payment = this.paymentRepository.create({
        orderId,
        userId,
        amount,
        currency: currency.toUpperCase(),
        paymentMethod: paymentIntent.payment_method
          ? 'payment_intent'
          : 'unknown',
        status: this._mapStripeStatusToPaymentStatus(
          paymentIntent.status,
        ),
        stripePaymentIntentId: paymentIntent.id,
        stripeChargeId: paymentIntent.charges.data[0]?.id || null,
        escrowStatus: 'pending',
        description,
        // Extract card info if available
        cardInfo: paymentIntent.charges.data[0]?.payment_method_details
          ? this._extractCardInfo(
              paymentIntent.charges.data[0].payment_method_details,
            )
          : null,
      });

      // Update payment timestamps
      if (paymentIntent.status === 'succeeded') {
        payment.paidAt = new Date();
        // Calculate fees and seller payout (2% platform fee)
        payment.platformFee = amount * 0.02;
        payment.sellerPayout = amount - payment.platformFee;
        payment.escrowStatus = 'held';
      } else if (paymentIntent.status === 'requires_payment_method') {
        payment.failureReason = 'Payment method requires additional handling';
      }

      const savedPayment = await this.paymentRepository.save(payment);

      // Update order status if payment succeeded
      if (paymentIntent.status === 'succeeded') {
        await this.orderRepository.update(
          { id: orderId },
          { status: 'confirmed', paymentStatus: 'paid' },
        );
      }

      return this._formatPaymentResponse(savedPayment);
    } catch (error) {
      if (error instanceof Stripe.errors.StripeError) {
        throw new BadRequestException(`Payment failed: ${error.message}`);
      }
      throw new InternalServerErrorException('Payment processing error');
    }
  }

  /**
   * Confirm payment (for 3D Secure or additional authentication)
   */
  async confirmPayment(
    userId: string,
    paymentId: string,
    confirmPaymentDto: ConfirmPaymentDto,
  ): Promise<PaymentResponseDto> {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    if (payment.userId !== userId) {
      throw new ForbiddenException('Not authorized for this payment');
    }

    try {
      const paymentIntent = await this.stripe.paymentIntents.confirm(
        confirmPaymentDto.paymentIntentId,
        {
          payment_method: confirmPaymentDto.paymentMethodId,
        },
      );

      payment.status = this._mapStripeStatusToPaymentStatus(
        paymentIntent.status,
      );

      if (paymentIntent.status === 'succeeded') {
        payment.paidAt = new Date();
        payment.stripeChargeId =
          paymentIntent.charges.data[0]?.id || null;
        payment.escrowStatus = 'held';

        // Update order
        await this.orderRepository.update(
          { id: payment.orderId },
          { status: 'confirmed', paymentStatus: 'paid' },
        );
      } else if (paymentIntent.status === 'requires_action') {
        payment.failureReason =
          'Additional authentication required (3D Secure)';
      }

      const updated = await this.paymentRepository.save(payment);
      return this._formatPaymentResponse(updated);
    } catch (error) {
      throw new BadRequestException(`Payment confirmation failed: ${error.message}`);
    }
  }

  /**
   * Get payment by ID
   */
  async getPayment(userId: string, paymentId: string): Promise<PaymentResponseDto> {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    if (payment.userId !== userId) {
      throw new ForbiddenException('Not authorized for this payment');
    }

    return this._formatPaymentResponse(payment);
  }

  /**
   * Get payments for an order
   */
  async getOrderPayments(userId: string, orderId: string): Promise<PaymentResponseDto[]> {
    const order = await this.orderRepository.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    // Only buyer or seller can view order payments
    if (order.buyerId !== userId && order.sellerId !== userId) {
      throw new ForbiddenException('Not authorized for this order');
    }

    const payments = await this.paymentRepository.find({
      where: { orderId },
      order: { createdAt: 'DESC' },
    });

    return payments.map((p) => this._formatPaymentResponse(p));
  }

  /**
   * Refund a payment
   */
  async refundPayment(
    userId: string,
    paymentId: string,
    refundPaymentDto: RefundPaymentDto,
  ): Promise<PaymentResponseDto> {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    // Only order parties can initiate refunds
    const order = await this.orderRepository.findOne({
      where: { id: payment.orderId },
    });

    if (order.buyerId !== userId && order.sellerId !== userId) {
      throw new ForbiddenException('Not authorized for this refund');
    }

    if (payment.status !== 'succeeded') {
      throw new BadRequestException('Only succeeded payments can be refunded');
    }

    try {
      const refund = await this.stripe.refunds.create({
        payment_intent: payment.stripePaymentIntentId,
        amount: refundPaymentDto.amount
          ? Math.round(refundPaymentDto.amount * 100)
          : undefined,
        metadata: {
          orderId: payment.orderId,
          reason: refundPaymentDto.reason,
        },
      });

      payment.status = 'refunded';
      payment.refundedAt = new Date();
      payment.escrowStatus = 'refunded';

      // Update order status
      await this.orderRepository.update(
        { id: payment.orderId },
        { paymentStatus: 'refunded' },
      );

      const updated = await this.paymentRepository.save(payment);
      return this._formatPaymentResponse(updated);
    } catch (error) {
      throw new BadRequestException(`Refund failed: ${error.message}`);
    }
  }

  /**
   * Release escrow funds (seller receives payout)
   */
  async releaseEscrow(paymentId: string): Promise<PaymentResponseDto> {
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new NotFoundException('Payment not found');
    }

    if (payment.escrowStatus !== 'held') {
      throw new BadRequestException('Payment not in escrow state');
    }

    // TODO: Create payout to seller's Stripe connected account
    // For now, mark as released
    payment.escrowStatus = 'released';
    const updated = await this.paymentRepository.save(payment);

    return this._formatPaymentResponse(updated);
  }

  /**
   * Handle Stripe webhook events
   */
  async handleWebhookEvent(event: Stripe.Event): Promise<void> {
    switch (event.type) {
      case 'payment_intent.succeeded':
        await this._handlePaymentIntentSucceeded(
          event.data.object as Stripe.PaymentIntent,
        );
        break;
      case 'payment_intent.payment_failed':
        await this._handlePaymentIntentFailed(
          event.data.object as Stripe.PaymentIntent,
        );
        break;
      case 'charge.refunded':
        await this._handleChargeRefunded(
          event.data.object as Stripe.Charge,
        );
        break;
      case 'charge.dispute.created':
        await this._handleChargeDispute(
          event.data.object as Stripe.Dispute,
        );
        break;
    }
  }

  /**
   * Get user's payment history
   */
  async getUserPaymentHistory(
    userId: string,
    page: number = 1,
    limit: number = 20,
  ): Promise<{ payments: PaymentResponseDto[]; total: number }> {
    const skip = (page - 1) * limit;

    const [payments, total] = await this.paymentRepository.findAndCount({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip,
      take: limit,
    });

    return {
      payments: payments.map((p) => this._formatPaymentResponse(p)),
      total,
    };
  }

  /**
   * Private helper methods
   */

  private _mapStripeStatusToPaymentStatus(
    stripeStatus: string,
  ): string {
    const statusMap = {
      succeeded: 'succeeded',
      processing: 'processing',
      requires_payment_method: 'failed',
      requires_action: 'processing',
      requires_confirmation: 'pending',
      canceled: 'cancelled',
    };

    return statusMap[stripeStatus] || 'pending';
  }

  private _extractCardInfo(paymentMethodDetails: any): any {
    if (paymentMethodDetails?.card) {
      return {
        brand: paymentMethodDetails.card.brand,
        last4: paymentMethodDetails.card.last4,
        expiryMonth: paymentMethodDetails.card.exp_month,
        expiryYear: paymentMethodDetails.card.exp_year,
      };
    }
    return null;
  }

  private _formatPaymentResponse(payment: Payment): PaymentResponseDto {
    return {
      id: payment.id,
      orderId: payment.orderId,
      userId: payment.userId,
      amount: Number(payment.amount),
      currency: payment.currency,
      status: payment.status,
      escrowStatus: payment.escrowStatus,
      paymentMethod: payment.paymentMethod,
      cardInfo: payment.cardInfo,
      stripePaymentIntentId: payment.stripePaymentIntentId,
      stripeChargeId: payment.stripeChargeId,
      receiptUrl: payment.receiptUrl,
      createdAt: payment.createdAt,
      paidAt: payment.paidAt,
      refundedAt: payment.refundedAt,
      failureReason: payment.failureReason,
    };
  }

  private async _handlePaymentIntentSucceeded(
    paymentIntent: Stripe.PaymentIntent,
  ): Promise<void> {
    const { orderId } = paymentIntent.metadata;
    const payment = await this.paymentRepository.findOne({
      where: { stripePaymentIntentId: paymentIntent.id },
    });

    if (payment) {
      payment.status = 'succeeded';
      payment.paidAt = new Date();
      payment.escrowStatus = 'held';
      await this.paymentRepository.save(payment);
    }
  }

  private async _handlePaymentIntentFailed(
    paymentIntent: Stripe.PaymentIntent,
  ): Promise<void> {
    const payment = await this.paymentRepository.findOne({
      where: { stripePaymentIntentId: paymentIntent.id },
    });

    if (payment) {
      payment.status = 'failed';
      payment.failureReason = paymentIntent.last_payment_error?.message;
      await this.paymentRepository.save(payment);
    }
  }

  private async _handleChargeRefunded(charge: Stripe.Charge): Promise<void> {
    if (charge.payment_intent) {
      const payment = await this.paymentRepository.findOne({
        where: { stripePaymentIntentId: charge.payment_intent as string },
      });

      if (payment) {
        payment.status = 'refunded';
        payment.escrowStatus = 'refunded';
        payment.refundedAt = new Date();
        await this.paymentRepository.save(payment);
      }
    }
  }

  private async _handleChargeDispute(dispute: Stripe.Dispute): Promise<void> {
    // Handle refund disputes (customer disputes payment)
    if (dispute.charge) {
      const payment = await this.paymentRepository.findOne({
        where: { stripeChargeId: dispute.charge as string },
      });

      if (payment) {
        payment.status = 'failed';
        payment.failureReason = `Payment disputed: ${dispute.reason}`;
        await this.paymentRepository.save(payment);
      }
    }
  }
}
