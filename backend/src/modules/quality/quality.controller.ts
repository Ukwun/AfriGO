import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Query,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { QualityService } from './quality.service';
import {
  CreateQualityInspectionDTO,
  SubmitVisualInspectionDTO,
  SubmitLabTestDTO,
  ApproveQualityInspectionDTO,
  CreateLabCertificationDTO,
  QualityInspectionFilterDTO,
  QualityInspectionResponseDTO,
  LabCertificationResponseDTO,
} from './quality.dto';

@ApiTags('Quality & Lab Management')
@Controller('api/quality')
export class QualityController {
  constructor(private qualityService: QualityService) {}

  /**
   * Create quality inspection
   * POST /api/quality/inspections
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('inspections')
  async createInspection(@Body() dto: CreateQualityInspectionDTO) {
    const inspection = await this.qualityService.createInspection(dto);
    return {
      success: true,
      message: 'Quality inspection created',
      data: this._formatInspection(inspection),
    };
  }

  /**
   * Submit visual inspection results
   * POST /api/quality/inspections/:id/visual
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('inspections/:id/visual')
  async submitVisualInspection(
    @Param('id') inspectionId: string,
    @Body() dto: SubmitVisualInspectionDTO,
  ) {
    const inspection = await this.qualityService.submitVisualInspection({
      ...dto,
      inspectionId,
    });
    return {
      success: true,
      message: 'Visual inspection submitted',
      data: this._formatInspection(inspection),
    };
  }

  /**
   * Submit lab test results
   * POST /api/quality/inspections/:id/lab-test
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('inspections/:id/lab-test')
  async submitLabTest(@Param('id') inspectionId: string, @Body() dto: SubmitLabTestDTO) {
    const inspection = await this.qualityService.submitLabTest({
      ...dto,
      inspectionId,
    });
    return {
      success: true,
      message: 'Lab test results submitted',
      data: this._formatInspection(inspection),
    };
  }

  /**
   * Approve/reject inspection
   * POST /api/quality/inspections/:id/approve
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('inspections/:id/approve')
  async approveInspection(
    @Param('id') inspectionId: string,
    @Body() dto: ApproveQualityInspectionDTO,
    @Req() req: any,
  ) {
    const inspection = await this.qualityService.approveInspection(
      { ...dto, inspectionId },
      req.user.id,
    );
    return {
      success: true,
      message: dto.isApproved ? 'Inspection approved' : 'Inspection rejected',
      data: this._formatInspection(inspection),
    };
  }

  /**
   * Get inspection details
   * GET /api/quality/inspections/:id
   */
  @Get('inspections/:id')
  async getInspectionDetails(@Param('id') inspectionId: string) {
    const inspection = await this.qualityService.getInspectionById(inspectionId);
    return {
      success: true,
      data: this._formatInspection(inspection),
    };
  }

  /**
   * Get all inspections for a lot
   * GET /api/quality/lots/:lotId/inspections
   */
  @Get('lots/:lotId/inspections')
  async getLotInspections(@Param('lotId') lotId: string) {
    const inspections = await this.qualityService.getLotInspections(lotId);
    return {
      success: true,
      data: inspections.map((i) => this._formatInspection(i)),
    };
  }

  /**
   * List quality inspections
   * GET /api/quality/inspections?status=completed&page=1&limit=20
   */
  @Get('inspections')
  async listInspections(@Query() filters: QualityInspectionFilterDTO) {
    const { data, total } = await this.qualityService.listInspections(filters);
    return {
      success: true,
      data: data.map((i) => this._formatInspection(i)),
      pagination: {
        total,
        page: filters.page || 1,
        limit: filters.limit || 20,
        pages: Math.ceil(total / (filters.limit || 20)),
      },
    };
  }

  /**
   * Register lab certification
   * POST /api/quality/labs
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('labs')
  async registerLab(@Body() dto: CreateLabCertificationDTO) {
    const lab = await this.qualityService.registerLabCertification(dto);
    return {
      success: true,
      message: 'Lab registered successfully',
      data: this._formatLab(lab),
    };
  }

  /**
   * List available labs
   * GET /api/quality/labs?country=Ghana
   */
  @Get('labs')
  async listLabs(@Query('country') country?: string) {
    const labs = await this.qualityService.listLabs(country);
    return {
      success: true,
      data: labs.map((lab) => this._formatLab(lab)),
    };
  }

  /**
   * AI quality analysis
   * POST /api/quality/inspections/:id/analyze
   */
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @Post('inspections/:id/analyze')
  async analyzeQuality(@Param('id') inspectionId: string, @Body() body: { imageUrls: string[] }) {
    const result = await this.qualityService.analyzeWithAI(inspectionId, body.imageUrls);
    return {
      success: true,
      data: result,
    };
  }

  /**
   * Generate quality report
   * GET /api/quality/inspections/:id/report
   */
  @Get('inspections/:id/report')
  async generateReport(@Param('id') inspectionId: string) {
    const reportUrl = await this.qualityService.generateQualityReport(inspectionId);
    return {
      success: true,
      data: {
        reportUrl,
      },
    };
  }

  /**
   * Get quality statistics
   * GET /api/quality/stats
   */
  @Get('stats')
  async getStats() {
    const stats = await this.qualityService.getQualityStats();
    return {
      success: true,
      data: stats,
    };
  }

  // Helper methods
  private _formatInspection(inspection: any): QualityInspectionResponseDTO {
    return {
      id: inspection.id,
      lotId: inspection.lotId,
      inspectionType: inspection.inspectionType,
      status: inspection.status,
      visualGrade: inspection.visualGrade,
      visualDefectPercentage: inspection.visualDefectPercentage,
      visualDefectsFound: inspection.visualDefectsFound,
      inspectionPhotos: inspection.inspectionPhotos,
      moistureContent: inspection.moistureContent,
      afflatoxinLevel: inspection.afflatoxinLevel,
      foreignMatterPercentage: inspection.foreignMatterPercentage,
      insectFragmentCount: inspection.insectFragmentCount,
      pH: inspection.pH,
      bacterialCount: inspection.bacterialCount,
      aiPredictedGrade: inspection.aiPredictedGrade,
      aiConfidenceScore: inspection.aiConfidenceScore,
      finalGrade: inspection.finalGrade,
      isApproved: inspection.isApproved,
      approvalNotes: inspection.approvalNotes,
      createdAt: inspection.createdAt,
      completedAt: inspection.completedAt,
      labName: inspection.labCertification?.labName,
      inspectorName: inspection.inspector
        ? `${inspection.inspector.firstName} ${inspection.inspector.lastName}`
        : null,
    };
  }

  private _formatLab(lab: any): LabCertificationResponseDTO {
    return {
      id: lab.id,
      labName: lab.labName,
      labCode: lab.labCode,
      country: lab.country,
      certificationNumber: lab.certificationNumber,
      issuedDate: lab.issuedDate,
      expiryDate: lab.expiryDate,
      accreditation: lab.accreditation,
      testingCertifications: lab.testingCertifications,
      status: lab.status,
      contactEmail: lab.contactEmail,
      contactPhone: lab.contactPhone,
      costPerTest: lab.costPerTest,
      testsCompleted: lab.testsCompleted,
      averageAccuracy: lab.averageAccuracy,
    };
  }
}
