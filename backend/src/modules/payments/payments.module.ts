import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { PaymentsService } from './payments.service';
import { PaymentsController } from './payments.controller';
import { StripeWebhooksController } from './stripe-webhooks.controller';
import { Payment } from './entities/payment.entity';
import { Order } from '../trading/entities/order.entity';
import { User } from '../auth/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Payment, Order, User]),
    ConfigModule,
  ],
  providers: [PaymentsService],
  controllers: [PaymentsController, StripeWebhooksController],
  exports: [PaymentsService],
})
export class PaymentsModule {}
