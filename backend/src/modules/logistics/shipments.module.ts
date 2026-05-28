import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ShipmentsController } from './shipments.controller';
import { ShipmentsService } from './shipments.service';
import { Shipment } from './shipment.entity';
import { ShipmentTracking } from './shipment-tracking.entity';
import { DeliveryProof } from './delivery-proof.entity';
import { Contract } from '../contracts/contract.entity';
import { User } from '../users/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Shipment,
      ShipmentTracking,
      DeliveryProof,
      Contract,
      User,
    ]),
  ],
  controllers: [ShipmentsController],
  providers: [ShipmentsService],
  exports: [ShipmentsService],
})
export class LogisticsModule {}
