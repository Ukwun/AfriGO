import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
  Req,
  HttpCode,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { TrustScoringService } from '../services/trust-scoring.service';
import { FraudDetectionService } from '../services/fraud-detection.service';
import { ActivityLoggingService } from '../services/activity-logging.service';

interface AuthRequest {
  user: { id: string; email: string };
  ip?: string;
}

@Controller('api/intelligence')
export class IntelligenceController {
  private readonly logger = new Logger(IntelligenceController.name);

  constructor(
    private trustScoringService: TrustScoringService,
    private fraudDetectionService: FraudDetectionService,
    private activityLoggingService: ActivityLoggingService,
  ) {}

  /**
   * GET /api/intelligence/trust-score/:userId
   * Get current trust score for a user
   */
  @Get('trust-score/:userId')
  @UseGuards(JwtAuthGuard)
  async getTrustScore(@Param('userId') userId: string) {
    try {
      const trustScore = await this.trustScoringService.getTrustScore(userId);

      return {
        success: true,
        data: trustScore,
        message: 'Trust score retrieved successfully',
      };
    } catch (error) {
      this.logger.error(`Error getting trust score: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'TRUST_SCORE_ERROR',
      };
    }
  }

  /**
   * POST /api/intelligence/trust-score/:userId/calculate
   * Recalculate trust score for a user (typically after trade/payment)
   */
  @Post('trust-score/:userId/calculate')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async calculateTrustScore(@Param('userId') userId: string) {
    try {
      const breakdown = await this.trustScoringService.calculateTrustScore(userId);

      return {
        success: true,
        data: breakdown,
        message: 'Trust score recalculated successfully',
      };
    } catch (error) {
      this.logger.error(`Error calculating trust score: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'CALCULATION_ERROR',
      };
    }
  }

  /**
   * GET /api/intelligence/trust-score/:userId/history
   * Get trust score history for last 30 days
   */
  @Get('trust-score/:userId/history')
  @UseGuards(JwtAuthGuard)
  async getTrustScoreHistory(@Param('userId') userId: string) {
    try {
      const history = await this.trustScoringService.getTrustScoreHistory(userId, 30);

      return {
        success: true,
        data: history,
        message: 'Trust score history retrieved successfully',
      };
    } catch (error) {
      this.logger.error(`Error getting trust score history: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'HISTORY_ERROR',
      };
    }
  }

  /**
   * POST /api/intelligence/fraud-detection
   * Detect fraud for a proposed transaction
   */
  @Post('fraud-detection')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async detectFraud(
    @Body()
    body: {
      userId: string;
      amount?: number;
      currency?: string;
      targetUserId?: string;
      tradeId?: string;
      location?: any;
    },
    @Req() req: AuthRequest,
  ) {
    try {
      const fraudResult = await this.fraudDetectionService.detectFraud(
        body.userId,
        {
          amount: body.amount,
          currency: body.currency,
          targetUserId: body.targetUserId,
          tradeId: body.tradeId,
          location: body.location,
        },
      );

      // Log this activity
      await this.activityLoggingService.logActivity(body.userId, 'FRAUD_CHECK', {
        ipAddress: req.ip,
        actionData: {
          fraudScore: fraudResult.fraudScore,
          riskLevel: fraudResult.riskLevel,
          shouldBlock: fraudResult.shouldBlock,
        },
      });

      return {
        success: true,
        data: fraudResult,
        message: 'Fraud detection completed',
        warning: fraudResult.shouldBlock
          ? 'Transaction will be blocked'
          : fraudResult.shouldReview
          ? 'Transaction requires manual review'
          : null,
      };
    } catch (error) {
      this.logger.error(`Error in fraud detection: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'FRAUD_DETECTION_ERROR',
      };
    }
  }

  /**
   * GET /api/intelligence/fraud-alerts/:userId
   * Get fraud alerts for a user
   */
  @Get('fraud-alerts/:userId')
  @UseGuards(JwtAuthGuard)
  async getFraudAlerts(
    @Param('userId') userId: string,
    @Req() req: AuthRequest,
  ) {
    try {
      const alerts = await this.fraudDetectionService.getFraudAlerts(userId);

      return {
        success: true,
        data: alerts,
        message: `Found ${alerts.length} fraud alerts`,
      };
    } catch (error) {
      this.logger.error(`Error getting fraud alerts: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'FRAUD_ALERTS_ERROR',
      };
    }
  }

  /**
   * GET /api/intelligence/activity-history/:userId
   * Get activity history for a user
   */
  @Get('activity-history/:userId')
  @UseGuards(JwtAuthGuard)
  async getActivityHistory(@Param('userId') userId: string) {
    try {
      const activities = await this.activityLoggingService.getUserActivityHistory(
        userId,
        30,
      );
      const counts = await this.activityLoggingService.getActivityCountByType(
        userId,
        30,
      );

      return {
        success: true,
        data: {
          activities,
          counts,
          total: activities.length,
        },
        message: 'Activity history retrieved successfully',
      };
    } catch (error) {
      this.logger.error(`Error getting activity history: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'ACTIVITY_HISTORY_ERROR',
      };
    }
  }

  /**
   * POST /api/intelligence/activity-log
   * Log an activity (called by other modules)
   */
  @Post('activity-log')
  @HttpCode(HttpStatus.CREATED)
  async logActivity(
    @Body()
    body: {
      userId: string;
      activityType: string;
      ipAddress?: string;
      deviceInfo?: any;
      location?: any;
      actionData?: any;
    },
    @Req() req: AuthRequest,
  ) {
    try {
      const activity = await this.activityLoggingService.logActivity(
        body.userId,
        body.activityType,
        {
          ipAddress: body.ipAddress || req.ip,
          deviceInfo: body.deviceInfo,
          location: body.location,
          actionData: body.actionData,
        },
      );

      return {
        success: true,
        data: activity,
        message: 'Activity logged successfully',
      };
    } catch (error) {
      this.logger.error(`Error logging activity: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'ACTIVITY_LOG_ERROR',
      };
    }
  }

  /**
   * GET /api/intelligence/activity-summary/:userId
   * Get activity summary for dashboard
   */
  @Get('activity-summary/:userId')
  @UseGuards(JwtAuthGuard)
  async getActivitySummary(@Param('userId') userId: string) {
    try {
      const activities = await this.activityLoggingService.getUserActivityHistory(
        userId,
        30,
      );
      const counts = await this.activityLoggingService.getActivityCountByType(
        userId,
        30,
      );
      const trustScore = await this.trustScoringService.getTrustScore(userId);
      const fraudAlerts = await this.fraudDetectionService.getFraudAlerts(
        userId,
        'PENDING',
      );

      return {
        success: true,
        data: {
          trustScore,
          activityCount: activities.length,
          activityBreakdown: counts,
          pendingFraudAlerts: fraudAlerts.length,
          lastActivity: activities[0] || null,
        },
        message: 'Activity summary retrieved successfully',
      };
    } catch (error) {
      this.logger.error(`Error getting activity summary: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'SUMMARY_ERROR',
      };
    }
  }
}
