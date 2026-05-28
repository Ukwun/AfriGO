import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { PaymentsService } from './services/payments.service';
import { EscrowService } from './services/escrow.service';
import { PaymentsController } from './controllers/payments.controller';
import { Payment } from './entities/payment.entity';
import { Escrow } from './entities/escrow.entity';
import { PaymentTransactionLog } from './entities/payment-transaction-log.entity';

/**
 * Payments Module - Flutterwave Integration
 *
 * Handles payment processing, escrow management, and fund transfers.
 *
 * Features:
 * - Multi-currency payments (KES, USD, EUR, ZAR, UGX, TZS)
 * - 5 payment methods (FULL_UPFRONT, PARTIAL_DEPOSIT, ON_DELIVERY, INSTALLMENT, ESCROW)
 * - Flutterwave PCI DSS compliant gateway
 * - Multi-condition escrow with auto-release
 * - Automated late fee calculations
 * - Complete audit trail (payment_transaction_log)
 * - Idempotent webhook processing
 *
 * Endpoints:
 * - POST /api/payments - Create payment
 * - POST /api/payments/:id/initiate - Start Flutterwave flow
 * - POST /api/payments/webhook/flutterwave - Webhook receiver
 * - GET /api/payments/:id - Get payment details
 * - GET /api/payments - List payments with filters
 * - POST /api/payments/:id/refund - Process refund
 * - POST /api/payments/:id/dispute - File dispute
 * - GET /api/payments/statistics - Dashboard stats
 * - POST /api/escrow - Create escrow
 * - GET /api/escrow/:id - Get escrow status
 * - POST /api/escrow/:id/release/:condition - Mark condition met
 * - POST /api/escrow/:id/dispute - File dispute
 * - GET /api/escrow - List escrows
 * - GET /api/escrow/statistics - Escrow analytics
 */
@Module({
  imports: [
    // Import database entities
    TypeOrmModule.forFeature([
      Payment,
      Escrow,
      PaymentTransactionLog,
    ]),
    // Import config for environment variables
    ConfigModule,
  ],
  // Service providers
  providers: [
    PaymentsService,   // 14 methods for payment processing
    EscrowService,     // 8 methods for escrow management
  ],
  // Controllers
  controllers: [
    PaymentsController, // 15+ endpoints
  ],
  // Export for other modules
  exports: [
    PaymentsService,
    EscrowService,
  ],
})
export class PaymentsModule {}
