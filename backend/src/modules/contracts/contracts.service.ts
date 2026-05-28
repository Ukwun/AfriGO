import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Contract } from './entities/contract.entity';
import { ContractAmendment } from './entities/contract-amendment.entity';
import {
  CreateContractDTO,
  SignContractDTO,
  AmendContractDTO,
  ApproveAmendmentDTO,
  InitiateDisputeDTO,
} from './dto/contract.dto';
import { RFQ } from '../rfq/rfq.entity';
import { Lot } from '../lots/lot.entity';
import { User } from '../users/user.entity';

@Injectable()
export class ContractService {
  constructor(
    @InjectRepository(Contract)
    private contractRepository: Repository<Contract>,
    @InjectRepository(ContractAmendment)
    private amendmentRepository: Repository<ContractAmendment>,
    @InjectRepository(RFQ)
    private rfqRepository: Repository<RFQ>,
    @InjectRepository(Lot)
    private lotRepository: Repository<Lot>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  /**
   * Auto-generate contract from RFQ award
   * Called when RFQ winner is selected
   */
  async autoGenerateFromRFQ(rfqId: string, winnerId: string): Promise<Contract> {
    const rfq = await this.rfqRepository.findOne({
      where: { id: rfqId },
      relations: ['buyer', 'lot'],
    });

    if (!rfq) throw new NotFoundException('RFQ not found');
    if (!rfq.lot) throw new BadRequestException('RFQ must reference a lot');

    const seller = await this.userRepository.findOne({ where: { id: winnerId } });
    if (!seller) throw new NotFoundException('Seller not found');

    // Get lot for quality requirements
    const lot = await this.lotRepository.findOne({
      where: { id: rfq.lot.id },
    });

    // Auto-determine contract template based on product type and country
    const templateName = this._selectTemplate(lot);

    // Create contract from RFQ
    const contract = this.contractRepository.create({
      rfqId: rfq.id,
      lotId: rfq.lot.id,
      buyerId: rfq.buyerId,
      sellerId: winnerId,
      contractType: 'standard',
      templateName,
      totalValue: rfq.totalBudget,
      totalQuantity: rfq.quantityNeeded,
      unit: lot.unit,
      currency: 'USD',
      pricePerUnit: rfq.totalBudget / rfq.quantityNeeded,
      requiredGrade: lot.gradeLevel || 'B',
      qualitySpecifications: JSON.stringify({
        gradeLevel: lot.gradeLevel,
        moistureContent: '8-12%',
        aflatoxin: '<5ppb',
        foreignMatter: '<0.5%',
      }),
      deliveryTerms: rfq.deliveryLocation ? `CIF ${rfq.deliveryLocation}` : 'FOB Origin',
      paymentMethod: 'escrow',
      depositPercentage: 30,
      installmentCount: 2,
      paymentDuesDays: 7,
      signatureDeadline: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
      deliveryStartDate: rfq.requiredDate,
      deliveryEndDate: new Date(rfq.requiredDate.getTime() + 30 * 24 * 60 * 60 * 1000), // 30 days
      expiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000), // 1 year
      insuranceRequired: false,
      phytosanitaryCertificateRequired: lot.requiresExportDocumentation || false,
      status: 'draft',
    });

    return await this.contractRepository.save(contract);
  }

  /**
   * Create custom contract
   */
  async createContract(dto: CreateContractDTO): Promise<Contract> {
    // Verify all referenced entities exist
    const lot = await this.lotRepository.findOne({ where: { id: dto.lotId } });
    if (!lot) throw new NotFoundException('Lot not found');

    const buyer = await this.userRepository.findOne({ where: { id: dto.buyerId } });
    if (!buyer) throw new NotFoundException('Buyer not found');

    const seller = await this.userRepository.findOne({ where: { id: dto.sellerId } });
    if (!seller) throw new NotFoundException('Seller not found');

    // Validate dates
    if (new Date(dto.signatureDeadline) < new Date()) {
      throw new BadRequestException('Signature deadline must be in the future');
    }

    if (new Date(dto.deliveryStartDate) >= new Date(dto.deliveryEndDate)) {
      throw new BadRequestException('Delivery start must be before end date');
    }

    const contract = this.contractRepository.create(dto);
    contract.status = 'draft';

    return await this.contractRepository.save(contract);
  }

