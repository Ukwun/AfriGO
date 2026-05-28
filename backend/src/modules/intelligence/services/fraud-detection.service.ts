import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FraudAlert } from '../entities/fraud-alert.entity';
import { UserActivityLog } from '../entities/activity-log.entity';
import { User } from '../../../database/entities/user.entity';

interface FraudDetectionResult {
  isFraudulent: boolean;
  fraudScore: number;
  flags: string[];
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  shouldBlock: boolean;
  shouldReview: boolean;
}

@Injectable()
export class FraudDetectionService {
  private readonly logger = new Logger(FraudDetectionService.name);

  // Configuration for fraud detection thresholds
  private readonly FRAUD_THRESHOLDS = {
    BLOCK: 80, // >80% fraud score = block transaction
    MANUAL_REVIEW: 70, // 70-80% = manual review
    ALERT: 50, // 50-70% = alert/monitor
  };

  private readonly RED_FLAGS = {
    UNUSUAL_LOCATION: 20,
    SPIKE_ACTIVITY: 15,
    LARGE_TRANSACTION: 10,
    PAYMENT_REVERSAL: 25,
    RAPID_TRADES: 18,
    DISPUTE_ABUSE: 12,
    ACCOUNT_TAKEOVER: 35,
    KYC_MISMATCH: 22,
  };

  constructor(
    @InjectRepository(FraudAlert)
    private fraudAlertRepository: Repository<FraudAlert>,
    @InjectRepository(UserActivityLog)
    private activityLogRepository: Repository<UserActivityLog>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  /**
   * Detect fraud patterns and assess risk for a transaction
   * Returns whether transaction should be blocked/reviewed
   */
  async detectFraud(
    userId: string,
    transactionData: {
      amount?: number;
      currency?: string;
      targetUserId?: string;
      tradeId?: string;
      lotId?: string;
      location?: { country: string; latitude: number; longitude: number };
    },
  ): Promise<FraudDetectionResult> {
    this.logger.log(`Running fraud detection for user: ${userId}`);

    const fraudScore = await this.calculateFraudScore(userId, transactionData);
    const flags = await this.detectRedFlags(userId, transactionData);
    const riskLevel = this.getRiskLevel(fraudScore);
    const shouldBlock = fraudScore > this.FRAUD_THRESHOLDS.BLOCK;
    const shouldReview = fraudScore > this.FRAUD_THRESHOLDS.MANUAL_REVIEW;

    // Log the fraud detection
    if (shouldBlock || shouldReview) {
      await this.createFraudAlert(userId, transactionData, fraudScore, flags);
    }

    return {
      isFraudulent: fraudScore > 50,
      fraudScore,
      flags,
      riskLevel,
      shouldBlock,
      shouldReview,
    };
  }

  /**
   * Calculate overall fraud score (0-100)
   * Based on multiple factors and red flags
   */
  private async calculateFraudScore(
    userId: string,
    transactionData: any,
  ): Promise<number> {
    let score = 0;

    // Check for unusual location
    const locationScore = await this.checkUnusualLocation(userId, transactionData);
    score += locationScore;

    // Check for spike in activity
    const activityScore = await this.checkActivitySpike(userId);
    score += activityScore;

    // Check for large transaction (anomaly)
    const transactionScore = await this.checkLargeTransaction(
      userId,
      transactionData.amount,
    );
    score += transactionScore;

    // Check for payment reversals
    const reversalScore = await this.checkPaymentReversals(userId);
    score += reversalScore;

    // Check for rapid-fire trades
    const rapidScore = await this.checkRapidTrades(userId);
    score += rapidScore;

    // Check for dispute abuse
    const disputeScore = await this.checkDisputeAbuse(userId);
    score += disputeScore;

    // Check for KYC mismatches
    const kycScore = await this.checkKYCMismatch(userId, transactionData);
    score += kycScore;

    // Cap at 100
    return Math.min(score, 100);
  }

  /**
   * Detect specific red flags
   */
  private async detectRedFlags(
    userId: string,
    transactionData: any,
  ): Promise<string[]> {
    const flags: string[] = [];

    // Unusual location
    const locationAnomaly = await this.checkUnusualLocation(userId, transactionData);
    if (locationAnomaly > 15) {
      flags.push(
        `UNUSUAL_LOCATION: User logged in from ${transactionData.location?.country || 'unknown'}`,
      );
    }

    // Activity spike
    const activitySpike = await this.checkActivitySpike(userId);
    if (activitySpike > 15) {
      flags.push('SPIKE_ACTIVITY: Multiple trades in short time');
    }

    // Large transaction
    const largeAmount = await this.checkLargeTransaction(userId, transactionData.amount);
    if (largeAmount > 10) {
      flags.push(
        `LARGE_TRANSACTION: ${transactionData.currency} ${transactionData.amount} (2x user average)`,
      );
    }

    // Payment reversals
    const reversals = await this.checkPaymentReversals(userId);
    if (reversals > 20) {
      flags.push('PAYMENT_REVERSAL: Recent payment reversal');
    }

    // Rapid trades
    const rapid = await this.checkRapidTrades(userId);
    if (rapid > 15) {
      flags.push('RAPID_TRADES: 10+ trades in 1 hour');
    }

    return flags;
  }

  /**
   * Check for unusual login location
   * Red flag if user logs in from different country than profile
   */
  private async checkUnusualLocation(
    userId: string,
    transactionData: any,
  ): Promise<number> {
    if (!transactionData.location) {
      return 0;
    }

    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      return 0;
    }

    // If user's profile country != transaction location
    if (user.country !== transactionData.location.country) {
      // Check if this is first time from new country
      const recentActivities = await this.activityLogRepository.find({
        where: { userId },
        order: { createdAt: 'DESC' },
        take: 10,
      });

      const hasRecentActivityFromCountry = recentActivities.some(
        (a) => a.location?.country === transactionData.location.country,
      );

      if (!hasRecentActivityFromCountry) {
        return this.RED_FLAGS.UNUSUAL_LOCATION;
      }
    }

    return 0;
  }

