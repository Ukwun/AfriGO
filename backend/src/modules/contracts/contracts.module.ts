import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Contract } from './entities/contract.entity';
import { ContractAmendment } from './entities/contract-amendment.entity';
import { ContractService } from './contracts.service';
import { ContractController } from './contracts.controller';
import { Lot } from '../lots/lot.entity';
import { RFQ } from '../rfq/rfq.entity';
import { User } from '../users/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Contract,
      ContractAmendment,
      Lot,
      RFQ,
      User,
    ]),
  ],
  controllers: [ContractController],
  providers: [ContractService],
  exports: [ContractService],
})
export class ContractModule {}