  /**
   * Sign contract (buyer or seller)
   */
  async signContract(
    contractId: string,
    userId: string,
    dto: SignContractDTO,
  ): Promise<Contract> {
    const contract = await this.contractRepository.findOne({
      where: { id: contractId },
      relations: ['buyer', 'seller'],
    });

    if (!contract) throw new NotFoundException('Contract not found');
    if (contract.status !== 'draft') {
      throw new BadRequestException('Only draft contracts can be signed');
    }

    const isBuyer = contract.buyerId === userId;
    const isSeller = contract.sellerId === userId;

    if (!isBuyer && !isSeller) {
      throw new BadRequestException('Only buyer and seller can sign');
    }

    // Signature deadline check
    if (new Date() > contract.signatureDeadline) {
      throw new BadRequestException('Signature deadline has passed');
    }

    if (isBuyer) {
      contract.buyerSigned = true;
      contract.buyerSignedAt = new Date();
      contract.buyerSignature = dto.signature;
    } else {
      contract.sellerSigned = true;
      contract.sellerSignedAt = new Date();
      contract.sellerSignature = dto.signature;
    }

    // If both signed, activate contract
    if (contract.buyerSigned && contract.sellerSigned) {
      contract.status = 'signed';
    }

    return await this.contractRepository.save(contract);
  }

  /**
   * Submit amendment proposal
   */
  async submitAmendment(contractId: string, userId: string, dto: AmendContractDTO): Promise<ContractAmendment> {
    const contract = await this.contractRepository.findOne({
      where: { id: contractId },
    });

    if (!contract) throw new NotFoundException('Contract not found');

    // Only buyer/seller can amend
    const isParty = contract.buyerId === userId || contract.sellerId === userId;
    if (!isParty) throw new BadRequestException('Only parties to contract can propose amendments');

    // Apply proposed changes to build the changes object
    const proposedChanges: any = {};
    if (dto.newPrice) proposedChanges.pricePerUnit = dto.newPrice;
    if (dto.newQuantity) proposedChanges.totalQuantity = dto.newQuantity;
    if (dto.newDeliveryDate) proposedChanges.deliveryEndDate = dto.newDeliveryDate;
    if (dto.newQuality) proposedChanges.requiredGrade = dto.newQuality;

    const amendment = this.amendmentRepository.create({
      contractId,
      submittedBy: userId,
      reason: dto.reason,
      description: dto.description,
      proposedChanges: JSON.stringify(proposedChanges),
      status: 'pending',
    });

    return await this.amendmentRepository.save(amendment);
  }

  /**
   * Approve or reject amendment
   */
  async approveAmendment(
    amendmentId: string,
    userId: string,
    dto: ApproveAmendmentDTO,
  ): Promise<ContractAmendment> {
    const amendment = await this.amendmentRepository.findOne({
      where: { id: amendmentId },
      relations: ['contract'],
    });

    if (!amendment) throw new NotFoundException('Amendment not found');
    if (amendment.status !== 'pending') {
      throw new BadRequestException('Only pending amendments can be approved');
    }

    const contract = amendment.contract;
    const isBuyer = contract.buyerId === userId;
    const isSeller = contract.sellerId === userId;

    if (!isBuyer && !isSeller) {
      throw new BadRequestException('Only parties can approve amendments');
    }

    if (dto.approved) {
      // Mark approval
      if (isBuyer) amendment.buyerApproved = true;
      else amendment.sellerApproved = true;

      // If both approved, apply changes
      if (amendment.buyerApproved && amendment.sellerApproved) {
        amendment.status = 'approved';
        amendment.approvedAt = new Date();

        // Apply proposed changes to contract
        const changes = JSON.parse(amendment.proposedChanges || '{}');
        Object.assign(contract, changes);
        await this.contractRepository.save(contract);

        contract.amendmentCount++;
      }
    } else {
      // Rejection
      amendment.status = 'rejected';
      amendment.rejectionReason = dto.rejectionReason;
    }

    return await this.amendmentRepository.save(amendment);
  }

  /**
   * Initiate dispute
   */
  async initiateDispute(
    contractId: string,
    userId: string,
    dto: InitiateDisputeDTO,
  ): Promise<Contract> {
    const contract = await this.contractRepository.findOne({
      where: { id: contractId },
    });

    if (!contract) throw new NotFoundException('Contract not found');

    const isParty = contract.buyerId === userId || contract.sellerId === userId;
    if (!isParty) throw new BadRequestException('Only parties can initiate dispute');

    contract.isDisputed = true;
    contract.disputeReason = dto.disputeReason;
    contract.status = 'disputed';

    // Assign mediator if provided
    if (dto.preferredMediatorId) {
      contract.mediatorId = dto.preferredMediatorId;
    }

    return await this.contractRepository.save(contract);
  }

  /**
   * Resolve dispute
   */
  async resolveDispute(
    contractId: string,
    mediatorId: string,
    newStatus: 'active' | 'terminated',
    adjustments?: Partial<Contract>,
  ): Promise<Contract> {
    const contract = await this.contractRepository.findOne({
      where: { id: contractId },
    });

    if (!contract) throw new NotFoundException('Contract not found');
    if (!contract.isDisputed) throw new BadRequestException('Contract is not in dispute');

    contract.isDisputed = false;
    contract.disputeReason = null;
    contract.status = newStatus;

    // Apply mediator adjustments if provided
    if (adjustments) {
      Object.assign(contract, adjustments);
    }

    return await this.contractRepository.save(contract);
  }

