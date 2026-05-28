import {
  Controller,
  Post,
  Get,
  Put,
  Body,
  Param,
  Query,
  UseGuards,
  BadRequestException,
  HttpStatus,
  Res,
} from '@nestjs/common';
import { Response } from 'express';

import { PaymentsService } from '../services/payments.service';
import { EscrowService } from '../services/escrow.service';
import {
  CreatePaymentDto,
  UpdatePaymentStatusDto,
  VerifyPaymentDto,
  RefundPaymentDto,
  DisputePaymentDto,
  PaymentStatisticsQueryDto,
  CreateInvoiceDto,
  CreateEscrowDto,
  ReleaseEscrowDto,
  DisputeEscrowDto,
  EscrowStatisticsQueryDto,
} from '../dto';

/**
 * PAYMENTS CONTROLLER
 * REST API for payment processing, escrow management, and settlements
 * All endpoints require authentication except Flutterwave webhook
 */
@Controller('api/payments')
export class PaymentsController {
  constructor(
    private readonly paymentsService: PaymentsService,
    private readonly escrowService: EscrowService,
  ) {}

  // ============================================================================
  // PAYMENT ENDPOINTS (12 total)
  // ============================================================================

  /**
   * ENDPOINT 1: POST /api/payments
   * Creates a new payment from a contract
   * Generates invoice reference in format: INV-2026-001001
   *
   * Request Body: CreatePaymentDto
   * Response: { success: true, data: { paymentId, reference, status } }
   */
  @Post()
  async createPayment(@Body() dto: CreatePaymentDto, @Query('userId') userId: string) {
    if (!userId) {
      throw new BadRequestException('userId query parameter required');
    }

    const payment = await this.paymentsService.createPayment(dto, userId);

    return {
      success: true,
      message: 'Payment created',
      data: {
        paymentId: payment.id,
        reference: payment.invoiceReference,
        status: payment.status,
        amount: payment.amount,
        currency: payment.currency,
        createdAt: payment.createdAt,
      },
    };
  }

  /**
   * ENDPOINT 2: POST /api/payments/:id/initiate
   * Initiates payment with Flutterwave
   * Returns Flutterwave redirect URL
   *
   * Response: { success: true, data: { paymentUrl } }
   */
  @Post(':id/initiate')
  async initiatePayment(@Param('id') paymentId: string, @Query('userId') userId: string) {
    if (!userId) {
      throw new BadRequestException('userId query parameter required');
    }

    const paymentUrl = await this.paymentsService.initiatePayment(paymentId, userId);

    return {
      success: true,
      message: 'Payment initiated',
      data: {
        paymentUrl,
        redirectTo: 'flutterwave',
      },
    };
  }

  /**
   * ENDPOINT 3: POST /api/payments/webhook/flutterwave
   * Receives Flutterwave webhook for payment status updates
   * CRITICAL: No authentication (Flutterwave server-to-server)
   *
   * Webhook signature verified server-side
   * Response: { success: true, message: 'Webhook processed' }
   */
  @Post('webhook/flutterwave')
  async handleFlutterwaveWebhook(@Body() webhookData: any) {
    try {
      const payment = await this.paymentsService.handleFlutterwaveWebhook(webhookData);

      return {
        success: true,
        message: 'Webhook processed',
        data: { paymentId: payment?.id },
      };
    } catch (error) {
      // Log webhook error but return 200 OK (Flutterwave retry if 5xx)
      console.error('Flutterwave webhook error:', error);
      return { success: false, message: error.message };
    }
  }

  /**
   * ENDPOINT 4: POST /api/payments/:id/refund
   * Requests refund for completed payment
   * Called when: quality issues, non-delivery, buyer cancellation
   *
   * Response: { success: true, data: { refundId, status, amount } }
   */
  @Post(':id/refund')
  async refundPayment(
    @Param('id') paymentId: string,
    @Body() dto: RefundPaymentDto,
    @Query('userId') userId: string,
  ) {
    if (!userId) {
      throw new BadRequestException('userId query parameter required');
    }

    // In production, would map reason + evidence to RefundPaymentDto
    const updatedPayment = await this.paymentsService.processRefund(paymentId, dto.reason, userId);

    return {
      success: true,
      message: 'Refund processed',
      data: {
        refundId: updatedPayment.id,
        status: updatedPayment.status,
        amount: updatedPayment.amount,
      },
    };
  }

