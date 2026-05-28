import {
  Controller,
  Get,
  UseGuards,
  Param,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../../auth/guards/jwt-auth.guard';
import { AnalyticsService } from '../services/analytics.service';

@Controller('api/analytics')
export class AnalyticsController {
  private readonly logger = new Logger(AnalyticsController.name);

  constructor(private analyticsService: AnalyticsService) {}

  /**
   * GET /api/analytics/seller/:sellerId
   * Get seller dashboard analytics
   */
  @Get('seller/:sellerId')
  @UseGuards(JwtAuthGuard)
  async getSellerDashboard(@Param('sellerId') sellerId: string) {
    try {
      const data = await this.analyticsService.getSellerDashboard(sellerId);

      return {
        success: true,
        data,
        message: 'Seller analytics retrieved',
      };
    } catch (error) {
      this.logger.error(`Error getting seller analytics: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'SELLER_ANALYTICS_ERROR',
      };
    }
  }

  /**
   * GET /api/analytics/buyer/:buyerId
   * Get buyer dashboard analytics
   */
  @Get('buyer/:buyerId')
  @UseGuards(JwtAuthGuard)
  async getBuyerDashboard(@Param('buyerId') buyerId: string) {
    try {
      const data = await this.analyticsService.getBuyerDashboard(buyerId);

      return {
        success: true,
        data,
        message: 'Buyer analytics retrieved',
      };
    } catch (error) {
      this.logger.error(`Error getting buyer analytics: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'BUYER_ANALYTICS_ERROR',
      };
    }
  }

  /**
   * GET /api/analytics/market
   * Get market analytics (public)
   */
  @Get('market')
  async getMarketAnalytics() {
    try {
      const data = await this.analyticsService.getMarketAnalytics();

      return {
        success: true,
        data,
        message: 'Market analytics retrieved',
      };
    } catch (error) {
      this.logger.error(`Error getting market analytics: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'MARKET_ANALYTICS_ERROR',
      };
    }
  }

  /**
   * GET /api/analytics/quality
   * Get quality analytics
   */
  @Get('quality')
  async getQualityAnalytics() {
    try {
      const data = await this.analyticsService.getQualityAnalytics();

      return {
        success: true,
        data,
        message: 'Quality analytics retrieved',
      };
    } catch (error) {
      this.logger.error(`Error getting quality analytics: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'QUALITY_ANALYTICS_ERROR',
      };
    }
  }

  /**
   * GET /api/analytics/payments
   * Get payment analytics (admin only)
   */
  @Get('payments')
  @UseGuards(JwtAuthGuard)
  async getPaymentAnalytics() {
    try {
      const data = await this.analyticsService.getPaymentAnalytics();

      return {
        success: true,
        data,
        message: 'Payment analytics retrieved',
      };
    } catch (error) {
      this.logger.error(`Error getting payment analytics: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'PAYMENT_ANALYTICS_ERROR',
      };
    }
  }

  /**
   * GET /api/analytics/logistics
   * Get logistics analytics
   */
  @Get('logistics')
  async getLogisticsAnalytics() {
    try {
      const data = await this.analyticsService.getLogisticsAnalytics();

      return {
        success: true,
        data,
        message: 'Logistics analytics retrieved',
      };
    } catch (error) {
      this.logger.error(`Error getting logistics analytics: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'LOGISTICS_ANALYTICS_ERROR',
      };
    }
  }

  /**
   * GET /api/analytics/users
   * Get user growth analytics (admin only)
   */
  @Get('users')
  @UseGuards(JwtAuthGuard)
  async getUserGrowthAnalytics() {
    try {
      const data = await this.analyticsService.getUserGrowthAnalytics();

      return {
        success: true,
        data,
        message: 'User growth analytics retrieved',
      };
    } catch (error) {
      this.logger.error(`Error getting user growth analytics: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'USER_ANALYTICS_ERROR',
      };
    }
  }

  /**
   * GET /api/analytics/compliance
   * Get compliance analytics (admin only)
   */
  @Get('compliance')
  @UseGuards(JwtAuthGuard)
  async getComplianceAnalytics() {
    try {
      const data = await this.analyticsService.getComplianceAnalytics();

      return {
        success: true,
        data,
        message: 'Compliance analytics retrieved',
      };
    } catch (error) {
      this.logger.error(`Error getting compliance analytics: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'COMPLIANCE_ANALYTICS_ERROR',
      };
    }
  }

  /**
   * GET /api/analytics/revenue
   * Get revenue analytics (admin only)
   */
  @Get('revenue')
  @UseGuards(JwtAuthGuard)
  async getRevenueAnalytics() {
    try {
      const data = await this.analyticsService.getRevenueAnalytics();

      return {
        success: true,
        data,
        message: 'Revenue analytics retrieved',
      };
    } catch (error) {
      this.logger.error(`Error getting revenue analytics: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'REVENUE_ANALYTICS_ERROR',
      };
    }
  }

  /**
   * GET /api/analytics/metrics
   * Get key metrics summary
   */
  @Get('metrics')
  async getKeyMetrics() {
    try {
      const data = await this.analyticsService.getKeyMetrics();

      return {
        success: true,
        data,
        message: 'Key metrics retrieved',
      };
    } catch (error) {
      this.logger.error(`Error getting key metrics: ${error.message}`);
      return {
        success: false,
        error: error.message,
        code: 'METRICS_ERROR',
      };
    }
  }
}