  /**
   * Get contract by ID
   */
  async getContractById(id: string): Promise<Contract> {
    const contract = await this.contractRepository.findOne({
      where: { id },
      relations: ['lot', 'rfq', 'buyer', 'seller', 'amendments'],
    });

    if (!contract) throw new NotFoundException('Contract not found');
    return contract;
  }

  /**
   * List contracts with filters
   */
  async listContracts(
    userId?: string,
    status?: string,
    contractType?: string,
    limit: number = 20,
    offset: number = 0,
  ): Promise<{ data: Contract[]; total: number }> {
    let query = this.contractRepository.createQueryBuilder('contract');

    if (userId) {
      query = query.where(
        '(contract.buyerId = :userId OR contract.sellerId = :userId)',
        { userId },
      );
    }

    if (status) {
      query = query.andWhere('contract.status = :status', { status });
    }

    if (contractType) {
      query = query.andWhere('contract.contractType = :contractType', { contractType });
    }

    const total = await query.getCount();
    const data = await query
      .leftJoinAndSelect('contract.buyer', 'buyer')
      .leftJoinAndSelect('contract.seller', 'seller')
      .leftJoinAndSelect('contract.lot', 'lot')
      .orderBy('contract.createdAt', 'DESC')
      .limit(limit)
      .offset(offset)
      .getMany();

    return { data, total };
  }

  /**
   * Get amendments for contract
   */
  async getContractAmendments(contractId: string): Promise<ContractAmendment[]> {
    return await this.amendmentRepository.find({
      where: { contractId },
      relations: ['submittedByUser'],
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Generate contract terms summary as text
   */
  async generateContractSummary(contractId: string): Promise<string> {
    const contract = await this.getContractById(contractId);

    const summary = `
CONTRACT SUMMARY
===============
ID: ${contract.id}
Type: ${contract.contractType.toUpperCase()}
Status: ${contract.status.toUpperCase()}

PARTIES
-------
Buyer: ${contract.buyer.firstName} ${contract.buyer.lastName}
Seller: ${contract.seller.firstName} ${contract.seller.lastName}

PRODUCT & QUALITY
-----------------
Lot ID: ${contract.lotId}
Quantity: ${contract.totalQuantity} ${contract.unit}
Price per Unit: ${contract.currency} ${contract.pricePerUnit}
Total Value: ${contract.currency} ${contract.totalValue}
Required Grade: ${contract.requiredGrade}

PAYMENT TERMS
-------------
Method: ${contract.paymentMethod.replace(/_/g, ' ').toUpperCase()}
Deposit: ${contract.depositPercentage}%
${contract.installmentCount ? `Installments: ${contract.installmentCount}` : ''}

DELIVERY
--------
Start: ${contract.deliveryStartDate.toDateString()}
End: ${contract.deliveryEndDate.toDateString()}
Terms: ${contract.deliveryTerms}

SIGNATURES
----------
Buyer Signed: ${contract.buyerSigned ? 'YES ✓' : 'NO'}
Seller Signed: ${contract.sellerSigned ? 'YES ✓' : 'NO'}
Signature Deadline: ${contract.signatureDeadline.toDateString()}

AMENDMENTS: ${contract.amendmentCount}
DISPUTE: ${contract.isDisputed ? 'YES - UNDER MEDIATION' : 'NO'}
    `;

    return summary.trim();
  }

  /**
   * Helper: Select template based on product
   */
  private _selectTemplate(lot: Lot): string {
    // Product type + country = template
    const productType = lot.productName || 'commodities';
    const country = lot.originCountry || 'Ghana';
    const year = new Date().getFullYear();

    return `${productType}_StandardTerms_${country}_${year}`;
  }

  /**
   * Helper: Calculate grace days for signatures
   */
  private _calculateGraceDays(deadline: Date): number {
    const daysLeft = Math.floor(
      (deadline.getTime() - Date.now()) / (24 * 60 * 60 * 1000),
    );
    return Math.max(0, daysLeft);
  }

  /**
   * Archive/Terminate contract
   */
  async terminateContract(
    contractId: string,
    userId: string,
    reason: string,
  ): Promise<Contract> {
    const contract = await this.contractRepository.findOne({
      where: { id: contractId },
    });

    if (!contract) throw new NotFoundException('Contract not found');

    const isParty = contract.buyerId === userId || contract.sellerId === userId;
    if (!isParty) throw new BadRequestException('Only parties can terminate');

    contract.status = 'terminated';
    contract.additionalTerms = reason;

    return await this.contractRepository.save(contract);
  }
}
