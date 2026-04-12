import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { TradingService } from '../trading.service';
import { Order } from '../entities/order.entity';
import { Quote } from '../entities/quote.entity';
import { Lot } from '../../lots/entities/lot.entity';
import { User } from '../../users/entities/user.entity';

describe('TradingService', () => {
  let service: TradingService;
  let ordersRepository: Repository<Order>;
  let quotesRepository: Repository<Quote>;
  let lotsRepository: Repository<Lot>;
  let usersRepository: Repository<User>;

  const mockBuyer = {
    id: 'buyer-123',
    email: 'buyer@example.com',
    fullName: 'John Buyer',
  };

  const mockSeller = {
    id: 'seller-123',
    email: 'seller@example.com',
    fullName: 'Jane Seller',
  };

  const mockLot = {
    id: 'lot-123',
    productName: 'Tomatoes',
    price: 10000,
    availableQuantity: 100,
    sellerId: 'seller-123',
    status: 'verified',
    deletedAt: null,
  };

  const mockOrder = {
    id: 'order-123',
    lotId: 'lot-123',
    buyerId: 'buyer-123',
    sellerId: 'seller-123',
    quantity: 10,
    quantityUnit: 'kg',
    pricePerUnit: 10000,
    totalPrice: 100000,
    status: 'pending',
    paymentStatus: 'not_paid',
    createdAt: new Date(),
  };

  const mockQuote = {
    id: 'quote-123',
    orderId: 'order-123',
    lotId: 'lot-123',
    fromUserId: 'seller-123',
    toUserId: 'buyer-123',
    quotedPrice: 9500,
    quotedQuantity: 10,
    quantityUnit: 'kg',
    status: 'pending',
    expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TradingService,
        {
          provide: getRepositoryToken(Order),
          useValue: {
            save: jest.fn(),
            findOne: jest.fn(),
            createQueryBuilder: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(Quote),
          useValue: {
            save: jest.fn(),
            findOne: jest.fn(),
            findAndCount: jest.fn(),
            createQueryBuilder: jest.fn(),
            update: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(Lot),
          useValue: {
            findOne: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(User),
          useValue: {
            findOne: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<TradingService>(TradingService);
    ordersRepository = module.get<Repository<Order>>(getRepositoryToken(Order));
    quotesRepository = module.get<Repository<Quote>>(getRepositoryToken(Quote));
    lotsRepository = module.get<Repository<Lot>>(getRepositoryToken(Lot));
    usersRepository = module.get<Repository<User>>(getRepositoryToken(User));
  });

  describe('createOrder', () => {
    it('should create a new order', async () => {
      jest.spyOn(lotsRepository, 'findOne').mockResolvedValue(mockLot as any);
      jest
        .spyOn(ordersRepository, 'save')
        .mockResolvedValue({ ...mockOrder, id: 'new-order-id' } as any);
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue({ ...mockOrder, id: 'new-order-id' } as any);

      const result = await service.createOrder(mockBuyer.id, {
        lotId: 'lot-123',
        quantity: 10,
        quantityUnit: 'kg',
      });

      expect(result.buyerId).toBe(mockBuyer.id);
      expect(result.status).toBe('pending');
      expect(ordersRepository.save).toHaveBeenCalled();
    });

    it('should throw error if lot not found', async () => {
      jest.spyOn(lotsRepository, 'findOne').mockResolvedValue(null);

      await expect(
        service.createOrder(mockBuyer.id, {
          lotId: 'invalid-lot',
          quantity: 10,
          quantityUnit: 'kg',
        }),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw error if lot is deleted', async () => {
      const deletedLot = { ...mockLot, deletedAt: new Date() };
      jest.spyOn(lotsRepository, 'findOne').mockResolvedValue(deletedLot as any);

      await expect(
        service.createOrder(mockBuyer.id, {
          lotId: 'lot-123',
          quantity: 10,
          quantityUnit: 'kg',
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw error if buyer is the seller', async () => {
      jest.spyOn(lotsRepository, 'findOne').mockResolvedValue(mockLot as any);

      await expect(
        service.createOrder(mockSeller.id, {
          lotId: 'lot-123',
          quantity: 10,
          quantityUnit: 'kg',
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw error if quantity exceeds available', async () => {
      jest.spyOn(lotsRepository, 'findOne').mockResolvedValue(mockLot as any);

      await expect(
        service.createOrder(mockBuyer.id, {
          lotId: 'lot-123',
          quantity: 200,
          quantityUnit: 'kg',
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw error if quantity is zero or negative', async () => {
      jest.spyOn(lotsRepository, 'findOne').mockResolvedValue(mockLot as any);

      await expect(
        service.createOrder(mockBuyer.id, {
          lotId: 'lot-123',
          quantity: 0,
          quantityUnit: 'kg',
        }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('getOrderById', () => {
    it('should return order if user is buyer', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);

      const result = await service.getOrderById('order-123', mockBuyer.id);

      expect(result.id).toBe('order-123');
      expect(ordersRepository.findOne).toHaveBeenCalledWith({
        where: { id: 'order-123' },
        relations: ['lot', 'seller', 'buyer'],
      });
    });

    it('should return order if user is seller', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);

      const result = await service.getOrderById('order-123', mockSeller.id);

      expect(result.id).toBe('order-123');
    });

    it('should throw ForbiddenException if user is neither buyer nor seller', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);

      await expect(
        service.getOrderById('order-123', 'random-user'),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw NotFoundException if order not found', async () => {
      jest.spyOn(ordersRepository, 'findOne').mockResolvedValue(null);

      await expect(
        service.getOrderById('invalid-order', mockBuyer.id),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('confirmOrder', () => {
    it('should confirm order if buyer confirms', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);
      jest
        .spyOn(ordersRepository, 'save')
        .mockResolvedValue({ ...mockOrder, status: 'confirmed' } as any);
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValueOnce(mockOrder as any)
        .mockResolvedValueOnce({ ...mockOrder, status: 'confirmed' } as any);

      const result = await service.confirmOrder('order-123', mockBuyer.id);

      expect(result.status).toBe('confirmed');
      expect(result.confirmedAt).toBeDefined();
    });

    it('should throw ForbiddenException if non-buyer tries to confirm', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);

      await expect(
        service.confirmOrder('order-123', 'random-user'),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw BadRequestException if order not in pending or quoted status', async () => {
      const confirmedOrder = { ...mockOrder, status: 'confirmed' };
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(confirmedOrder as any);

      await expect(
        service.confirmOrder('order-123', mockBuyer.id),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('cancelOrder', () => {
    it('should cancel order if buyer cancels', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);
      jest
        .spyOn(ordersRepository, 'save')
        .mockResolvedValue({ ...mockOrder, status: 'cancelled' } as any);

      const result = await service.cancelOrder('order-123', mockBuyer.id);

      expect(result.status).toBe('cancelled');
    });

    it('should cancel order if seller cancels', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);
      jest
        .spyOn(ordersRepository, 'save')
        .mockResolvedValue({ ...mockOrder, status: 'cancelled' } as any);

      const result = await service.cancelOrder('order-123', mockSeller.id);

      expect(result.status).toBe('cancelled');
    });

    it('should throw BadRequestException if order already shipped', async () => {
      const shippedOrder = { ...mockOrder, status: 'shipped' };
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(shippedOrder as any);

      await expect(
        service.cancelOrder('order-123', mockBuyer.id),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw ForbiddenException if unauthorized user tries to cancel', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);

      await expect(
        service.cancelOrder('order-123', 'random-user'),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('shipOrder', () => {
    it('should ship order if seller ships', async () => {
      const confirmedOrder = { ...mockOrder, status: 'confirmed' };
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(confirmedOrder as any);
      jest
        .spyOn(ordersRepository, 'save')
        .mockResolvedValue({ ...confirmedOrder, status: 'shipped' } as any);

      const result = await service.shipOrder('order-123', mockSeller.id);

      expect(result.status).toBe('shipped');
      expect(result.shippedAt).toBeDefined();
    });

    it('should throw ForbiddenException if non-seller tries to ship', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);

      await expect(
        service.shipOrder('order-123', mockBuyer.id),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('deliverOrder', () => {
    it('should deliver order if buyer confirms delivery', async () => {
      const shippedOrder = { ...mockOrder, status: 'shipped' };
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(shippedOrder as any);
      jest
        .spyOn(ordersRepository, 'save')
        .mockResolvedValue({ ...shippedOrder, status: 'delivered' } as any);

      const result = await service.deliverOrder('order-123', mockBuyer.id);

      expect(result.status).toBe('delivered');
      expect(result.deliveredAt).toBeDefined();
    });

    it('should throw ForbiddenException if non-buyer tries to confirm delivery', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);

      await expect(
        service.deliverOrder('order-123', mockSeller.id),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('createQuote', () => {
    it('should create a quote from seller to buyer', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);
      jest
        .spyOn(quotesRepository, 'save')
        .mockResolvedValue(mockQuote as any);
      jest
        .spyOn(quotesRepository, 'findOne')
        .mockResolvedValue(mockQuote as any);

      const result = await service.createQuote(mockSeller.id, {
        orderId: 'order-123',
        quotedPrice: 9500,
        quotedQuantity: 10,
        quantityUnit: 'kg',
      });

      expect(result.fromUserId).toBe(mockSeller.id);
      expect(result.quoteType).toBe('seller_quote');
      expect(result.status).toBe('pending');
    });

    it('should throw ForbiddenException if non-seller tries to create quote', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);

      await expect(
        service.createQuote(mockBuyer.id, {
          orderId: 'order-123',
          quotedPrice: 9500,
          quotedQuantity: 10,
          quantityUnit: 'kg',
        }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw NotFoundException if order not found', async () => {
      jest.spyOn(ordersRepository, 'findOne').mockResolvedValue(null);

      await expect(
        service.createQuote(mockSeller.id, {
          orderId: 'invalid-order',
          quotedPrice: 9500,
          quotedQuantity: 10,
          quantityUnit: 'kg',
        }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('acceptQuote', () => {
    it('should accept a quote', async () => {
      jest
        .spyOn(quotesRepository, 'findOne')
        .mockResolvedValue(mockQuote as any);
      jest
        .spyOn(quotesRepository, 'save')
        .mockResolvedValue({ ...mockQuote, status: 'accepted' } as any);
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);

      const result = await service.acceptQuote('quote-123', mockBuyer.id);

      expect(result.status).toBe('accepted');
      expect(result.acceptedAt).toBeDefined();
    });

    it('should throw ForbiddenException if non-recipient tries to accept', async () => {
      jest
        .spyOn(quotesRepository, 'findOne')
        .mockResolvedValue(mockQuote as any);

      await expect(
        service.acceptQuote('quote-123', mockSeller.id),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw BadRequestException if quote is expired', async () => {
      const expiredQuote = {
        ...mockQuote,
        expiresAt: new Date(Date.now() - 1000),
      };
      jest
        .spyOn(quotesRepository, 'findOne')
        .mockResolvedValue(expiredQuote as any);
      jest
        .spyOn(quotesRepository, 'save')
        .mockResolvedValue({ ...expiredQuote, status: 'expired' } as any);

      await expect(
        service.acceptQuote('quote-123', mockBuyer.id),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('rejectQuote', () => {
    it('should reject a quote', async () => {
      jest
        .spyOn(quotesRepository, 'findOne')
        .mockResolvedValue(mockQuote as any);
      jest
        .spyOn(quotesRepository, 'save')
        .mockResolvedValue({ ...mockQuote, status: 'rejected' } as any);

      const result = await service.rejectQuote(
        'quote-123',
        mockBuyer.id,
        { quoteId: 'quote-123', rejectionReason: 'Price too high' },
      );

      expect(result.status).toBe('rejected');
      expect(result.rejectedAt).toBeDefined();
    });

    it('should throw ForbiddenException if non-recipient tries to reject', async () => {
      jest
        .spyOn(quotesRepository, 'findOne')
        .mockResolvedValue(mockQuote as any);

      await expect(
        service.rejectQuote('quote-123', mockSeller.id, {
          quoteId: 'quote-123',
        }),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('submitCounterQuote', () => {
    it('should submit a counter quote', async () => {
      jest
        .spyOn(quotesRepository, 'findOne')
        .mockResolvedValue(mockQuote as any);
      jest
        .spyOn(quotesRepository, 'save')
        .mockResolvedValue({
          ...mockQuote,
          id: 'counter-quote-123',
          quoteType: 'buyer_counter_offer',
        } as any);
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);

      const result = await service.submitCounterQuote(
        'quote-123',
        mockBuyer.id,
        {
          originalQuoteId: 'quote-123',
          quotedPrice: 9000,
          quotedQuantity: 10,
          quantityUnit: 'kg',
        },
      );

      expect(result.quoteType).toBe('buyer_counter_offer');
      expect(result.status).toBe('pending');
    });
  });

  describe('rateOrder', () => {
    it('should rate order from buyer perspective', async () => {
      const deliveredOrder = { ...mockOrder, status: 'delivered' };
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(deliveredOrder as any);
      jest
        .spyOn(ordersRepository, 'save')
        .mockResolvedValue({
          ...deliveredOrder,
          sellerRating: 5,
          sellerReview: 'Great seller!',
        } as any);

      const result = await service.rateOrder(
        'order-123',
        mockBuyer.id,
        5,
        'Great seller!',
      );

      expect(result.sellerRating).toBe(5);
      expect(result.sellerReview).toBe('Great seller!');
    });

    it('should rate order from seller perspective', async () => {
      const deliveredOrder = { ...mockOrder, status: 'delivered' };
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(deliveredOrder as any);
      jest
        .spyOn(ordersRepository, 'save')
        .mockResolvedValue({
          ...deliveredOrder,
          buyerRating: 4,
          buyerReview: 'Good buyer',
        } as any);

      const result = await service.rateOrder(
        'order-123',
        mockSeller.id,
        4,
        'Good buyer',
      );

      expect(result.buyerRating).toBe(4);
      expect(result.buyerReview).toBe('Good buyer');
    });

    it('should throw BadRequestException if rating out of range', async () => {
      const deliveredOrder = { ...mockOrder, status: 'delivered' };
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(deliveredOrder as any);

      await expect(
        service.rateOrder('order-123', mockBuyer.id, 10, 'Too high!'),
      ).rejects.toThrow(BadRequestException);

      await expect(
        service.rateOrder('order-123', mockBuyer.id, 0, 'Too low!'),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if rating non-delivered order', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);

      await expect(
        service.rateOrder('order-123', mockBuyer.id, 5, 'Great!'),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('completeOrder', () => {
    it('should complete a delivered order', async () => {
      const deliveredOrder = { ...mockOrder, status: 'delivered' };
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(deliveredOrder as any);
      jest
        .spyOn(ordersRepository, 'save')
        .mockResolvedValue({ ...deliveredOrder, status: 'completed' } as any);

      const result = await service.completeOrder('order-123', mockBuyer.id);

      expect(result.status).toBe('completed');
      expect(result.completedAt).toBeDefined();
    });

    it('should throw BadRequestException if order not delivered', async () => {
      jest
        .spyOn(ordersRepository, 'findOne')
        .mockResolvedValue(mockOrder as any);

      await expect(
        service.completeOrder('order-123', mockBuyer.id),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
