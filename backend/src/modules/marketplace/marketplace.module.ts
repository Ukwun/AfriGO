import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RFQ } from './rfq.entity';
import { RFQBid } from './rfq-bid.entity';
import { RFQsService } from './rfqs.service';
import { RFQsController } from './rfqs.controller';
import { LotsService } from '../lots/lots.service';
import { Lot } from '../lots/lot.entity';
import { LotTraceability } from '../lots/lot-traceability.entity';
import { QualityReport } from '../lots/quality-report.entity';
import { User } from '../auth/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      RFQ,
      RFQBid,
      Lot,
      LotTraceability,
      QualityReport,
      User,
    ]),
  ],
  controllers: [RFQsController],
  providers: [RFQsService, LotsService],
  exports: [RFQsService],
})
export class MarketplaceModule {}
