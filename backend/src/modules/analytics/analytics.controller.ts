import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  Query,
} from '@nestjs/common';
import { AnalyticsService } from './analytics.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('api/analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  /**
   * POST /api/analytics/activity
   * Record a user activity (called from mobile/frontend)
   * Tracks: screen views, button clicks, searches, bids, payments, errors
   * 
   * Body:
   * {
   *   "eventType": "action|screen|error|api_call",
   *   "action": "lot_search|bid_submit|payment_initiate",
   *   "data": { "lotId": "abc", "amount": 5000 },
   *   "deviceType": "mobile|web",
   *   "appVersion": "1.0.0",
   *   "sessionId": "session-uuid"
   * }
   */
  @UseGuards(JwtAuthGuard)
  @Post('activity')
  @HttpCode(HttpStatus.CREATED)
  async recordActivity(
    @Request() req,
    @Body()
    activityData: {
      eventType: string;
      action: string;
      data?: Record<string, any>;
      deviceType?: string;
      appVersion?: string;
      sessionId?: string;
    },
  ) {
    return this.analyticsService.recordActivity(
      req.user.id,
      activityData.eventType,
      activityData.action,
      activityData.data,
      {
        deviceType: activityData.deviceType,
        appVersion: activityData.appVersion,
        sessionId: activityData.sessionId,
      },
    );
  }

  /**
   * GET /api/analytics/engagement?days=30
   * Get user engagement metrics (for admin dashboard)
   * 
   * Returns:
   * {
   *   "totalActivities": 1245,
   *   "uniqueUsers": 42,
   *   "avgActivitiesPerUser": 29.64,
   *   "activitiesByType": {
   *     "screen_view": 450,
   *     "lot_search": 320,
   *     "bid_submit": 180,
   *     "error": 15
   *   },
   *   "errorRate": 1.20,
   *   "topErrors": [...]
   * }
   */
  @Get('engagement')
  @HttpCode(HttpStatus.OK)
  async getEngagementMetrics(@Query('days') days: number = 30) {
    return this.analyticsService.getUserEngagementMetrics(days);
  }

  /**
   * GET /api/analytics/api-performance?days=7
   * Get API performance metrics (latency, error rates)
   * 
   * Returns:
   * {
   *   "endpointMetrics": {
   *     "GET /api/lots": {
   *       "count": 284,
   *       "avgResponseTime": 87.5,
   *       "errorRate": 0.3
   *     },
   *     "POST /api/bids": {
   *       "count": 45,
   *       "avgResponseTime": 245.8,
   *       "errorRate": 5.3
   *     }
   *   }
   * }
   */
  @Get('api-performance')
  @HttpCode(HttpStatus.OK)
  async getApiMetrics(@Query('days') days: number = 7) {
    return this.analyticsService.getApiMetrics(days);
  }

  /**
   * GET /api/analytics/my-activity?limit=50
   * Get current user's activity timeline
   * Requires authentication
   */
  @UseGuards(JwtAuthGuard)
  @Get('my-activity')
  @HttpCode(HttpStatus.OK)
  async getMyActivity(@Request() req, @Query('limit') limit: number = 50) {
    return this.analyticsService.getUserActivityTimeline(req.user.id, limit);
  }

  /**
   * GET /api/analytics/top-users?days=30&limit=20
   * Get most active users (for admin insights)
   * 
   * Returns:
   * [
   *   { "userId": "uuid-abc", "activityCount": 287 },
   *   { "userId": "uuid-def", "activityCount": 245 },
   *   ...
   * ]
   */
  @Get('top-users')
  @HttpCode(HttpStatus.OK)
  async getTopUsers(
    @Query('days') days: number = 30,
    @Query('limit') limit: number = 20,
  ) {
    return this.analyticsService.getTopActiveUsers(days, limit);
  }

  /**
   * GET /api/analytics/market-activity?days=30
   * Get marketplace activity (searches, bids, payments, etc.)
   * 
   * Returns:
   * {
   *   "lotSearches": 891,
   *   "lotViews": 1243,
   *   "bidsSubmitted": 284,
   *   "paymentsInitiated": 156,
   *   "contractsCreated": 89,
   *   "shipmentsCreated": 45,
   *   "period": "30 days"
   * }
   */
  @Get('market-activity')
  @HttpCode(HttpStatus.OK)
  async getMarketActivity(@Query('days') days: number = 30) {
    return this.analyticsService.getMarketActivityMetrics(days);
  }

  /**
   * POST /api/analytics/api-call
   * Record an API call (for server-side tracking)
   * 
   * Called by middleware for all API requests
   */
  @Post('api-call')
  @HttpCode(HttpStatus.CREATED)
  async recordApiCall(
    @Body()
    apiCallData: {
      userId?: string;
      endpoint: string;
      method: string;
      statusCode: number;
      responseTime: number;
      ipAddress?: string;
    },
  ) {
    if (!apiCallData.userId) {
      return { message: 'Anonymous API call recorded' };
    }

    return this.analyticsService.recordActivity(
      apiCallData.userId,
      'api_call',
      `${apiCallData.method} ${apiCallData.endpoint}`,
      { method: apiCallData.method },
      {
        endpoint: apiCallData.endpoint,
        statusCode: apiCallData.statusCode,
        responseTime: apiCallData.responseTime,
        ipAddress: apiCallData.ipAddress,
      },
    );
  }
}
