import { Injectable, BadRequestException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { QualityInspection } from './quality-inspection.entity';
import { LabCertification } from './lab-certification.entity';
import { Lot } from '../lots/lot.entity';
import { User } from '../auth/user.entity';
import {
  CreateQualityInspectionDTO,
  SubmitVisualInspectionDTO,
  SubmitLabTestDTO,
  ApproveQualityInspectionDTO,
  CreateLabCertificationDTO,
  QualityInspectionFilterDTO,
} from './quality.dto';

@Injectable()
export class QualityService {
  constructor(
    @InjectRepository(QualityInspection) private inspectionRepository: Repository<QualityInspection>,
    @InjectRepository(LabCertification) private labRepository: Repository<LabCertification>,
    @InjectRepository(Lot) private lotRepository: Repository<Lot>,
    @InjectRepository(User) private userRepository: Repository<User>,
  ) {}

  /**
   * Create new quality inspection
   */
  async createInspection(dto: CreateQualityInspectionDTO): Promise<QualityInspection> {
    // Verify lot exists
    const lot = await this.lotRepository.findOne({ where: { id: dto.lotId } });
    if (!lot) {
      throw new NotFoundException('Lot not found');
    }

    // Check if inspection already exists
    const existingInspection = await this.inspectionRepository.findOne({
      where: { lotId: dto.lotId, status: 'completed' },
    });

    if (existingInspection && existingInspection.isApproved) {
      throw new BadRequestException('Lot already has approved quality inspection');
    }

    // Create inspection
    const inspection = this.inspectionRepository.create({
      lotId: dto.lotId,
      inspectionType: dto.inspectionType,
      labCertificationId: dto.labCertificationId,
      inspectorId: dto.inspectorId,
      status: 'pending',
      inspectionPhotos: [],
    });

    return this.inspectionRepository.save(inspection);
  }

  /**
   * Submit visual inspection results
   */
  async submitVisualInspection(dto: SubmitVisualInspectionDTO): Promise<QualityInspection> {
    const inspection = await this.inspectionRepository.findOne({
      where: { id: dto.inspectionId },
      relations: ['lot'],
    });

    if (!inspection) {
      throw new NotFoundException('Inspection not found');
    }

    if (inspection.status === 'completed' || inspection.status === 'approved') {
      throw new BadRequestException('Inspection already completed');
    }

    // Update visual inspection data
    inspection.visualGrade = dto.visualGrade;
    inspection.visualDefectPercentage = dto.visualDefectPercentage;
    inspection.visualDefectsFound = dto.visualDefectsFound || [];
    inspection.inspectionPhotos = dto.inspectionPhotos || [];
    inspection.status = 'in_progress';

    // Auto-grade based on defect percentage
    if (dto.visualDefectPercentage > 20) {
      inspection.visualGrade = 'C';
    } else if (dto.visualDefectPercentage > 10) {
      inspection.visualGrade = 'B';
    } else {
      inspection.visualGrade = 'A';
    }

    return this.inspectionRepository.save(inspection);
  }

  /**
   * Submit lab test results
   */
  async submitLabTest(dto: SubmitLabTestDTO): Promise<QualityInspection> {
    const inspection = await this.inspectionRepository.findOne({
      where: { id: dto.inspectionId },
      relations: ['lot', 'labCertification'],
    });

    if (!inspection) {
      throw new NotFoundException('Inspection not found');
    }

    // Validate lab metrics meet standards
    const metrics = {
      moistureContent: dto.moistureContent,
      afflatoxinLevel: dto.afflatoxinLevel,
      foreignMatterPercentage: dto.foreignMatterPercentage,
    };

    // Industry standards for cocoa/coffee
    const gradeFromMetrics = this._determineGradeFromMetrics(metrics);

    // Update inspection with lab data
    inspection.moistureContent = dto.moistureContent;
    inspection.afflatoxinLevel = dto.afflatoxinLevel;
    inspection.foreignMatterPercentage = dto.foreignMatterPercentage;
    inspection.insectFragmentCount = dto.insectFragmentCount;
    inspection.pH = dto.pH;
    inspection.bacterialCount = dto.bacterialCount;
    inspection.status = 'in_progress';

    // Set lab certification if provided
    if (dto.labCertificationId && !inspection.labCertificationId) {
      inspection.labCertificationId = dto.labCertificationId;
    }

    // Tentative grade from lab metrics
    inspection.aiPredictedGrade = gradeFromMetrics;

    return this.inspectionRepository.save(inspection);
  }

  /**
   * Approve/reject inspection and finalize grade
   */
  async approveInspection(dto: ApproveQualityInspectionDTO, approverId: string): Promise<QualityInspection> {
    const inspection = await this.inspectionRepository.findOne({
      where: { id: dto.inspectionId },
      relations: ['lot'],
    });

    if (!inspection) {
      throw new NotFoundException('Inspection not found');
    }

    // Verify approver exists
    const approver = await this.userRepository.findOne({ where: { id: approverId } });
    if (!approver) {
      throw new NotFoundException('Approver not found');
    }

    // Update inspection
    inspection.finalGrade = dto.finalGrade;
    inspection.isApproved = dto.isApproved;
    inspection.approvalNotes = dto.approvalNotes;
    inspection.approvedBy = approverId;
    inspection.approvedAt = new Date();
    inspection.status = dto.isApproved ? 'approved' : 'rejected';
    inspection.completedAt = new Date();

    const saved = await this.inspectionRepository.save(inspection);

    // Update lot with final grade if approved
    if (dto.isApproved) {
      const lot = saved.lot;
      lot.gradeLevel = dto.finalGrade;
      await this.lotRepository.save(lot);
    }

    return saved;
  }

  /**
   * Get inspection by ID
   */
  async getInspectionById(inspectionId: string): Promise<QualityInspection> {
    const inspection = await this.inspectionRepository.findOne({
      where: { id: inspectionId },
      relations: ['lot', 'inspector', 'labCertification', 'approver'],
    });

    if (!inspection) {
      throw new NotFoundException('Inspection not found');
    }

    return inspection;
  }

  /**
   * Get inspections for lot
   */
  async getLotInspections(lotId: string): Promise<QualityInspection[]> {
    return this.inspectionRepository.find({
      where: { lotId },
      relations: ['inspector', 'labCertification', 'approver'],
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * List quality inspections with filtering
   */
  async listInspections(filters: QualityInspectionFilterDTO): Promise<{ data: QualityInspection[]; total: number }> {
    const { status, inspectionType, page = 1, limit = 20 } = filters;

    const query = this.inspectionRepository
      .createQueryBuilder('inspection')
      .leftJoinAndSelect('inspection.lot', 'lot')
      .leftJoinAndSelect('inspection.labCertification', 'lab')
      .leftJoinAndSelect('inspection.inspector', 'inspector');

    if (status) {
      query.andWhere('inspection.status = :status', { status });
    }

    if (inspectionType) {
      query.andWhere('inspection.inspectionType = :inspectionType', { inspectionType });
    }

    const total = await query.getCount();

    const data = await query
      .orderBy('inspection.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    return { data, total };
  }

  /**
   * Register lab certification
   */
  async registerLabCertification(dto: CreateLabCertificationDTO): Promise<LabCertification> {
    // Check if lab already registered
    const existing = await this.labRepository.findOne({
      where: { labCode: dto.labCode },
    });

    if (existing) {
      throw new BadRequestException('Lab with this code already registered');
    }

    const lab = this.labRepository.create({
      labName: dto.labName,
      labCode: dto.labCode,
      country: dto.country,
      certificationNumber: dto.certificationNumber,
      certificationUrl: dto.certificationUrl,
      issuedDate: new Date(dto.issuedDate),
      expiryDate: new Date(dto.expiryDate),
      accreditation: dto.accreditation,
      testingCertifications: dto.testingCertifications,
      contactEmail: dto.contactEmail,
      contactPhone: dto.contactPhone,
      costPerTest: dto.costPerTest || 0,
      status: 'active',
    });

    return this.labRepository.save(lab);
  }

  /**
   * List available labs
   */
  async listLabs(country?: string): Promise<LabCertification[]> {
    const query = this.labRepository
      .createQueryBuilder('lab')
      .where('lab.status = :status', { status: 'active' })
      .andWhere('lab.expiryDate > :now', { now: new Date() });

    if (country) {
      query.andWhere('lab.country = :country', { country });
    }

    return query.orderBy('lab.averageAccuracy', 'DESC').getMany();
  }

  /**
   * Determine grade based on lab metrics
   */
  private _determineGradeFromMetrics(metrics: {
    moistureContent?: number;
    afflatoxinLevel?: number;
    foreignMatterPercentage?: number;
  }): string {
    let score = 100;

    // Moisture content penalty (8-12% is ideal)
    if (metrics.moistureContent !== undefined) {
      if (metrics.moistureContent < 8 || metrics.moistureContent > 12) {
        score -= 15;
      } else if (metrics.moistureContent < 10 || metrics.moistureContent > 11) {
        score -= 5;
      }
    }

    // Aflatoxin level penalty (< 5 ppb is good)
    if (metrics.afflatoxinLevel !== undefined) {
      if (metrics.afflatoxinLevel > 15) {
        score -= 30; // Reject
      } else if (metrics.afflatoxinLevel > 10) {
        score -= 20; // Grade C
      } else if (metrics.afflatoxinLevel > 5) {
        score -= 10; // Grade B
      }
    }

    // Foreign matter penalty (< 0.5% is good)
    if (metrics.foreignMatterPercentage !== undefined) {
      if (metrics.foreignMatterPercentage > 2) {
        score -= 25; // Reject
      } else if (metrics.foreignMatterPercentage > 1) {
        score -= 15; // Grade C
      } else if (metrics.foreignMatterPercentage > 0.5) {
        score -= 5; // Grade B
      }
    }

    // Determine grade from score
    if (score < 50) {
      return 'Rejected';
    } else if (score < 70) {
      return 'C';
    } else if (score < 85) {
      return 'B';
    } else {
      return 'A';
    }
  }

  /**
   * AI-powered quality analysis (stub for ML integration)
   */
  async analyzeWithAI(inspectionId: string, imageUrls: string[]): Promise<{
    predictedGrade: string;
    confidence: number;
    defects: string[];
  }> {
    // In production: call ML model API
    // This is a stub that returns deterministic results
    const inspection = await this.getInspectionById(inspectionId);

    // Simulate AI analysis
    const predictedGrade = inspection.visualGrade || inspection.aiPredictedGrade || 'B';
    const confidence = 85 + Math.random() * 10; // 85-95%

    return {
      predictedGrade,
      confidence,
      defects: inspection.visualDefectsFound || [],
    };
  }

  /**
   * Generate quality report PDF
   */
  async generateQualityReport(inspectionId: string): Promise<string> {
    const inspection = await this.getInspectionById(inspectionId);

    // In production: use pdfkit or similar to generate PDF
    // Returns URL to stored PDF
    const reportUrl = `https://storage.afrigo.com/quality-reports/${inspectionId}.pdf`;

    return reportUrl;
  }

  /**
   * Get quality statistics
   */
  async getQualityStats(): Promise<{
    totalInspections: number;
    approvedCount: number;
    rejectedCount: number;
    avgGradeA: number;
    avgGradeB: number;
    avgGradeC: number;
    avgGradeRejected: number;
  }> {
    const completed = await this.inspectionRepository.find({
      where: { status: 'approved' },
    });

    const gradeDistribution = {
      A: completed.filter((i) => i.finalGrade === 'A').length,
      B: completed.filter((i) => i.finalGrade === 'B').length,
      C: completed.filter((i) => i.finalGrade === 'C').length,
      Rejected: completed.filter((i) => i.finalGrade === 'Rejected').length,
    };

    const total = Object.values(gradeDistribution).reduce((a, b) => a + b, 0) || 1;

    return {
      totalInspections: await this.inspectionRepository.count(),
      approvedCount: completed.length,
      rejectedCount: await this.inspectionRepository.count({ where: { status: 'rejected' } }),
      avgGradeA: (gradeDistribution.A / total) * 100,
      avgGradeB: (gradeDistribution.B / total) * 100,
      avgGradeC: (gradeDistribution.C / total) * 100,
      avgGradeRejected: (gradeDistribution.Rejected / total) * 100,
    };
  }
}
