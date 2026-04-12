import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  BadRequestException,
} from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CreatePaymentDto,
  ConfirmPaymentDto,
  RefundPaymentDto,
  PaymentResponseDto,
} from './dtos/payment.dto';

@Controller('api/payments')
@UseGuards(JwtAuthGuard)
export class PaymentsController {
  constructor(private paymentsService: PaymentsService) {}

  /**
   * Get Stripe publishable key
   * GET /api/payments/config/publishable-key
   */
  @Get('config/publishable-key')
  getPublishableKey(): { publishableKey: string } {
    return {
      publishableKey: this.paymentsService.getPublishableKey(),
    };
  }

  /**
   * Create a new payment (initialize PaymentIntent)
   * POST /api/payments
   */
  @Post()
  async createPayment(
    @Request() req: any,
    @Body() createPaymentDto: CreatePaymentDto,
  ): Promise<{ success: boolean; data: PaymentResponseDto }> {
    if (!createPaymentDto.orderId) {
      throw new BadRequestException('orderId is required');
    }

    if (!createPaymentDto.amount || createPaymentDto.amount <= 0) {
      throw new BadRequestException('amount must be greater than 0');
    }

    if (!createPaymentDto.paymentMethodId) {
      throw new BadRequestException('paymentMethodId is required');
    }

    const payment = await this.paymentsService.createPayment(
      req.user.id,
      createPaymentDto,
    );

    return {
      success: true,
      data: payment,
    };
  }

  /**
   * Confirm payment (for 3D Secure or additional authentication)
   * POST /api/payments/:id/confirm
   */
  @Post(':id/confirm')
  async confirmPayment(
    @Request() req: any,
    @Param('id') paymentId: string,
    @Body() confirmPaymentDto: ConfirmPaymentDto,
  ): Promise<{ success: boolean; data: PaymentResponseDto }> {
    if (!confirmPaymentDto.paymentIntentId) {
      throw new BadRequestException('paymentIntentId is required');
    }

    if (!confirmPaymentDto.paymentMethodId) {
      throw new BadRequestException('paymentMethodId is required');
    }

    const payment = await this.paymentsService.confirmPayment(
      req.user.id,
      paymentId,
      confirmPaymentDto,
    );

    return {
      success: true,
      data: payment,
    };
  }

  /**
   * Get payment by ID
   * GET /api/payments/:id
   */
  @Get(':id')
  async getPayment(
    @Request() req: any,
    @Param('id') paymentId: string,
  ): Promise<{ success: boolean; data: PaymentResponseDto }> {
    const payment = await this.paymentsService.getPayment(
      req.user.id,
      paymentId,
    );

    return {
      success: true,
      data: payment,
    };
  }

  /**
   * Get payment for an order
   * GET /api/orders/:orderId/payment
   */
  @Get('order/:orderId')
  async getOrderPayment(
    @Request() req: any,
    @Param('orderId') orderId: string,
  ): Promise<{ success: boolean; data: PaymentResponseDto[] }> {
    const payments = await this.paymentsService.getOrderPayments(
      req.user.id,
      orderId,
    );

    return {
      success: true,
      data: payments,
    };
  }

  /**
   * Refund a payment
   * POST /api/payments/:id/refund
   */
  @Post(':id/refund')
  async refundPayment(
    @Request() req: any,
    @Param('id') paymentId: string,
    @Body() refundPaymentDto: RefundPaymentDto,
  ): Promise<{ success: boolean; data: PaymentResponseDto }> {
    if (!refundPaymentDto.reason) {
      throw new BadRequestException('reason is required');
    }

    const payment = await this.paymentsService.refundPayment(
      req.user.id,
      paymentId,
      refundPaymentDto,
    );

    return {
      success: true,
      data: payment,
    };
  }

  /**
   * Get user payment history
   * GET /api/payments
   */
  @Get()
  async getUserPaymentHistory(
    @Request() req: any,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ): Promise<{
    success: boolean;
    data: PaymentResponseDto[];
    pagination: { page: number; limit: number; total: number };
  }> {
    const pageNum = page ? Math.max(1, Number(page)) : 1;
    const limitNum = limit ? Math.min(100, Math.max(1, Number(limit))) : 20;

    const { payments, total } =
      await this.paymentsService.getUserPaymentHistory(
        req.user.id,
        pageNum,
        limitNum,
      );

    return {
      success: true,
      data: payments,
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
      },
    };
  }

  /**
   * Release escrow funds (admin only - for delivered orders)
   * POST /api/payments/:id/release-escrow
   */
  @Post(':id/release-escrow')
  async releaseEscrow(
    @Param('id') paymentId: string,
  ): Promise<{ success: boolean; data: PaymentResponseDto }> {
    // TODO: Add admin guard
    const payment = await this.paymentsService.releaseEscrow(paymentId);

    return {
      success: true,
      data: payment,
    };
  }
}