  /**
   * ENDPOINT 5: GET /api/payments/:id
   * Retrieves payment details
   *
   * Response: { success: true, data: payment object }
   */
  @Get(':id')
  async getPayment(@Param('id') paymentId: string) {
    const payment = await this.paymentsService.getPaymentById(paymentId);

    return {
      success: true,
      message: 'Payment retrieved',
      data: payment,
    };
  }

  /**
   * ENDPOINT 6: GET /api/payments
   * Lists payments with filtering and pagination
   *
   * Query Parameters:
   *   - status: PaymentStatusEnum (PENDING, COMPLETED, etc.)
   *   - method: PaymentMethodEnum
   *   - startDate, endDate: ISO date strings
   *   - page: 0-indexed page number (default: 0)
   *   - limit: results per page (default: 10)
   *
   * Response: { success: true, data: { payments, pagination } }
   */
  @Get()
  async listPayments(@Query() filters: PaymentStatisticsQueryDto) {
    const page = parseInt(filters['page'] ?? '0', 10);
    const limit = parseInt(filters['limit'] ?? '10', 10);

    const { data, total } = await this.paymentsService.listPayments(filters, page, limit);

    return {
      success: true,
      message: 'Payments retrieved',
      data: {
        payments: data,
        pagination: {
          page,
          limit,
          total,
          pageCount: Math.ceil(total / limit),
        },
      },
    };
  }

