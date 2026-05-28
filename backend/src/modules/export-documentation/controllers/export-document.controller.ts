// backend/src/modules/export-documentation/controllers/export-document.controller.ts

import {
  Controller,
  Post,
  Get,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
  Res,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { ExportDocumentService } from '../services/export-document.service';
import {
  CreateExportDocumentDto,
  UpdateDocumentStatusDto,
  SignDocumentDto,
  GenerateComplianceReportDto,
  DocumentStatusEnum,
  DocumentTypeEnum,
} from '../dto/export-document.dto';

/**
 * Export Documentation Controller
 * REST API endpoints for managing export documents
 * 
 * All endpoints require authentication (sellers/exporters only)
 */
@Controller('api/export-documentation')
@UseGuards(JwtAuthGuard)
export class ExportDocumentController {
  constructor(private exportDocumentService: ExportDocumentService) {}

  /**
   * POST /api/export-documentation
   * Generate a new export document for a shipment
   * 
   * @param dto Document creation details
   * @param user Authenticated user
   * @returns New document with initial status DRAFT
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createDocument(
    @Body() dto: CreateExportDocumentDto,
    @CurrentUser() user: any,
  ) {
    return {
      success: true,
      statusCode: 201,
      message: 'Export document generated successfully',
      data: await this.exportDocumentService.generateDocument(dto, user.id),
    };
  }

  /**
   * GET /api/export-documentation/:documentId
   * Retrieve a specific document
   * 
   * @param documentId UUID of document
   * @returns Complete document details
   */
  @Get(':documentId')
  async getDocument(@Param('documentId') documentId: string) {
    const document = await this.exportDocumentService.getDocument(documentId);

    return {
      success: true,
      statusCode: 200,
      data: document,
    };
  }

  /**
   * GET /api/export-documentation/:documentId/download
   * Download document as PDF
   * 
   * @param documentId UUID of document
   * @param res Express response for file download
   */
  @Get(':documentId/download')
  async downloadDocument(
    @Param('documentId') documentId: string,
    @Res() res: Response,
  ) {
    const pdfBuffer = await this.exportDocumentService.generatePDF(documentId);

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="export-doc-${documentId}.pdf"`);
    res.send(pdfBuffer);
  }

  /**
   * GET /api/export-documentation/:documentId/status
   * Get current approval status from government
   * 
   * @param documentId UUID of document
   */
  @Get(':documentId/status')
  async getApprovalStatus(@Param('documentId') documentId: string) {
    const status = await this.exportDocumentService.getApprovalStatus(documentId);

    return {
      success: true,
      statusCode: 200,
      data: status,
    };
  }

  /**
   * GET /api/export-documentation/shipment/:shipmentId/bundle
   * Get all export documents for shipment as a bundle
   * Returns list ready for download/submission
   */
  @Get('shipment/:shipmentId/bundle')
  async getDocumentBundle(@Param('shipmentId') shipmentId: string) {
    const documents = await this.exportDocumentService.listDocuments(shipmentId);

    // Count status
    const signed = documents.documents.filter(d => d.status === DocumentStatusEnum.SIGNED).length;
    const submitted = documents.documents.filter(d => d.status === DocumentStatusEnum.SUBMITTED).length;
    const approved = documents.documents.filter(d => d.status === DocumentStatusEnum.APPROVED).length;

    const readyToSubmit = documents.documents.filter(
      d => d.status === DocumentStatusEnum.SIGNED && d.status !== DocumentStatusEnum.SUBMITTED,
    );

    return {
      success: true,
      statusCode: 200,
      data: {
        shipmentId,
        summary: {
          total: documents.total,
          signed,
          submitted,
          approved,
          unsigned: documents.total - signed,
        },
        documents: documents.documents,
        nextActions: {
          unsigned: `Sign ${documents.total - signed} remaining documents`,
          lastSigned: signed === documents.total ? 'Ready to submit' : null,
          lastSubmitted: submitted > 0 ? 'Check approval status' : null,
        },
        downloadLinks: {
          allAsPDF: `/api/export-documentation/shipment/${shipmentId}/bundle/download`,
          byType: documents.documents.reduce((acc, doc) => {
            acc[doc.documentType] = `/api/export-documentation/${doc.id}/download`;
            return acc;
          }, {}),
        },
      },
    };
  }

  /**
   * GET /api/export-documentation/metadata/countries
   * Get list of supported countries and their requirements
   * Useful for UI dropdowns
   */
  @Get('metadata/countries')
  async getSupportedCountries() {
    return {
      success: true,
      statusCode: 200,
      data: {
        countries: [
          { code: 'KE', name: 'Kenya', supported: true },
          { code: 'UG', name: 'Uganda', supported: true },
          { code: 'TZ', name: 'Tanzania', supported: true },
          { code: 'ET', name: 'Ethiopia', supported: true },
          { code: 'GH', name: 'Ghana', supported: true },
          { code: 'NG', name: 'Nigeria', supported: true },
          { code: 'ZA', name: 'South Africa', supported: true },
          // ... more countries
        ],
        documentTypes: [
          'PHYTOSANITARY_CERTIFICATE',
          'BILL_OF_LADING',
          'COMMERCIAL_INVOICE',
          'CERTIFICATE_OF_ORIGIN',
          'PACKING_LIST',
          'CERTIFICATE_OF_ANALYSIS',
          'ORGANIC_CERTIFICATE',
          'FAIR_TRADE_CERTIFICATE',
        ],
      },
    };
  }

  /**
   * POST /api/export-documentation/:documentId/sign
   * Digitally sign document (legally binding)
   * 
   * @param documentId UUID of document
   * @param dto Signature data
   * @param user Authenticated user
   */
  @Post(':documentId/sign')
  async signDocument(
    @Param('documentId') documentId: string,
    @Body() dto: SignDocumentDto,
    @CurrentUser() user: any,
  ) {
    const result = await this.exportDocumentService.signDocument(documentId, dto);

    return {
      success: true,
      statusCode: 200,
      message: 'Document signed successfully',
      data: result,
    };
  }

  /**
   * POST /api/export-documentation/:documentId/submit
   * Submit signed document to government for approval
   * 
   * @param documentId UUID of document
   */
  @Post(':documentId/submit')
  async submitForApproval(@Param('documentId') documentId: string) {
    const result = await this.exportDocumentService.submitForApproval(documentId);

    return {
      success: true,
      statusCode: 200,
      message: 'Document submitted for government approval',
      data: result,
    };
  }

  /**
   * POST /api/export-documentation/:documentId/request-signature
   * Request signature from another party (shipper, exporter, etc.)
   * 
   * Sends notification to other party to sign document
   */
  @Post(':documentId/request-signature')
  async requestSignature(
    @Param('documentId') documentId: string,
    @Body() dto: { recipientEmail: string; message?: string },
  ) {
    // In production, would send email notification
    return {
      success: true,
      statusCode: 200,
      message: 'Signature request sent',
      data: {
        documentId,
        requestedFrom: dto.recipientEmail,
        sentAt: new Date(),
        expiresIn: '7 days',
      },
    };
  }

  /**
   * POST /api/export-documentation/compliance/report
   * Generate compliance checklist for destination country
   * Shows all required documents, restrictions, and regulations
   * 
   * @param dto Destination and product details
   * @returns Compliance matrix with all requirements
   */
  @Post('compliance/report')
  async generateComplianceReport(@Body() dto: GenerateComplianceReportDto) {
    const compliance = await this.exportDocumentService.generateComplianceReport(dto);

    return {
      success: true,
      statusCode: 200,
      message: 'Compliance report generated',
      data: compliance,
    };
  }

  /**
   * POST /api/export-documentation/bulk-generate
   * Generate all required documents for a shipment at once
   * Convenience endpoint for common use case
   * 
   * @param dto Shipment details
   */
  @Post('bulk-generate')
  async bulkGenerateDocuments(
    @Body() dto: any,  // Accepts shipment ID + destination
    @CurrentUser() user: any,
  ) {
    // Get all required documents for destination
    const compliance = await this.exportDocumentService.generateComplianceReport({
      destinationCountry: dto.destinationCountry,
      productType: dto.productType,
      quantity: dto.quantity,
      quantityUnit: dto.quantityUnit,
    });

    // Generate each required document
    const generatedDocs = [];
    for (const req of compliance.requiredDocuments) {
      try {
        const doc = await this.exportDocumentService.generateDocument(
          {
            documentType: req.documentType,
            shipmentId: dto.shipmentId,
            contractId: dto.contractId,
            originCountry: dto.originCountry,
            destinationCountry: dto.destinationCountry,
            productDescription: dto.productDescription,
            totalValue: dto.totalValue,
            currency: dto.currency,
          },
          user.id,
        );
        generatedDocs.push(doc);
      } catch (err) {
        // Continue generating other docs if one fails
        console.error(`Failed to generate ${req.documentType}:`, err.message);
      }
    }

    return {
      success: true,
      statusCode: 201,
      message: `Generated ${generatedDocs.length} export documents`,
      data: {
        generatedCount: generatedDocs.length,
        requiredCount: compliance.requiredDocuments.length,
        documents: generatedDocs,
        nextSteps: [
          `Review each document for accuracy`,
          `Sign all documents (legally binding)`,
          `Submit to government for approval`,
        ],
      },
    };
  }

  /**
   * GET /api/export-documentation
   * List all export documents for authenticated user's shipments
   * 
   * @param shipmentId Filter by shipment
   * @param status Filter by document status
   * @param documentType Filter by document type
   * @returns Array of documents with pagination
   */
  @Get()
  async listDocuments(
    @Query('shipmentId') shipmentId?: string,
    @Query('status') status?: DocumentStatusEnum,
    @Query('documentType') documentType?: DocumentTypeEnum,
  ) {
    const documents = await this.exportDocumentService.listDocuments(shipmentId, {
      status,
      documentType,
    });

    return {
      success: true,
      statusCode: 200,
      data: documents,
    };
  }
}
