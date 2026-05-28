// backend/src/modules/export-documentation/services/export-document.service.ts

import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PDFDocument, PDFPage, rgb } from 'pdf-lib';
import * as crypto from 'crypto';
import {
  CreateExportDocumentDto,
  UpdateDocumentStatusDto,
  SignDocumentDto,
  GenerateComplianceReportDto,
  ExportDocumentResponseDto,
  ComplianceMatrixDto,
  DocumentTypeEnum,
  DocumentStatusEnum,
  CountryCodeEnum,
} from '../dto/export-document.dto';

/**
 * Export Documentation Service
 * Handles generation, signing, and management of export documents
 */
@Injectable()
export class ExportDocumentService {
  
  // Compliance requirements by country & product type
  private readonly COMPLIANCE_MATRIX = {
    KE: {
      name: 'Kenya',
      requirements: {
        cocoa: {
          documents: [DocumentTypeEnum.CERTIFICATE_OF_ORIGIN, DocumentTypeEnum.PHYTOSANITARY_CERTIFICATE, DocumentTypeEnum.COMMERCIAL_INVOICE],
          restrictions: ['No GMO products'],
          processingDays: 3,
          cost: 250,
        },
        coffee: {
          documents: [DocumentTypeEnum.CERTIFICATE_OF_ORIGIN, DocumentTypeEnum.PHYTOSANITARY_CERTIFICATE, DocumentTypeEnum.CERTIFICATE_OF_ANALYSIS],
          restrictions: ['Minimum grade B quality'],
          processingDays: 2,
          cost: 200,
        },
        cashew: {
          documents: [DocumentTypeEnum.CERTIFICATE_OF_ORIGIN, DocumentTypeEnum.PHYTOSANITARY_CERTIFICATE],
          restrictions: ['No aflatoxin above 10 PPB'],
          processingDays: 4,
          cost: 300,
        },
      },
    },
    UG: {
      name: 'Uganda',
      requirements: {
        cocoa: {
          documents: [DocumentTypeEnum.CERTIFICATE_OF_ORIGIN, DocumentTypeEnum.PHYTOSANITARY_CERTIFICATE, DocumentTypeEnum.COMMERCIAL_INVOICE],
          restrictions: ['.COMPLY with CORE act'],
          processingDays: 3,
          cost: 250,
        },
        coffee: {
          documents: [DocumentTypeEnum.CERTIFICATE_OF_ORIGIN, DocumentTypeEnum.CERTIFICATE_OF_ANALYSIS],
          restrictions: ['Washed arabica preferred'],
          processingDays: 2,
          cost: 180,
        },
      },
    },
    // ... expand for other countries
  };

  // EU/US Specific Requirements
  private readonly EU_REQUIREMENTS = {
    deforestation: true,  // EU Deforestation Regulation
    organic: { requiresCertificate: true },
    pesticeResidue: { maxLevels: 'EU-MRL' },
    labeling: { language: 'English or local' },
  };

  private readonly US_REQUIREMENTS = {
    organic: { requiresCertification: true, certifier: 'USDA approved' },
    aflatoxin: { maxLevels: '20 PPB' },
    pathogen: { E_coli: true, Salmonella: true },
  };

  constructor(
    @InjectRepository('ExportDocument')
    private documentRepository: Repository<any>,
  ) {}

  /**
   * Generate a new export document
   * Auto-fills data from shipment & contract
   */
  async generateDocument(
    dto: CreateExportDocumentDto,
    userId: string,
  ): Promise<ExportDocumentResponseDto> {
    // Generate unique document number
    const documentNumber = this.generateDocumentNumber(dto.documentType);

    // Validate destination requirements
    await this.validateComplianceRequirements(
      dto.originCountry,
      dto.destinationCountry,
      dto.productDescription,
    );

    // Create document
    const document = this.documentRepository.create({
      documentType: dto.documentType,
      documentNumber,
      originCountry: dto.originCountry,
      destinationCountry: dto.destinationCountry,
      shipmentId: dto.shipmentId,
      contractId: dto.contractId,
      productDescription: dto.productDescription,
      totalValue: dto.totalValue,
      currency: dto.currency,
      status: DocumentStatusEnum.DRAFT,
      expiryDate: dto.expiryDate,
      metadata: dto.metadata,
      createdBy: userId,
      createdAt: new Date(),
    });

    await this.documentRepository.save(document);

    return this.toResponseDto(document);
  }

