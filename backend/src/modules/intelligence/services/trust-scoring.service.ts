import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TrustScore } from '../entities/trust-score.entity';
import { User } from '../../../database/entities/user.entity';
import { UserActivityLog } from '../entities/activity-log.entity';

interface TrustScoreBreakdown {
  baseScore: number;
  transactionPoints: number;
  profilePoints: number;
  behaviorBonusPoints: number;
  penaltyPoints: number;
  totalScore: number;
  starRating: number;
  trustLevel: string;
}

@Injectable()
export class TrustScoringService {
  private readonly logger = new Logger(TrustScoringService.name);

  constructor(
    @InjectRepository(TrustScore)
    private trustScoreRepository: Repository<TrustScore>,
    @InjectRepository(UserActivityLog)
    private activityLogRepository: Repository<UserActivityLog>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  /**
   * Calculate complete trust score for a user
   * This is the core algorithm that determines user trustworthiness
   *
   * Algorithm:
   * Trust Score = Base (40) + Transaction Points (0-30) + Profile Points (0-20) + Behavior Bonus (0-20) - Penalties
   * Score Range: 0-100
   * Rating: (Score / 100) * 5 stars
   */
  async calculateTrustScore(userId: string): Promise<TrustScoreBreakdown> {
    this.logger.log(`Calculating trust score for user: ${userId}`);

    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new Error(`User not found: ${userId}`);
    }

    // BASE SCORE (everyone starts at 40/100)
    const baseScore = 40;

    // TRANSACTION POINTS (0-30 points max)
    // Users build trust through successful trades
    const transactionData = await this.calculateTransactionPoints(userId);

    // PROFILE POINTS (0-20 points max)
    // Complete profiles are more trustworthy
    const profileData = await this.calculateProfilePoints(userId);

    // BEHAVIOR BONUS (0-20 points max)
    // Good behavior patterns increase trust
    const behaviorData = await this.calculateBehaviorBonus(userId);

    // PENALTIES (deduct points for negative actions)
    const penaltyData = await this.calculatePenalties(userId);

    // FINAL CALCULATION
    const totalScore = Math.max(
      0,
      Math.min(
        100,
        baseScore +
          transactionData.points +
          profileData.points +
          behaviorData.points -
          penaltyData.points,
      ),
    );

    const starRating = (totalScore / 100) * 5;

    // Determine trust level
    const trustLevel = this.determineTrustLevel(totalScore);

    const breakdown: TrustScoreBreakdown = {
      baseScore,
      transactionPoints: transactionData.points,
      profilePoints: profileData.points,
      behaviorBonusPoints: behaviorData.points,
      penaltyPoints: penaltyData.points,
      totalScore,
      starRating,
      trustLevel,
    };

    this.logger.log(`Trust score calculated: ${totalScore}/100 (${starRating} stars)`);

    // Save to database
    return await this.saveTrustScore(userId, breakdown);
  }

  /**
   * Calculate transaction points (0-30 max)
   * +2 points per completed trade (capped at +20)
   * +1 point per successful payment (capped at +10)
   */
  private async calculateTransactionPoints(
    userId: string,
  ): Promise<{ points: number; breakdown: any }> {
    // Count completed trades (from trading module)
    // For now, mock this - in production fetch from trades table
    const completedTrades = 0; // Replace with actual count
    const tradePoints = Math.min(completedTrades * 2, 20);

    // Count successful payments
    // For now, mock this - in production fetch from payments table
    const successfulPayments = 0; // Replace with actual count
    const paymentPoints = Math.min(successfulPayments * 1, 10);

    return {
      points: tradePoints + paymentPoints,
      breakdown: { completedTrades, tradePoints, successfulPayments, paymentPoints },
    };
  }

