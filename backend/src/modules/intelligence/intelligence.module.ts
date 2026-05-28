import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IntelligenceController } from './controllers/intelligence.controller';
import { TrustScoringService } from './services/trust-scoring.service';
import { FraudDetectionService } from './services/fraud-detection.service';
import { ActivityLoggingService } from './services/activity-logging.service';
import { TrustScore } from './entities/trust-score.entity';
import { UserActivityLog } from './entities/activity-log.entity';
import { FraudAlert } from './entities/fraud-alert.entity';
import { User } from '../auth/entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([TrustScore, UserActivityLog, FraudAlert, User])],
  controllers: [IntelligenceController],
  providers: [TrustScoringService, FraudDetectionService, ActivityLoggingService],
  exports: [TrustScoringService, FraudDetectionService, ActivityLoggingService],
})
export class IntelligenceModule {}