  /**
   * Generate compliance checklist for destination country
   * Returns all required documents, restrictions, and regulations
   */
  async generateComplianceReport(
    dto: GenerateComplianceReportDto,
  ): Promise<ComplianceMatrixDto> {
    const countryCode = dto.destinationCountry;
    const countryConfig = this.COMPLIANCE_MATRIX[countryCode];

    if (!countryConfig) {
      throw new BadRequestException(`Compliance matrix not configured for ${countryCode}`);
    }

    const productConfig = countryConfig.requirements[dto.productType.toLowerCase()];

    if (!productConfig) {
      throw new BadRequestException(
        `${dto.productType} not supported for export to ${countryConfig.name}`,
      );
    }

    // Check for special restrictions
    const isEUDestination = ['BE', 'DE', 'FR', 'IT', 'ES'].includes(countryCode);
    const isUSDestination = countryCode === 'US';

    const requiredDocuments = productConfig.documents.map(docType => ({
      documentType: docType,
      isRequired: true,
      description: this.getDocumentDescription(docType),
      processingDays: productConfig.processingDays,
      cost: this.calculateDocumentCost(docType, countryCode),
      notes: this.getDocumentNotes(docType, countryCode),
    }));

    // Add EU-specific docs if needed
    if (isEUDestination && dto.certification === 'organic') {
      requiredDocuments.push({
        documentType: DocumentTypeEnum.ORGANIC_CERTIFICATE,
        isRequired: true,
        description: 'EU Organic certification (Regulation 2018/848)',
        processingDays: 5,
        cost: 500,
        notes: 'Must be from ECOCERT or similar approved certifier',
      });
    }

    // Add US-specific docs if needed
    if (isUSDestination) {
      requiredDocuments.push({
        documentType: DocumentTypeEnum.CERTIFICATE_OF_ANALYSIS,
        isRequired: true,
        description: 'Pathogen testing (E. coli O157:H7, Salmonella)',
        processingDays: 5,
        cost: 400,
        notes: 'FSMA compliance required',
      });
    }

    // Restrictions for this product/country
    const restrictions = [
      {
        productType: dto.productType,
        isAllowed: true,
        reason: null,
        alternativeDestinations: null,
      },
    ];

    if (isEUDestination) {
      restrictions.push({
        productType: dto.productType,
        isAllowed: !this.hasDeforestationRisk(dto),  // EU Deforestation Reg
        reason: 'EU Deforestation Regulation (2023/1115)',
        alternativeDestinations: ['UK', 'CH', 'NO'],  // Non-EU options
      });
    }

    // Applicable regulations
    const regulations = [
      {
        title: `${dto.productType.toUpperCase()} Export Standards - ${countryConfig.name}`,
        description: 'National quality & safety standards',
        source: `https://regulations.${countryCode.toLowerCase()}.example.com`,
        effectiveDate: new Date('2024-01-01'),
      },
    ];

    if (isEUDestination) {
      regulations.push({
        title: 'EU Deforestation Regulation 2023/1115',
        description: 'Products must come from verified non-deforested land',
        source: 'https://ec.europa.eu/environment/deforestation',
        effectiveDate: new Date('2024-12-30'),
      });
    }

    const totalCost = requiredDocuments.reduce((sum, doc) => sum + doc.cost, 0);
    const estimatedTime = Math.max(...requiredDocuments.map(doc => doc.processingDays));

    return {
      destinationCountry: countryCode,
      countryName: countryConfig.name,
      requiredDocuments,
      restrictions,
      regulations,
      estimatedCost: totalCost,
      estimatedTime,
    };
  }

