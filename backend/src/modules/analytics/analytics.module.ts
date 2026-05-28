import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import {
  UserActivity,
  UserSession,
  PageView,
  UserMetric,
  Event,
  BehavioralAnomaly,
  Recommendation,
  AnalyticsSummary,
  Cohort,
} from './entities';
import { UserSegment } from './entities/user-segment.entity';
import { AnalyticsService } from './services/analytics.service';
import { UserActivityService } from './services/user-activity.service';
import { BehavioralAnomalyService } from './services/behavioral-anomaly.service';
import { RecommendationService } from './services/recommendation.service';
import { CohortService } from './services/cohort.service';
import { SegmentService } from './services/segment.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      UserActivity,
      UserSession,
      PageView,
      UserMetric,
      Event,
      BehavioralAnomaly,
      Recommendation,
      AnalyticsSummary,
      Cohort,
      UserSegment,
    ]),
  ],
  providers: [
    AnalyticsService,
    UserActivityService,
    BehavioralAnomalyService,
    RecommendationService,
    CohortService,
    SegmentService,
  ],
  exports: [
    AnalyticsService,
    UserActivityService,
    BehavioralAnomalyService,
    RecommendationService,
    CohortService,
    SegmentService,
  ],
})
export class AnalyticsModule {}
