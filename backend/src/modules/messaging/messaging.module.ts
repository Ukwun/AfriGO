import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MessagingService } from './messaging.service';
import { MessagingController } from './messaging.controller';
import { Message } from './entities/message.entity';
import { User } from '../auth/entities/user.entity';
import { Order } from '../trading/entities/order.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Message, User, Order]),
  ],
  controllers: [MessagingController],
  providers: [MessagingService],
  exports: [MessagingService],
})
export class MessagingModule {}