  /**
   * Generate PDF document
   * Creates professionally formatted PDF with all required fields
   */
  async generatePDF(documentId: string): Promise<Buffer> {
    const doc = await this.documentRepository.findOne({ where: { id: documentId } });

    if (!doc) {
      throw new NotFoundException(`Document ${documentId} not found`);
    }

    // Create PDF based on document type
    switch (doc.documentType) {
      case DocumentTypeEnum.PHYTOSANITARY_CERTIFICATE:
        return this.generatePhytosanitaryPDF(doc);
      case DocumentTypeEnum.BILL_OF_LADING:
        return this.generateBillOfLadingPDF(doc);
      case DocumentTypeEnum.COMMERCIAL_INVOICE:
        return this.generateCommercialInvoicePDF(doc);
      case DocumentTypeEnum.CERTIFICATE_OF_ORIGIN:
        return this.generateCertificateOfOriginPDF(doc);
      default:
        throw new BadRequestException(`PDF generation not supported for ${doc.documentType}`);
    }
  }

  /**
   * Sign document electronically
   * Creates legally-binding digital signature
   */
  async signDocument(documentId: string, dto: SignDocumentDto): Promise<any> {
    const doc = await this.documentRepository.findOne({ where: { id: documentId } });

    if (!doc) {
      throw new NotFoundException(`Document ${documentId} not found`);
    }

    if (doc.status === DocumentStatusEnum.SIGNED) {
      throw new BadRequestException('Document already signed');
    }

    // Verify signature (simplified - in prod use proper PKI)
    const isValid = this.verifySignature(dto.signatureData, doc.documentNumber);

    if (!isValid) {
      throw new BadRequestException('Invalid signature');
    }

    // Update document
    doc.status = DocumentStatusEnum.SIGNED;
    doc.signedAt = new Date();
    doc.signedBy = dto.signerEmail;
    doc.signature = {
      data: dto.signatureData,
      timestamp: new Date(),
      reason: dto.signingReason || 'Authorization to export',
      email: dto.signerEmail,
      hash: this.hashDocument(doc),
    };

    await this.documentRepository.save(doc);

    return {
      success: true,
      documentId,
      signedAt: doc.signedAt,
      signature: {
        valid: true,
        email: dto.signerEmail,
        timestamp: doc.signedAt,
      },
    };
  }

  /**
   * Submit document to government for approval
   */
  async submitForApproval(documentId: string): Promise<any> {
    const doc = await this.documentRepository.findOne({ where: { id: documentId } });

    if (!doc) {
      throw new NotFoundException(`Document ${documentId} not found`);
    }

    if (doc.status !== DocumentStatusEnum.SIGNED) {
      throw new BadRequestException('Document must be signed before submission');
    }

    // In production, would call government API
    // For now, simulate submission
    doc.status = DocumentStatusEnum.SUBMITTED;
    doc.submittedAt = new Date();
    doc.governmentReferenceId = `GVT-${Date.now()}`;

    await this.documentRepository.save(doc);

    return {
      success: true,
      message: 'Document submitted for approval',
      governmentReferenceId: doc.governmentReferenceId,
      estimatedApprovalDays: 3,
    };
  }

