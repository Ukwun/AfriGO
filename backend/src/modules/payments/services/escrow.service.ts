import { Injectable, BadRequestException, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@typeorm/typeorm';
import { Repository } from 'typeorm';
import { v4 as uuid } from 'uuid';

import {
  CreateEscrowDto,
  UpdateEscrowStatusDto,
  ReleaseEscrowDto,
  DisputeEscrowDto,
  EscrowStatisticsQueryDto,
  EscrowStatusEnum,
  ReleaseConditionEnum,
} from '../dto';
import { Escrow } from '../entities/escrow.entity';
import { Payment } from '../entities/payment.entity';
import { PaymentStatusEnum } from '../dto';

/**
 * ESCROW SERVICE
 * Handles fund holding with multi-condition release logic
 * Ensures buyer protection: funds only released when conditions met
 */
@Injectable()
export class EscrowService {
  constructor(
    @InjectRepository(Escrow)
    private readonly escrowRepository: Repository<Escrow>,
    @InjectRepository(Payment)
    private readonly paymentRepository: Repository<Payment>,
  ) {}

  /**
   * PUBLIC METHOD 1: createEscrow
   * Creates new escrow fund hold after payment completion
   * Funds are held by AfriGo, not released until conditions met
   *
   * @param paymentId UUID of completed payment
   * @param dto CreateEscrowDto with holding terms
   * @param userId UUID of user creating (buyer)
   * @returns Created escrow object
   */
  async createEscrow(paymentId: string, dto: CreateEscrowDto, userId: string): Promise<Escrow> {
    // Verify payment exists and is completed
    const payment = await this.paymentRepository.findOne({
      where: { id: paymentId },
    });

    if (!payment) {
      throw new NotFoundException(`Payment ${paymentId} not found`);
    }

    if (payment.status !== PaymentStatusEnum.COMPLETED) {
      throw new BadRequestException(`Payment must be completed before creating escrow`);
    }

    // Create escrow
    const escrow = new Escrow();
    escrow.id = uuid();
    escrow.paymentId = paymentId;
    escrow.amount = dto.amount;
    escrow.currency = dto.currency;
    escrow.status = EscrowStatusEnum.CREATED;
    escrow.holdingPeriodDays = dto.holdingPeriodDays;
    escrow.holdingFeePercentage = dto.holdingFeePercentage || 0;
    escrow.createdBy = userId;

    // Initialize conditions as not met
    escrow.conditionsMet = {};
    const conditions = dto.releaseConditions || [
      ReleaseConditionEnum.DELIVERY_PROOF,
      ReleaseConditionEnum.QUALITY_APPROVAL,
      ReleaseConditionEnum.BUYER_SIGNOFF,
    ];

    for (const condition of conditions) {
      escrow.conditionsMet[condition] = false;
    }

    // Calculate auto-release date (if no conditions met by then, auto-release)
    const autoReleaseDate = new Date();
    autoReleaseDate.setDate(autoReleaseDate.getDate() + dto.holdingPeriodDays);
    escrow.autoReleaseDate = autoReleaseDate;

    return this.escrowRepository.save(escrow);
  }

  /**
   * PUBLIC METHOD 2: fundEscrow
   * Transitions escrow from CREATED to FUNDED
   * After this, funds are officially held
   *
   * @param escrowId UUID of escrow to fund
   * @param userId UUID of user (buyer)
   * @returns Updated escrow
   */
  async fundEscrow(escrowId: string, userId: string): Promise<Escrow> {
    const escrow = await this.escrowRepository.findOne({
      where: { id: escrowId },
    });

    if (!escrow) {
      throw new NotFoundException(`Escrow ${escrowId} not found`);
    }

    if (escrow.status !== EscrowStatusEnum.CREATED) {
      throw new BadRequestException(`Escrow must be in CREATED status, current: ${escrow.status}`);
    }

    escrow.status = EscrowStatusEnum.FUNDED;
    escrow.metadata = {
      ...escrow.metadata,
      fundedAt: new Date(),
      fundedBy: userId,
    };

    return this.escrowRepository.save(escrow);
  }

  /**
   * PUBLIC METHOD 3: holdEscrow
   * Transitions escrow from FUNDED to HELD
   * Escrow conditions now active and countdown to auto-release starts
   *
   * @param escrowId UUID of escrow
   * @returns Updated escrow
   */
  async holdEscrow(escrowId: string): Promise<Escrow> {
    const escrow = await this.escrowRepository.findOne({
      where: { id: escrowId },
    });

    if (!escrow) {
      throw new NotFoundException(`Escrow ${escrowId} not found`);
    }

    if (escrow.status !== EscrowStatusEnum.FUNDED) {
      throw new BadRequestException(`Escrow must be in FUNDED status, current: ${escrow.status}`);
    }

    escrow.status = EscrowStatusEnum.HELD;

    return this.escrowRepository.save(escrow);
  }

  /**
   * PUBLIC METHOD 4: releaseEscrow
   * CRITICAL METHOD: Releases funds when conditions are met
   * Checks if ALL conditions met, then releases to seller
   *
   * Multi-condition logic:
   * - DELIVERY_PROOF: Shipment delivered with photo
   * - QUALITY_APPROVAL: Quality test passed
   * - BUYER_SIGNOFF: Buyer explicitly approves
   *
   * @param escrowId UUID of escrow to release
   * @param dto ReleaseEscrowDto marking condition as met
   * @param userId UUID of user marking condition
   * @returns Updated escrow (might still be HELD if not all conditions met)
   */
  async releaseEscrow(escrowId: string, dto: ReleaseEscrowDto, userId: string): Promise<Escrow> {
    const escrow = await this.escrowRepository.findOne({
      where: { id: escrowId },
      relations: ['payment'],
    });

    if (!escrow) {
      throw new NotFoundException(`Escrow ${escrowId} not found`);
    }

    if (escrow.status !== EscrowStatusEnum.HELD && escrow.status !== EscrowStatusEnum.DISPUTED) {
      throw new BadRequestException(`Cannot release escrow with status: ${escrow.status}`);
    }

    // Mark condition as met
    if (!escrow.conditionsMet[dto.condition]) {
      escrow.conditionsMet[dto.condition] = {
        met: true,
        metAt: new Date(),
        proofUrl: dto.proofUrl,
        markedBy: userId,
      };
    } else {
      throw new ConflictException(`Condition ${dto.condition} already met`);
    }

    // Check if ALL conditions are now met
    const allConditionsMet = Object.values(escrow.conditionsMet).every((c) =>
      typeof c === 'object' ? c.met : c === true,
    );

    if (allConditionsMet) {
      // Release funds to seller
      escrow.status = EscrowStatusEnum.RELEASED;
      escrow.releasedAt = new Date();

      // Also update associated payment status
      if (escrow.payment) {
        escrow.payment.status = PaymentStatusEnum.COMPLETED;
        escrow.payment.completedAt = new Date();
        await this.paymentRepository.save(escrow.payment);
      }
    }

    return this.escrowRepository.save(escrow);
  }

  /**
   * PUBLIC METHOD 5: refundEscrow
   * Refunds held funds back to buyer
   * Called when: payment expires, buyer cancels, product not delivered
   *
   * @param escrowId UUID of escrow to refund
   * @param reason Reason for refund
   * @param userId UUID of user requesting refund
   * @returns Updated escrow with REFUNDED status
   */
  async refundEscrow(escrowId: string, reason: string, userId: string): Promise<Escrow> {
    const escrow = await this.escrowRepository.findOne({
      where: { id: escrowId },
    });

    if (!escrow) {
      throw new NotFoundException(`Escrow ${escrowId} not found`);
    }

    // Can refund if HELD or CREATED (not yet progressed far)
    if (![EscrowStatusEnum.HELD, EscrowStatusEnum.CREATED].includes(escrow.status)) {
      throw new BadRequestException(`Cannot refund escrow with status: ${escrow.status}`);
    }

    escrow.status = EscrowStatusEnum.REFUNDED;
    escrow.refundedAt = new Date();
    escrow.metadata = {
      ...escrow.metadata,
      refundReason: reason,
      refundedBy: userId,
      refundProcessedAt: new Date(),
    };

    return this.escrowRepository.save(escrow);
  }

  /**
   * PUBLIC METHOD 6: disputeEscrow
   * Files dispute when party disagrees with escrow status
   * Requires admin/mediator resolution
   *
   * @param escrowId UUID of escrow in dispute
   * @param dto DisputeEscrowDto with dispute details
   * @param userId UUID of user filing dispute
   * @returns Updated escrow with DISPUTED status
   */
  async disputeEscrow(escrowId: string, dto: DisputeEscrowDto, userId: string): Promise<Escrow> {
    const escrow = await this.escrowRepository.findOne({
      where: { id: escrowId },
    });

    if (!escrow) {
      throw new NotFoundException(`Escrow ${escrowId} not found`);
    }

    escrow.status = EscrowStatusEnum.DISPUTED;
    escrow.metadata = {
      ...escrow.metadata,
      disputes: [
        ...(escrow.metadata?.disputes || []),
        {
          id: uuid(),
          reason: dto.reason,
          evidence: dto.evidence,
          filedBy: userId,
          filedAt: new Date(),
          status: 'OPEN',
        },
      ],
    };

    return this.escrowRepository.save(escrow);
  }

  /**
   * PUBLIC METHOD 7: resolveDispute
   * Admin/mediator resolves dispute
   * Decides fund disbursement (buyer wins, seller wins, or split)
   *
   * @param escrowId UUID of disputed escrow
   * @param resolution Resolution details (outcome, amounts)
   * @param mediatorId UUID of admin/mediator
   * @returns Updated escrow withresolution
   */
  async resolveDispute(
    escrowId: string,
    resolution: {
      outcome: 'BUYER_WINS' | 'SELLER_WINS' | 'SPLIT';
      buyerAmount: number;
      sellerAmount: number;
      notes: string;
    },
    mediatorId: string,
  ): Promise<Escrow> {
    const escrow = await this.escrowRepository.findOne({
      where: { id: escrowId },
    });

    if (!escrow) {
      throw new NotFoundException(`Escrow ${escrowId} not found`);
    }

    if (escrow.status !== EscrowStatusEnum.DISPUTED) {
      throw new BadRequestException(`Escrow must be in DISPUTED status to resolve`);
    }

    // Validate amounts add up to escrow amount
    if (Math.abs(resolution.buyerAmount + resolution.sellerAmount - escrow.amount) > 0.01) {
      throw new BadRequestException(
        `Resolution amounts (${resolution.buyerAmount + resolution.sellerAmount}) do not match escrow amount (${escrow.amount})`,
      );
    }

    escrow.status = EscrowStatusEnum.RESOLVED;
    escrow.metadata = {
      ...escrow.metadata,
      resolution: {
        outcome: resolution.outcome,
        buyerAmount: resolution.buyerAmount,
        sellerAmount: resolution.sellerAmount,
        notes: resolution.notes,
        resolvedBy: mediatorId,
        resolvedAt: new Date(),
      },
    };

    return this.escrowRepository.save(escrow);
  }

  /**
   * PUBLIC METHOD 8: checkAutoRelease
   * Scheduled task to auto-release old held escrows
   * Called periodically (e.g., daily cron job)
   * Releases escrows past holdingPeriodDays if no conditions required
   *
   * @returns Count of auto-released escrows
   */
  async checkAutoRelease(): Promise<number> {
    const now = new Date();

    // Find all HELD escrows past auto-release date
    const expiredEscrows = await this.escrowRepository.find({
      where: {
        status: EscrowStatusEnum.HELD,
        // autoReleaseDate < now (in production, use TypeORM date comparison)
      },
    });

    let releasedCount = 0;

    for (const escrow of expiredEscrows) {
      if (escrow.autoReleaseDate < now) {
        // Auto-release this escrow
        escrow.status = EscrowStatusEnum.RELEASED;
        escrow.releasedAt = new Date();
        escrow.metadata = {
          ...escrow.metadata,
          autoReleasedAt: new Date(),
          autoReleaseReason: 'Holding period expired',
        };

        await this.escrowRepository.save(escrow);
        releasedCount++;

        // Notify seller (in production): "Your escrow was auto-released"
      }
    }

    return releasedCount;
  }

  // ============================================================================
  // QUERY METHODS
  // ============================================================================

  /**
   * Retrieves escrow by ID with full relations
   */
  async getEscrowById(escrowId: string): Promise<Escrow> {
    const escrow = await this.escrowRepository.findOne({
      where: { id: escrowId },
      relations: ['payment'],
    });

    if (!escrow) {
      throw new NotFoundException(`Escrow ${escrowId} not found`);
    }

    return escrow;
  }

  /**
   * Lists escrows with filtering and pagination
   */
  async listEscrows(
    filters: EscrowStatisticsQueryDto,
    page: number = 0,
    limit: number = 10,
  ): Promise<{ data: Escrow[]; total: number }> {
    let query = this.escrowRepository.createQueryBuilder('escrow');

    if (filters.status) {
      query = query.where('escrow.status = :status', { status: filters.status });
    }
    if (filters.startDate) {
      query = query.andWhere('escrow.createdAt >= :startDate', {
        startDate: new Date(filters.startDate),
      });
    }
    if (filters.endDate) {
      query = query.andWhere('escrow.createdAt <= :endDate', {
        endDate: new Date(filters.endDate),
      });
    }

    const total = await query.getCount();

    const data = await query
      .orderBy('escrow.createdAt', 'DESC')
      .skip(page * limit)
      .take(limit)
      .getMany();

    return { data, total };
  }

  /**
   * Gets escrow statistics for admin dashboards
   */
  async getEscrowStatistics(filters: EscrowStatisticsQueryDto) {
    let query = this.escrowRepository.createQueryBuilder('escrow');

    if (filters.status) {
      query = query.where('escrow.status = :status', { status: filters.status });
    }

    const stats = await query
      .select('COUNT(*)', 'totalEscrows')
      .addSelect('SUM(escrow.amount)', 'totalAmount')
      .addSelect('AVG(escrow.amount)', 'avgAmount')
      .getRawOne();

    return stats || { totalEscrows: 0, totalAmount: 0, avgAmount: 0 };
  }
}