  /**
   * Calculate profile points (0-20 max)
   * +3 points for email verified
   * +3 points for phone verified
   * +2 points for profile 100% complete
   * +8 points for KYC verified
   */
  private async calculateProfilePoints(
    userId: string,
  ): Promise<{ points: number; breakdown: any }> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      return { points: 0, breakdown: {} };
    }

    let points = 0;
    const breakdown: any = {};

    // Email verification
    if (user.emailVerified) {
      points += 3;
      breakdown.emailVerified = 3;
    }

    // Phone verification
    if (user.phoneVerified) {
      points += 3;
      breakdown.phoneVerified = 3;
    }

    // Profile completeness (check if all required fields filled)
    const isProfileComplete =
      user.firstName &&
      user.lastName &&
      user.email &&
      user.phoneNumber &&
      user.country;

    if (isProfileComplete) {
      points += 2;
      breakdown.profileComplete = 2;
    }

    // KYC verification
    if (user.kycStatus === 'VERIFIED') {
      points += 8;
      breakdown.kycVerified = 8;
    }

    return {
      points: Math.min(points, 20),
      breakdown,
    };
  }

  /**
   * Calculate behavior bonus (0-20 max)
   * +2 points for <2 hour response time
   * +2 points for zero disputes
   * +3 points per month with no late payments
   */
  private async calculateBehaviorBonus(
    userId: string,
  ): Promise<{ points: number; breakdown: any }> {
    let points = 0;
    const breakdown: any = {};

    // Response time (average time to respond to messages/RFQs)
    // For MVP, we'll set this to 0
    const avgResponseTime = 0; // in minutes
    if (avgResponseTime > 0 && avgResponseTime < 120) {
      points += 2;
      breakdown.responseTime = 2;
    }

    // Disputes (zero disputes is a good sign)
    // Count disputes from disputes table
    const disputeCount = 0; // Replace with actual count
    if (disputeCount === 0) {
      points += 2;
      breakdown.noDisputes = 2;
    }

    // Late payment history (no late payments = good)
    const monthsSinceLastLatePayment = 12; // Assume no recent late payments
    if (monthsSinceLastLatePayment > 3) {
      points += 3;
      breakdown.noLatePayments = 3;
    }

    return {
      points: Math.min(points, 20),
      breakdown,
    };
  }

  /**
   * Calculate penalties (deduct from score)
   * -5 points per late payment
   * -3 points per failed delivery
   * -2 points per dispute filed
   * -5 points per dispute lost
   * -50 points immediate suspension for fraud
   */
  private async calculatePenalties(
    userId: string,
  ): Promise<{ points: number; breakdown: any }> {
    let points = 0;
    const breakdown: any = {};

    // Late payments
    const latePaymentCount = 0; // Replace with actual count
    points += latePaymentCount * 5;
    if (latePaymentCount > 0) {
      breakdown.latePayments = latePaymentCount * 5;
    }

    // Failed deliveries
    const failedDeliveryCount = 0; // Replace with actual count
    points += failedDeliveryCount * 3;
    if (failedDeliveryCount > 0) {
      breakdown.failedDeliveries = failedDeliveryCount * 3;
    }

    // Disputes filed
    const disputesFiled = 0; // Replace with actual count
    points += disputesFiled * 2;
    if (disputesFiled > 0) {
      breakdown.disputesFiled = disputesFiled * 2;
    }

    // Disputes lost
    const disputesLost = 0; // Replace with actual count
    points += disputesLost * 5;
    if (disputesLost > 0) {
      breakdown.disputesLost = disputesLost * 5;
    }

    // Fraud suspension (-50 points)
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (user && user.accountStatus === 'SUSPENDED_FRAUD') {
      points += 50;
      breakdown.fraudSuspension = 50;
    }

    return { points, breakdown };
  }

  /**
   * Determine trust level based on score
   */
  private determineTrustLevel(score: number): string {
    if (score >= 80) return 'EXCELLENT';
    if (score >= 60) return 'GOOD';
    if (score >= 40) return 'NEUTRAL';
    if (score >= 20) return 'LOW';
    return 'CRITICAL';
  }

  /**
   * Save trust score to database
   */
  private async saveTrustScore(
    userId: string,
    breakdown: TrustScoreBreakdown,
  ): Promise<TrustScoreBreakdown> {
    const trustScore = new TrustScore();
    trustScore.userId = userId;
    trustScore.baseScore = breakdown.baseScore;
    trustScore.transactionPoints = breakdown.transactionPoints;
    trustScore.profilePoints = breakdown.profilePoints;
    trustScore.behaviorBonusPoints = breakdown.behaviorBonusPoints;
    trustScore.penaltyPoints = breakdown.penaltyPoints;
    trustScore.totalScore = breakdown.totalScore;
    trustScore.starRating = Number(breakdown.starRating.toFixed(2));
    trustScore.trustLevel = breakdown.trustLevel as any;
    trustScore.components = {
      completedTrades: 0,
      emailVerified: true,
      phoneVerified: false,
      kyc: 'pending' as const,
      responseTime: 0,
      disputes: 0,
      latePayments: 0,
    };

    await this.trustScoreRepository.save(trustScore);
    return breakdown;
  }

  /**
   * Get latest trust score for user
   */
  async getTrustScore(userId: string): Promise<TrustScore | null> {
    return await this.trustScoreRepository.findOne({
      where: { userId },
      order: { calculatedAt: 'DESC' },
    });
  }

  /**
   * Get trust score history
   */
  async getTrustScoreHistory(
    userId: string,
    days: number = 30,
  ): Promise<TrustScore[]> {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    return await this.trustScoreRepository.find({
      where: {
        userId,
        calculatedAt: { _type: 'gte', _value: startDate },
      } as any,
      order: { calculatedAt: 'DESC' },
    });
  }
}