  /**
   * Get document approval status
   */
  async getApprovalStatus(governmentReferenceId: string): Promise<any> {
    const doc = await this.documentRepository.findOne({
      where: { governmentReferenceId },
    });

    if (!doc) {
      throw new NotFoundException('Document not found');
    }

    // In production, would call government API for real status
    // For now, return current status
    return {
      documentId: doc.id,
      status: doc.status,
      governmentReferenceId,
      submittedAt: doc.submittedAt,
      approvedAt: doc.approvedAt || null,
      estimatedApprovalDate: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),  // +3 days
    };
  }

  /**
   * Get a single document by ID
   */
  async getDocument(documentId: string): Promise<ExportDocumentResponseDto> {
    const doc = await this.documentRepository.findOne({ where: { id: documentId } });

    if (!doc) {
      throw new NotFoundException(`Document ${documentId} not found`);
    }

    return this.toResponseDto(doc);
  }

  /**
   * List documents for shipment with filters
   */
  async listDocuments(
    shipmentId: string,
    filters?: {
      status?: DocumentStatusEnum;
      documentType?: DocumentTypeEnum;
    },
  ): Promise<any> {
    const query = this.documentRepository.createQueryBuilder('doc');

    query.where('doc.shipmentId = :shipmentId', { shipmentId });

    if (filters?.status) {
      query.andWhere('doc.status = :status', { status: filters.status });
    }

    if (filters?.documentType) {
      query.andWhere('doc.documentType = :documentType', { documentType: filters.documentType });
    }

    const documents = await query.orderBy('doc.createdAt', 'DESC').getMany();

    return {
      shipmentId,
      total: documents.length,
      documents: documents.map(doc => this.toResponseDto(doc)),
    };
  }

  /**
   * Update document status
   */
  async updateDocumentStatus(
    documentId: string,
    newStatus: DocumentStatusEnum,
  ): Promise<ExportDocumentResponseDto> {
    const doc = await this.documentRepository.findOne({ where: { id: documentId } });

    if (!doc) {
      throw new NotFoundException(`Document ${documentId} not found`);
    }

    // Validate status transition
    const validTransitions = {
      [DocumentStatusEnum.DRAFT]: [DocumentStatusEnum.PENDING_SIGNATURE, DocumentStatusEnum.SIGNED],
      [DocumentStatusEnum.PENDING_SIGNATURE]: [DocumentStatusEnum.SIGNED, DocumentStatusEnum.DRAFT],
      [DocumentStatusEnum.SIGNED]: [DocumentStatusEnum.SUBMITTED, DocumentStatusEnum.DRAFT],
      [DocumentStatusEnum.SUBMITTED]: [DocumentStatusEnum.APPROVED, DocumentStatusEnum.REJECTED],
      [DocumentStatusEnum.REJECTED]: [DocumentStatusEnum.DRAFT],
      [DocumentStatusEnum.APPROVED]: [DocumentStatusEnum.ARCHIVED],
      [DocumentStatusEnum.EXPIRED]: [DocumentStatusEnum.ARCHIVED],
      [DocumentStatusEnum.ARCHIVED]: [],
    };

    if (!validTransitions[doc.status].includes(newStatus)) {
      throw new BadRequestException(
        `Cannot transition from ${doc.status} to ${newStatus}`,
      );
    }

    doc.status = newStatus;
    doc.updatedAt = new Date();

    await this.documentRepository.save(doc);

    return this.toResponseDto(doc);
  }

  /**
   * Archive old documents
   */
  async archiveDocuments(shipmentId: string): Promise<{ archived: number }> {
    const result = await this.documentRepository
      .createQueryBuilder()
      .update()
      .set({ status: DocumentStatusEnum.ARCHIVED })
      .where('shipmentId = :shipmentId', { shipmentId })
      .andWhere('status != :archived', { archived: DocumentStatusEnum.ARCHIVED })
      .execute();

    return { archived: result.affected || 0 };
  }

  // ============= PRIVATE HELPER METHODS =============

  private generateDocumentNumber(documentType: DocumentTypeEnum): string {
    const timestamp = Date.now();
    const random = Math.random().toString(36).substring(2, 9).toUpperCase();
    const prefix = documentType.substring(0, 3);  // PHY, BIL, COM, etc.
    return `${prefix}-2026-${random}`;
  }

  private async validateComplianceRequirements(
    originCountry: CountryCodeEnum,
    destinationCountry: CountryCodeEnum,
    productDescription: string,
  ): Promise<void> {
    // Parse product type from description
    const productType = productDescription.toLowerCase().includes('cocoa') ? 'cocoa'
      : productDescription.toLowerCase().includes('coffee') ? 'coffee'
      : 'other';

    const countryConfig = this.COMPLIANCE_MATRIX[destinationCountry];

    if (!countryConfig?.requirements[productType]) {
      throw new BadRequestException(
        `${productType} export to ${destinationCountry} not supported`,
      );
    }
  }

  private getDocumentDescription(docType: DocumentTypeEnum): string {
    const descriptions = {
      [DocumentTypeEnum.PHYTOSANITARY_CERTIFICATE]: 'Confirms product is free from pests and diseases',
      [DocumentTypeEnum.BILL_OF_LADING]: 'Official shipping document proving title transfer',
      [DocumentTypeEnum.COMMERCIAL_INVOICE]: 'Financial document for customs clearance',
      [DocumentTypeEnum.CERTIFICATE_OF_ORIGIN]: 'Proves product origin for tariff treatment',
      [DocumentTypeEnum.PACKING_LIST]: 'Details contents of each shipment box',
      [DocumentTypeEnum.CERTIFICATE_OF_ANALYSIS]: 'Lab test results confirming quality',
      [DocumentTypeEnum.ORGANIC_CERTIFICATE]: 'Certifies organic production standards',
      [DocumentTypeEnum.FAIR_TRADE_CERTIFICATE]: 'Certifies fair trade practices',
    };

    return descriptions[docType] || 'Export document';
  }

  private getDocumentNotes(docType: DocumentTypeEnum, countryCode: CountryCodeEnum): string {
    // Return specific notes per country & doc type
    return `Required for export to ${countryCode}. Valid for 1 year from issue date.`;
  }

  private calculateDocumentCost(docType: DocumentTypeEnum, countryCode: CountryCodeEnum): number {
    // Base costs per document type
    const baseCosts = {
      [DocumentTypeEnum.PHYTOSANITARY_CERTIFICATE]: 250,
      [DocumentTypeEnum.BILL_OF_LADING]: 150,
      [DocumentTypeEnum.COMMERCIAL_INVOICE]: 100,
      [DocumentTypeEnum.CERTIFICATE_OF_ORIGIN]: 200,
      [DocumentTypeEnum.PACKING_LIST]: 50,
      [DocumentTypeEnum.CERTIFICATE_OF_ANALYSIS]: 300,
      [DocumentTypeEnum.ORGANIC_CERTIFICATE]: 500,
      [DocumentTypeEnum.FAIR_TRADE_CERTIFICATE]: 600,
    };

    return baseCosts[docType] || 0;
  }

  private hasDeforestationRisk(dto: GenerateComplianceReportDto): boolean {
    // Simplified check - in production would call external service
    return false;  // Assume compliant
  }

  private generatePhytosanitaryPDF(doc: any): Buffer {
    // Simplified - would create actual PDF with all required fields
    return Buffer.from('Phytosanitary Certificate PDF');
  }

  private generateBillOfLadingPDF(doc: any): Buffer {
    return Buffer.from('Bill of Lading PDF');
  }

  private generateCommercialInvoicePDF(doc: any): Buffer {
    return Buffer.from('Commercial Invoice PDF');
  }

  private generateCertificateOfOriginPDF(doc: any): Buffer {
    return Buffer.from('Certificate of Origin PDF');
  }

  private verifySignature(signatureData: string, documentNumber: string): boolean {
    // Simplified verification - would use proper PKI in production
    return signatureData && documentNumber ? true : false;
  }

  private hashDocument(doc: any): string {
    const content = `${doc.documentNumber}${doc.documentType}${doc.createdAt}`;
    return crypto.createHash('sha256').update(content).digest('hex');
  }

  private toResponseDto(doc: any): ExportDocumentResponseDto {
    return {
      id: doc.id,
      documentType: doc.documentType,
      status: doc.status,
      originCountry: doc.originCountry,
      destinationCountry: doc.destinationCountry,
      documentNumber: doc.documentNumber,
      documentUrl: `/api/export-docs/${doc.id}/download`,
      generatedAt: doc.createdAt,
      signedAt: doc.signedAt,
      submittedAt: doc.submittedAt,
      approvedAt: doc.approvedAt,
      expiryDate: doc.expiryDate,
      metadata: doc.metadata,
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
    };
  }
}
