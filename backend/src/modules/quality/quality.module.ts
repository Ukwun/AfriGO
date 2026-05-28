import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { QualityInspection } from './quality-inspection.entity';
import { LabCertification } from './lab-certification.entity';
import { QualityService } from './quality.service';
import { QualityController } from './quality.controller';
import { Lot } from '../lots/lot.entity';
import { User } from '../auth/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      QualityInspection,
      LabCertification,
      Lot,
      User,
    ]),
  ],
  controllers: [QualityController],
  providers: [QualityService],
  exports: [QualityService],
})
export class QualityModule {}
