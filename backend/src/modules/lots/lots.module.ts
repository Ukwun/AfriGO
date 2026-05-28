import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Lot } from './entities/lot.entity';
import { LotTraceability } from './entities/lot-traceability.entity';
import { QualityReport } from './entities/quality-report.entity';
import { LotsService } from './lots.service';
import { LotsController } from './lots.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Lot, LotTraceability, QualityReport])],
  controllers: [LotsController],
  providers: [LotsService],
  exports: [LotsService],
})
export class LotsModule {}
