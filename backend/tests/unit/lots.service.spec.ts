import { Test, TestingModule } from '@nestjs/testing';
import { LotsService } from '../lots.service';
import { LotsController } from '../lots.controller';
import { Repository } from 'typeorm';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Lot } from '../entities/lot.entity';
import { CreateLotDto, LotSearchQueryDto } from '../dtos/lot.dto';

describe('LotsService', () => {
  let service: LotsService;
  let repository: Repository<Lot>;

  const mockLot: Lot = {
    id: 'test-lot-1',
    sellerId: 'seller-1',
    seller: undefined,
    productName: 'Test Maize',
    quantity: 1000,
    quantityUnit: 'kg',
    pricePerUnit: 0.75,
    description: 'Test description',
    images: ['image1.jpg'],
    pickupLocation: 'Test Market',
    latitude: -1.2865,
    longitude: 36.8172,
    qrCode: 'testqr123',
    status: 'active',
    verifyStatus: 'verified',
    certifications: ['Organic'],
    category: 'Grains',
    viewCount: 0,
    averageRating: 4.5,
    ratingCount: 10,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        LotsService,
        {
          provide: getRepositoryToken(Lot),
          useValue: {
            create: jest.fn().mockReturnValue(mockLot),
            save: jest.fn().mockResolvedValue(mockLot),
            findOne: jest.fn().mockResolvedValue(mockLot),
            findAndCount: jest
              .fn()
              .mockResolvedValue([[mockLot], 1]),
            find: jest.fn().mockResolvedValue([mockLot]),
            createQueryBuilder: jest.fn().mockReturnValue({
              where: jest.fn().mockReturnThis(),
              andWhere: jest.fn().mockReturnThis(),
              orderBy: jest.fn().mockReturnThis(),
              limit: jest.fn().mockReturnThis(),
              getMany: jest.fn().mockResolvedValue([mockLot]),
            }),
          },
        },
      ],
    }).compile();

    service = module.get<LotsService>(LotsService);
    repository = module.get<Repository<Lot>>(getRepositoryToken(Lot));
  });

  describe('createLot', () => {
    it('should create a new lot', async () => {
      const createLotDto: CreateLotDto = {
        productName: 'Test Maize',
        quantity: 1000,
        quantityUnit: 'kg',
        pricePerUnit: 0.75,
        description: 'Test description',
        images: ['image1.jpg'],
        pickupLocation: 'Test Market',
        latitude: -1.2865,
        longitude: 36.8172,
      };

      const result = await service.createLot('seller-1', createLotDto);

      expect(result).toBeDefined();
      expect(result.productName).toEqual('Test Maize');
      expect(result.status).toEqual('draft');
      expect(result.verifyStatus).toEqual('pending');
    });
  });

  describe('getAllLots', () => {
    it('should return list of lots', async () => {
      const query: LotSearchQueryDto = {
        page: 1,
        limit: 20,
      };

      const result = await service.getAllLots(query);

      expect(result).toBeDefined();
      expect(result.data).toBeInstanceOf(Array);
      expect(result.page).toEqual(1);
      expect(result.limit).toEqual(20);
    });

    it('should filter lots by product name', async () => {
      const query: LotSearchQueryDto = {
        productName: 'Maize',
        page: 1,
        limit: 20,
      };

      const result = await service.getAllLots(query);

      expect(result.data).toBeDefined();
    });

    it('should filter lots by price range', async () => {
      const query: LotSearchQueryDto = {
        minPrice: 0.5,
        maxPrice: 1.0,
        page: 1,
        limit: 20,
      };

      const result = await service.getAllLots(query);

      expect(result.data).toBeDefined();
    });

    it('should sort lots by newest', async () => {
      const query: LotSearchQueryDto = {
        sortBy: 'newest',
        page: 1,
        limit: 20,
      };

      const result = await service.getAllLots(query);

      expect(result.data).toBeDefined();
    });

    it('should sort lots by price (low to high)', async () => {
      const query: LotSearchQueryDto = {
        sortBy: 'priceLow',
        page: 1,
        limit: 20,
      };

      const result = await service.getAllLots(query);

      expect(result.data).toBeDefined();
    });
  });

  describe('getLotById', () => {
    it('should return a lot by id', async () => {
      const result = await service.getLotById('test-lot-1');

      expect(result).toBeDefined();
      expect(result.id).toEqual('test-lot-1');
    });

    it('should throw NotFoundException for non-existent lot', async () => {
      jest.spyOn(repository, 'findOne').mockResolvedValueOnce(null);

      await expect(service.getLotById('non-existent')).rejects.toThrow(
        'not found',
      );
    });
  });

  describe('getLotByQRCode', () => {
    it('should return a lot by QR code', async () => {
      const result = await service.getLotByQRCode('testqr123');

      expect(result).toBeDefined();
      expect(result.qrCode).toEqual('testqr123');
    });
  });

  describe('updateLot', () => {
    it('should update a lot (seller only)', async () => {
      const updateDto = {
        quantity: 800,
        pricePerUnit: 0.80,
      };

      const result = await service.updateLot(
        'test-lot-1',
        'seller-1',
        updateDto,
      );

      expect(result).toBeDefined();
    });

    it('should not allow non-seller to update lot', async () => {
      const updateDto = { quantity: 800 };

      await expect(
        service.updateLot('test-lot-1', 'different-seller', updateDto),
      ).rejects.toThrow('can only update your own');
    });
  });

  describe('deleteLot', () => {
    it('should delete a lot (soft delete)', async () => {
      const result = await service.deleteLot('test-lot-1', 'seller-1');

      expect(result.message).toEqual('Lot deleted successfully');
    });

    it('should not allow non-seller to delete lot', async () => {
      await expect(
        service.deleteLot('test-lot-1', 'different-seller'),
      ).rejects.toThrow('can only delete your own');
    });
  });

  describe('searchLots', () => {
    it('should search lots by query', async () => {
      const result = await service.searchLots('Maize');

      expect(result).toBeDefined();
      expect(result).toBeInstanceOf(Array);
    });
  });

  describe('getSellerLots', () => {
    it('should return seller lots', async () => {
      const result = await service.getSellerLots('seller-1');

      expect(result.data).toBeDefined();
      expect(result.total).toBeGreaterThanOrEqual(0);
    });
  });

  describe('verifyLot', () => {
    it('should verify a lot (admin only)', async () => {
      const result = await service.verifyLot('test-lot-1', true);

      expect(result).toBeDefined();
      expect(result.verifyStatus).toEqual('verified');
      expect(result.status).toEqual('active');
    });

    it('should reject a lot (admin only)', async () => {
      const result = await service.verifyLot('test-lot-1', false);

      expect(result).toBeDefined();
      expect(result.verifyStatus).toEqual('rejected');
    });
  });

  describe('getLotsByLocation', () => {
    it('should return lots near location', async () => {
      const result = await service.getLotsByLocation(
        -1.2865,
        36.8172,
        50,
      );

      expect(result).toBeDefined();
      expect(result).toBeInstanceOf(Array);
    });
  });
});