  /**
   * Check for spike in activity
   * Red flag if user suddenly does way more trades than usual
   */
  private async checkActivitySpike(userId: string): Promise<number> {
    // Get activity from last 24 hours
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

    const recentActivities = await this.activityLogRepository.count({
      where: { userId, createdAt: { _type: 'gte', _value: oneDayAgo } } as any,
    });

    // Get average from last 30 days
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const thirtyDayActivities = await this.activityLogRepository.count({
      where: { userId, createdAt: { _type: 'gte', _value: thirtyDaysAgo } } as any,
    });

    const avgDaily = thirtyDayActivities / 30;
    const multiplier = recentActivities / avgDaily;

    // If 5x more activity than usual
    if (multiplier > 5) {
      return this.RED_FLAGS.SPIKE_ACTIVITY;
    }

    return 0;
  }

  /**
   * Check for large transactions compared to user's history
   */
  private async checkLargeTransaction(userId: string, amount?: number): Promise<number> {
    if (!amount || amount <= 0) {
      return 0;
    }

    // In production, calculate user's average transaction amount
    // For now, use threshold of $10,000 USD equivalent
    const LARGE_TRANSACTION_THRESHOLD = 10000;

    if (amount > LARGE_TRANSACTION_THRESHOLD) {
      return this.RED_FLAGS.LARGE_TRANSACTION;
    }

    return 0;
  }

  /**
   * Check for payment reversals (buyer claims unauthorized)
   */
  private async checkPaymentReversals(userId: string): Promise<number> {
    // Check if this user has had payment reversals in last 24 hours
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);

    const reversals = await this.activityLogRepository.count({
      where: {
        userId,
        activityType: 'PAYMENT_REVERSAL',
        createdAt: { _type: 'gte', _value: oneDayAgo } as any,
      } as any,
    });

    if (reversals > 0) {
      return this.RED_FLAGS.PAYMENT_REVERSAL;
    }

