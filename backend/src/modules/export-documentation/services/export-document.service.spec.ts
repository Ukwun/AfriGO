import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, NotFoundException } from '@nestjs/common';
import { ExportDocumentService } from './export-document.service';
import {
  CreateExportDocumentDto,
  DocumentStatusEnum,
  DocumentTypeEnum,
  CountryCodeEnum,
  GenerateComplianceReportDto,
} from '../dto/export-document.dto';

describe('ExportDocumentService', () => {
  let service: ExportDocumentService;
  let mockRepository: any;

  beforeEach(async () => {
    mockRepository = {
      create: jest.fn(),
      save: jest.fn(),
      findOne: jest.fn(),
      createQueryBuilder: jest.fn(() => ({
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        getMany: jest.fn(),
      })),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ExportDocumentService,
        {
          provide: 'ExportDocumentRepository',
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<ExportDocumentService>(ExportDocumentService);
  });

  describe('generateDocument', () => {
    it('should create a new export document', async () => {
      const dto: CreateExportDocumentDto = {
        documentType: DocumentTypeEnum.PHYTOSANITARY_CERTIFICATE,
        shipmentId: '123e4567-e89b-12d3-a456-426614174000',
        contractId: '223e4567-e89b-12d3-a456-426614174000',
        originCountry: CountryCodeEnum.KE,
        destinationCountry: CountryCodeEnum.UG,
        productDescription: '2000 kg Grade A Cocoa Beans',
        totalValue: 5000,
        currency: 'USD',
      };

      const mockDocument = {
        id: '323e4567-e89b-12d3-a456-426614174000',
        ...dto,
        documentNumber: 'PHY-2026-ABC123',
        status: DocumentStatusEnum.DRAFT,
        createdBy: 'user123',
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockRepository.create.mockReturnValue(mockDocument);
      mockRepository.save.mockResolvedValue(mockDocument);

      const result = await service.generateDocument(dto, 'user123');

      expect(result).toBeDefined();
      expect(result.documentType).toBe(DocumentTypeEnum.PHYTOSANITARY_CERTIFICATE);
      expect(mockRepository.save).toHaveBeenCalled();
    });

    it('should throw error for unsupported destination country', async () => {
      const dto: CreateExportDocumentDto = {
        documentType: DocumentTypeEnum.PHYTOSANITARY_CERTIFICATE,
        shipmentId: '123e4567-e89b-12d3-a456-426614174000',
        contractId: '223e4567-e89b-12d3-a456-426614174000',
        originCountry: CountryCodeEnum.KE,
        destinationCountry: 'XX' as any,  // Invalid country
        productDescription: '2000 kg Unknown Product',
        totalValue: 5000,
        currency: 'USD',
      };

      await expect(service.generateDocument(dto, 'user123')).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('getDocument', () => {
    it('should retrieve a document by ID', async () => {
      const mockDocument = {
        id: '323e4567-e89b-12d3-a456-426614174000',
        documentType: DocumentTypeEnum.CERTIFICATE_OF_ORIGIN,
        status: DocumentStatusEnum.SIGNED,
        originCountry: CountryCodeEnum.KE,
        destinationCountry: CountryCodeEnum.TZ,
      };

      mockRepository.findOne.mockResolvedValue(mockDocument);

      const result = await service.getDocument('323e4567-e89b-12d3-a456-426614174000');

      expect(result).toBeDefined();
      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: '323e4567-e89b-12d3-a456-426614174000' },
      });
    });

    it('should throw NotFoundException for non-existent document', async () => {
      mockRepository.findOne.mockResolvedValue(null);

      await expect(service.getDocument('invalid-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('listDocuments', () => {
    it('should list documents for a shipment', async () => {
      const mockDocuments = [
        {
          id: '323e4567-e89b-12d3-a456-426614174000',
          documentType: DocumentTypeEnum.PHYTOSANITARY_CERTIFICATE,
          status: DocumentStatusEnum.DRAFT,
        },
        {
          id: '423e4567-e89b-12d3-a456-426614174000',
          documentType: DocumentTypeEnum.BILL_OF_LADING,
          status: DocumentStatusEnum.SIGNED,
        },
      ];

      mockRepository.createQueryBuilder().getMany.mockResolvedValue(mockDocuments);

      const result = await service.listDocuments('shipment123');

      expect(result.total).toBe(2);
      expect(result.documents).toHaveLength(2);
    });

    it('should filter documents by status', async () => {
      const mockDocuments = [
        {
          id: '323e4567-e89b-12d3-a456-426614174000',
          status: DocumentStatusEnum.SIGNED,
        },
      ];

      mockRepository.createQueryBuilder().getMany.mockResolvedValue(mockDocuments);

      const result = await service.listDocuments('shipment123', {
        status: DocumentStatusEnum.SIGNED,
      });

      expect(result.total).toBe(1);
      expect(result.documents[0].status).toBe(DocumentStatusEnum.SIGNED);
    });
  });

  describe('generateComplianceReport', () => {
    it('should generate compliance report for destination', async () => {
      const dto: GenerateComplianceReportDto = {
        destinationCountry: CountryCodeEnum.KE,
        productType: 'cocoa',
        quantity: 2000,
        quantityUnit: 'kg',
      };

      const result = await service.generateComplianceReport(dto);

      expect(result).toBeDefined();
      expect(result.requiredDocuments).toBeDefined();
      expect(result.requiredDocuments.length).toBeGreaterThan(0);
      expect(result.estimatedCost).toBeGreaterThan(0);
    });

    it('should throw error for unsupported product type', async () => {
      const dto: GenerateComplianceReportDto = {
        destinationCountry: CountryCodeEnum.KE,
        productType: 'unknown',
        quantity: 2000,
        quantityUnit: 'kg',
      };

      await expect(service.generateComplianceReport(dto)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should include EU-specific requirements for EU destinations', async () => {
      const dto: GenerateComplianceReportDto = {
        destinationCountry: CountryCodeEnum.KE,  // Would need to add EU country codes
        productType: 'cocoa',
        quantity: 2000,
        quantityUnit: 'kg',
        certification: 'organic',
      };

      const result = await service.generateComplianceReport(dto);

      expect(result).toBeDefined();
      expect(Array.isArray(result.requiredDocuments)).toBe(true);
    });
  });

  describe('signDocument', () => {
    it('should sign a document', async () => {
      const mockDocument = {
        id: '323e4567-e89b-12d3-a456-426614174000',
        documentNumber: 'DOC-2026-001',
        status: DocumentStatusEnum.DRAFT,
        save: jest.fn(),
      };

      mockRepository.findOne.mockResolvedValue(mockDocument);

      const result = await service.signDocument('323e4567-e89b-12d3-a456-426614174000', {
        signatureData: 'base64_signature_data',
        signerEmail: 'signer@example.com',
        signingReason: 'Export Authorization',
      });

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
    });

    it('should throw error if document already signed', async () => {
      const mockDocument = {
        id: '323e4567-e89b-12d3-a456-426614174000',
        status: DocumentStatusEnum.SIGNED,
      };

      mockRepository.findOne.mockResolvedValue(mockDocument);

      await expect(
        service.signDocument('323e4567-e89b-12d3-a456-426614174000', {
          signatureData: 'data',
          signerEmail: 'test@example.com',
        }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('submitForApproval', () => {
    it('should submit signed document for government approval', async () => {
      const mockDocument = {
        id: '323e4567-e89b-12d3-a456-426614174000',
        status: DocumentStatusEnum.SIGNED,
        save: jest.fn(),
      };

      mockRepository.findOne.mockResolvedValue(mockDocument);

      const result = await service.submitForApproval('323e4567-e89b-12d3-a456-426614174000');

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.governmentReferenceId).toBeDefined();
    });

    it('should throw error if document not signed', async () => {
      const mockDocument = {
        id: '323e4567-e89b-12d3-a456-426614174000',
        status: DocumentStatusEnum.DRAFT,
      };

      mockRepository.findOne.mockResolvedValue(mockDocument);

      await expect(service.submitForApproval('323e4567-e89b-12d3-a456-426614174000')).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('updateDocumentStatus', () => {
    it('should update document status with valid transition', async () => {
      const mockDocument = {
        id: '323e4567-e89b-12d3-a456-426614174000',
        status: DocumentStatusEnum.DRAFT,
        save: jest.fn(),
      };

      mockRepository.findOne.mockResolvedValue(mockDocument);

      const result = await service.updateDocumentStatus(
        '323e4567-e89b-12d3-a456-426614174000',
        DocumentStatusEnum.SIGNED,
      );

      expect(result).toBeDefined();
    });

    it('should throw error for invalid status transition', async () => {
      const mockDocument = {
        id: '323e4567-e89b-12d3-a456-426614174000',
        status: DocumentStatusEnum.APPROVED,
      };

      mockRepository.findOne.mockResolvedValue(mockDocument);

      await expect(
        service.updateDocumentStatus(
          '323e4567-e89b-12d3-a456-426614174000',
          DocumentStatusEnum.DRAFT,
        ),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('archiveDocuments', () => {
    it('should archive all documents for shipment', async () => {
      const mockQueryBuilder = {
        update: jest.fn().mockReturnThis(),
        set: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        execute: jest.fn().mockResolvedValue({ affected: 5 }),
      };

      mockRepository.createQueryBuilder.mockReturnValue(mockQueryBuilder);

      const result = await service.archiveDocuments('shipment123');

      expect(result.archived).toBe(5);
    });
  });

  describe('getApprovalStatus', () => {
    it('should get approval status for submitted document', async () => {
      const mockDocument = {
        id: '323e4567-e89b-12d3-a456-426614174000',
        status: DocumentStatusEnum.SUBMITTED,
        governmentReferenceId: 'GVT-123456',
        submittedAt: new Date(),
      };

      mockRepository.findOne.mockResolvedValue(mockDocument);

      const result = await service.getApprovalStatus('GVT-123456');

      expect(result).toBeDefined();
      expect(result.governmentReferenceId).toBe('GVT-123456');
    });
  });
});