describe('LotsController', () => {
  let controller: LotsController;
  let service: LotsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [LotsController],
      providers: [
        {
          provide: LotsService,
          useValue: {
            createLot: jest.fn(),
            getAllLots: jest.fn(),
            getLotById: jest.fn(),
            updateLot: jest.fn(),
            deleteLot: jest.fn(),
            searchLots: jest.fn(),
            getSellerLots: jest.fn(),
            verifyLot: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<LotsController>(LotsController);
    service = module.get<LotsService>(LotsService);
  });

  describe('createLot', () => {
    it('should create a lot', async () => {
      const req = { user: { id: 'seller-1' } };
      const createLotDto: CreateLotDto = {
        productName: 'Test',
        quantity: 100,
        quantityUnit: 'kg',
        pricePerUnit: 1.0,
        description: 'Test',
        images: [],
        pickupLocation: 'Test',
        latitude: 0,
        longitude: 0,
      };

      jest.spyOn(service, 'createLot').mockResolvedValue(undefined);

      await controller.createLot(req, createLotDto);

      expect(service.createLot).toHaveBeenCalledWith('seller-1', createLotDto);
    });
  });

  describe('getLots', () => {
    it('should return lots', async () => {
      const query: LotSearchQueryDto = {};

      jest.spyOn(service, 'getAllLots').mockResolvedValue(undefined);

      await controller.getLots(query);

      expect(service.getAllLots).toHaveBeenCalledWith(query);
    });
  });

  describe('getLotById', () => {
    it('should return a lot', async () => {
      jest.spyOn(service, 'getLotById').mockResolvedValue(undefined);

      await controller.getLotById('lot-1');

      expect(service.getLotById).toHaveBeenCalledWith('lot-1');
    });
  });
});