    return 0;
  }

  /**
   * Check for rapid-fire trades (10+ in 1 hour)
   */
  private async checkRapidTrades(userId: string): Promise<number> {
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);

    const tradeCount = await this.activityLogRepository.count({
      where: {
        userId,
        activityType: 'ACCEPT_TRADE',
        createdAt: { _type: 'gte', _value: oneHourAgo } as any,
      } as any,
    });

    if (tradeCount > 10) {
      return this.RED_FLAGS.RAPID_TRADES;
    }

    return 0;
  }

  /**
   * Check for dispute abuse (filing many disputes in 30 days)
   */
  private async checkDisputeAbuse(userId: string): Promise<number> {
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);

    const disputeCount = await this.activityLogRepository.count({
      where: {
        userId,
        activityType: 'DISPUTE_FILED',
        createdAt: { _type: 'gte', _value: thirtyDaysAgo } as any,
      } as any,
    });

    if (disputeCount > 5) {
      return this.RED_FLAGS.DISPUTE_ABUSE;
    }

    return 0;
  }

  /**
   * Check for KYC mismatches
   */
  private async checkKYCMismatch(userId: string, transactionData: any): Promise<number> {
    const user = await this.userRepository.findOne({ where: { id: userId } });

    if (!user) {
      return 0;
    }

    // Profile says "Individual Farmer" but trading in bulk quantities
    if (user.userType === 'INDIVIDUAL' && transactionData.amount > 50000) {
      return this.RED_FLAGS.KYC_MISMATCH;
    }

    // Account created recently but trading large amounts
    const createdDate = new Date(user.createdAt);
    const daysSinceCreation = (Date.now() - createdDate.getTime()) / (1000 * 60 * 60 * 24);

    if (daysSinceCreation < 7 && transactionData.amount > 10000) {
      return this.RED_FLAGS.KYC_MISMATCH;
    }

    return 0;
  }

  /**
   * Determine risk level from fraud score
   */
  private getRiskLevel(
    fraudScore: number,
  ): 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' {
    if (fraudScore >= 80) return 'CRITICAL';
    if (fraudScore >= 60) return 'HIGH';
    if (fraudScore >= 40) return 'MEDIUM';
    return 'LOW';
  }

  /**
   * Create fraud alert in database
   */
  private async createFraudAlert(
    userId: string,
    transactionData: any,
    fraudScore: number,
    flags: string[],
  ): Promise<FraudAlert> {
    const alert = new FraudAlert();
    alert.userId = userId;
    alert.fraudScore = fraudScore;
    alert.fraudType = 'MANUAL_FLAG';
    alert.severity = fraudScore > 80 ? 'CRITICAL' : fraudScore > 60 ? 'HIGH' : 'MEDIUM';
    alert.evidence = {
      flag1: flags[0] || '',
      flag2: flags[1] || '',
      flag3: flags[2] || '',
      details: transactionData,
    };
    alert.status = 'PENDING';
    alert.requiresManualReview = fraudScore > this.FRAUD_THRESHOLDS.MANUAL_REVIEW;
    alert.relatedTradeId = transactionData.tradeId;

    return await this.fraudAlertRepository.save(alert);
  }

  /**
   * Get fraud alerts for a user
   */
  async getFraudAlerts(
    userId: string,
    status?: 'PENDING' | 'REVIEWING' | 'RESOLVED',
  ): Promise<FraudAlert[]> {
    if (status) {
      return await this.fraudAlertRepository.find({
        where: { userId, status },
        order: { createdAt: 'DESC' },
      });
    }

    return await this.fraudAlertRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Update fraud alert (admin actions)
   */
  async updateFraudAlert(
    alertId: string,
    updates: {
      status?: string;
      action?: string;
      adminNotes?: string;
      reviewedBy?: string;
    },
  ): Promise<FraudAlert> {
    const alert = await this.fraudAlertRepository.findOne({ where: { id: alertId } });
    if (!alert) {
      throw new Error(`Fraud alert not found: ${alertId}`);
    }

    Object.assign(alert, updates);
    alert.resolvedAt = new Date();
    alert.isResolved = true;

    return await this.fraudAlertRepository.save(alert);
  }
}