  /**
   * ENDPOINT 7: GET /api/payments/:id/invoice
   * Retrieves payment invoice as PDF
   * Generates PDF on-the-fly or returns cached version
   *
   * Response: PDF binary (Content-Type: application/pdf)
   */
  @Get(':id/invoice')
  async getInvoice(@Param('id') paymentId: string, @Res() res: Response) {
    const invoicePdf = await this.paymentsService.generateInvoice(paymentId);

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="invoice-${paymentId}.pdf"`);
    res.send(invoicePdf);
  }

  /**
   * ENDPOINT 8: POST /api/payments/:id/dispute
   * Files dispute for payment (quality, non-delivery, etc.)
   *
   * Response: { success: true, data: { disputeId, status } }
   */
  @Post(':id/dispute')
  async disputePayment(
    @Param('id') paymentId: string,
    @Body() dto: DisputePaymentDto,
    @Query('userId') userId: string,
  ) {
    if (!userId) {
      throw new BadRequestException('userId query parameter required');
    }

    const updatedPayment = await this.paymentsService.disputePayment(paymentId, dto.reason, userId);

    return {
      success: true,
      message: 'Dispute filed',
      data: {
        disputeId: updatedPayment.id,
        status: updatedPayment.status,
      },
    };
  }

  /**
   * ENDPOINT 9: GET /api/payments/statistics
   * Returns payment statistics for admin dashboards
   *
   * Query Parameters: Same as listPayments (filters)
   *
   * Response: { success: true, data: { byStatus, byMethod, byCurrency, totals } }
   */
  @Get('statistics')
  async getPaymentStatistics(@Query() filters: PaymentStatisticsQueryDto) {
    const stats = await this.paymentsService.getPaymentStatistics(filters);

    return {
      success: true,
      message: 'Payment statistics retrieved',
      data: stats,
    };
  }

  // ============================================================================
  // ESCROW ENDPOINTS (Handled by this controller for convenience)
  // ============================================================================

  /**
   * ENDPOINT 10: POST /api/escrow
   * Creates escrow fund hold for completed payment
   * Funds held until release conditions met
   *
   * Request Body: CreateEscrowDto
   * Response: { success: true, data: { escrowId, status } }
   */
  @Post('escrow')
  async createEscrow(@Body() dto: CreateEscrowDto, @Query('userId') userId: string) {
    if (!userId) {
      throw new BadRequestException('userId query parameter required');
    }

    const escrow = await this.escrowService.createEscrow(dto.contractId, dto, userId);

    return {
      success: true,
      message: 'Escrow created',
      data: {
        escrowId: escrow.id,
        status: escrow.status,
        amount: escrow.amount,
        conditionsMet: escrow.conditionsMet,
      },
    };
  }

  /**
   * ENDPOINT 11: GET /api/escrow/:id
   * Retrieves escrow details with condition status
   *
   * Response: { success: true, data: escrow object }
   */
  @Get('escrow/:id')
  async getEscrow(@Param('id') escrowId: string) {
    const escrow = await this.escrowService.getEscrowById(escrowId);

    return {
      success: true,
      message: 'Escrow retrieved',
      data: escrow,
    };
  }

  /**
   * ENDPOINT 12: POST /api/escrow/:id/release/:condition
   * Marks release condition as met (DELIVERY_PROOF, QUALITY_APPROVAL, BUYER_SIGNOFF)
   * If all conditions met, funds auto-released to seller
   *
   * Path Parameters:
   *   - id: Escrow ID
   *   - condition: Release condition name
   *
   * Request Body: ReleaseEscrowDto with proof URL
   * Response: { success: true, data: { escrowId, status, conditionsMet } }
   */
  @Post('escrow/:id/release/:condition')
  async releaseEscrowCondition(
    @Param('id') escrowId: string,
    @Param('condition') condition: string,
    @Body() dto: ReleaseEscrowDto,
    @Query('userId') userId: string,
  ) {
    if (!userId) {
      throw new BadRequestException('userId query parameter required');
    }

    // Create proper DTO with condition
    const releaseDto = new ReleaseEscrowDto();
    releaseDto.condition = condition as any;
    releaseDto.proofUrl = dto.proofUrl;
    releaseDto.metadata = dto.metadata;

    const updatedEscrow = await this.escrowService.releaseEscrow(escrowId, releaseDto, userId);

    return {
      success: true,
      message: 'Escrow condition marked as met',
      data: {
        escrowId: updatedEscrow.id,
        status: updatedEscrow.status,
        conditionsMet: updatedEscrow.conditionsMet,
        allConditionsMet: Object.values(updatedEscrow.conditionsMet).every((c) =>
          typeof c === 'object' ? c.met : c === true,
        ),
      },
    };
  }

  // ============================================================================
  // ADDITIONAL ESCROW ENDPOINTS
  // ============================================================================

  /**
   * Disputes escrow when party disagrees with status
   */
  @Post('escrow/:id/dispute')
  async disputeEscrow(
    @Param('id') escrowId: string,
    @Body() dto: DisputeEscrowDto,
    @Query('userId') userId: string,
  ) {
    if (!userId) {
      throw new BadRequestException('userId query parameter required');
    }

    const updatedEscrow = await this.escrowService.disputeEscrow(escrowId, dto, userId);

    return {
      success: true,
      message: 'Escrow dispute filed',
      data: {
        escrowId: updatedEscrow.id,
        status: updatedEscrow.status,
      },
    };
  }

  /**
   * Lists escrows with filtering and pagination
   */
  @Get('escrow')
  async listEscrows(@Query() filters: EscrowStatisticsQueryDto) {
    const page = parseInt(filters['page'] ?? '0', 10);
    const limit = parseInt(filters['limit'] ?? '10', 10);

    const { data, total } = await this.escrowService.listEscrows(filters, page, limit);

    return {
      success: true,
      message: 'Escrows retrieved',
      data: {
        escrows: data,
        pagination: {
          page,
          limit,
          total,
          pageCount: Math.ceil(total / limit),
        },
      },
    };
  }

  /**
   * Gets escrow statistics for admin dashboards
   */
  @Get('escrow/statistics')
  async getEscrowStatistics(@Query() filters: EscrowStatisticsQueryDto) {
    const stats = await this.escrowService.getEscrowStatistics(filters);

    return {
      success: true,
      message: 'Escrow statistics retrieved',
      data: stats,
    };
  }
}
