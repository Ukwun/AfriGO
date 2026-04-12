import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
  InternalServerErrorException,
} from '@nestjs/common';
import { PaymentsService } from '../payments.service';
import { Payment } from '../entities/payment.entity';
import { Order } from '../../trading/entities/order.entity';
import { User } from '../../auth/entities/user.entity';
import Stripe from 'stripe';

describe('PaymentsService', () => {
  let service: PaymentsService;
  let paymentRepository: any;
  let orderRepository: any;
  let userRepository: any;
  let configService: any;

  const mockPaymentRepository = {
    create: jest.fn(),
    save: jest.fn(),
    findOne: jest.fn(),
    find: jest.fn(),
    findAndCount: jest.fn(),
  };

  const mockOrderRepository = {
    findOne: jest.fn(),
    update: jest.fn(),
  };

  const mockUserRepository = {
    findOne: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn((key) => {
      const config = {
        STRIPE_SECRET_KEY: 'sk_test_secret',
        STRIPE_PUBLISHABLE_KEY: 'pk_test_public',
      };
      return config[key];
    }),
  };

  beforeEach(async () => {
    // Reset all mocks
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PaymentsService,
        {
          provide: getRepositoryToken(Payment),
          useValue: mockPaymentRepository,
        },
        {
          provide: getRepositoryToken(Order),
          useValue: mockOrderRepository,
        },
        {
          provide: getRepositoryToken(User),
          useValue: mockUserRepository,
        },
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
      ],
    }).compile();

    service = module.get<PaymentsService>(PaymentsService);
    paymentRepository = module.get(getRepositoryToken(Payment));
    orderRepository = module.get(getRepositoryToken(Order));
    userRepository = module.get(getRepositoryToken(User));
    configService = module.get(ConfigService);
  });

  describe('getPublishableKey', () => {
    it('should return Stripe publishable key', () => {
      const key = service.getPublishableKey();
      expect(key).toBe('pk_test_public');
    });
  });

  describe('createPayment', () => {
    it('should create a payment successfully', async () => {
      const userId = 'user-123';
      const orderId = 'order-456';
      const createPaymentDto = {
        orderId,
        amount: 100,
        currency: 'USD',
        paymentMethodId: 'pm_test_123',
        description: 'Test payment',
      };

      const mockOrder = {
        id: orderId,
        buyerId: userId,
        status: 'pending',
      };

      const mockPaymentIntent = {
        id: 'pi_test_123',
        status: 'succeeded',
        payment_method: 'pm_test_123',
        charges: {
          data: [
            {
              id: 'ch_test_123',
              payment_method_details: {
                card: {
                  brand: 'visa',
                  last4: '4242',
                  exp_month: 12,
                  exp_year: 2025,
                },
              },
            },
          ],
        },
      };

      const mockPayment = {
        id: 'payment-123',
        orderId,
        userId,
        amount: 100,
        currency: 'USD',
        status: 'succeeded',
        escrowStatus: 'held',
        stripePaymentIntentId: 'pi_test_123',
        stripeChargeId: 'ch_test_123',
        paidAt: new Date(),
        cardInfo: {
          brand: 'visa',
          last4: '4242',
        },
      };

      orderRepository.findOne.mockResolvedValue(mockOrder);
      paymentRepository.create.mockReturnValue(mockPayment);
      paymentRepository.save.mockResolvedValue(mockPayment);
      orderRepository.update.mockResolvedValue({ affected: 1 });

      // Mock Stripe call
      jest.spyOn(service['stripe'].paymentIntents, 'create').mockResolvedValue(
        mockPaymentIntent as any,
      );

      const result = await service.createPayment(userId, createPaymentDto);

      expect(result.id).toBe('payment-123');
      expect(result.status).toBe('succeeded');
      expect(paymentRepository.save).toHaveBeenCalled();
      expect(orderRepository.update).toHaveBeenCalledWith(
        { id: orderId },
        { status: 'confirmed', paymentStatus: 'paid' },
      );
    });

    it('should throw NotFoundException if order not found', async () => {
      const userId = 'user-123';
      const createPaymentDto = {
        orderId: 'nonexistent',
        amount: 100,
        currency: 'USD',
        paymentMethodId: 'pm_test_123',
        description: 'Test payment',
      };

      orderRepository.findOne.mockResolvedValue(null);

      await expect(
        service.createPayment(userId, createPaymentDto),
      ).rejects.toThrow(NotFoundException);
    });

    it('should throw ForbiddenException if user is not buyer', async () => {
      const userId = 'user-123';
      const createPaymentDto = {
        orderId: 'order-456',
        amount: 100,
        currency: 'USD',
        paymentMethodId: 'pm_test_123',
        description: 'Test payment',
      };

      const mockOrder = {
        id: 'order-456',
        buyerId: 'different-user',
        status: 'pending',
      };

      orderRepository.findOne.mockResolvedValue(mockOrder);

      await expect(
        service.createPayment(userId, createPaymentDto),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw BadRequestException if order already paid', async () => {
      const userId = 'user-123';
      const orderId = 'order-456';
      const createPaymentDto = {
        orderId,
        amount: 100,
        currency: 'USD',
        paymentMethodId: 'pm_test_123',
        description: 'Test payment',
      };

      const mockOrder = {
        id: orderId,
        buyerId: userId,
        status: 'pending',
      };

      const existingPayment = {
        id: 'payment-123',
        status: 'succeeded',
      };

      orderRepository.findOne.mockResolvedValue(mockOrder);
      paymentRepository.findOne.mockResolvedValue(existingPayment);

      await expect(
        service.createPayment(userId, createPaymentDto),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if Stripe fails', async () => {
      const userId = 'user-123';
      const createPaymentDto = {
        orderId: 'order-456',
        amount: 100,
        currency: 'USD',
        paymentMethodId: 'pm_test_123',
        description: 'Test payment',
      };

      const mockOrder = {
        id: 'order-456',
        buyerId: userId,
        status: 'pending',
      };

      orderRepository.findOne.mockResolvedValue(mockOrder);
      paymentRepository.findOne.mockResolvedValue(null);

      jest
        .spyOn(service['stripe'].paymentIntents, 'create')
        .mockRejectedValue(
          new Stripe.errors.StripeAPIError('Card declined', '402', 'card_error'),
        );

      await expect(
        service.createPayment(userId, createPaymentDto),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('confirmPayment', () => {
    it('should confirm a payment successfully', async () => {
      const userId = 'user-123';
      const paymentId = 'payment-123';
      const confirmPaymentDto = {
        paymentIntentId: 'pi_test_123',
        paymentMethodId: 'pm_test_123',
      };

      const mockPayment = {
        id: paymentId,
        userId,
        orderId: 'order-456',
        amount: 100,
        status: 'pending',
      };

      const mockPaymentIntent = {
        id: 'pi_test_123',
        status: 'succeeded',
        charges: {
          data: [{ id: 'ch_test_123' }],
        },
      };

      paymentRepository.findOne.mockResolvedValue(mockPayment);
      jest
        .spyOn(service['stripe'].paymentIntents, 'confirm')
        .mockResolvedValue(mockPaymentIntent as any);
      paymentRepository.save.mockResolvedValue({
        ...mockPayment,
        status: 'succeeded',
      });
      orderRepository.update.mockResolvedValue({ affected: 1 });

      const result = await service.confirmPayment(
        userId,
        paymentId,
        confirmPaymentDto,
      );

      expect(result.status).toBe('succeeded');
      expect(paymentRepository.save).toHaveBeenCalled();
    });

    it('should throw ForbiddenException if user not authorized', async () => {
      const userId = 'user-123';
      const paymentId = 'payment-123';

      const mockPayment = {
        id: paymentId,
        userId: 'different-user',
      };

      paymentRepository.findOne.mockResolvedValue(mockPayment);

      await expect(
        service.confirmPayment(userId, paymentId, {} as any),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('getPayment', () => {
    it('should get payment by ID', async () => {
      const userId = 'user-123';
      const paymentId = 'payment-123';

      const mockPayment = {
        id: paymentId,
        userId,
        status: 'succeeded',
      };

      paymentRepository.findOne.mockResolvedValue(mockPayment);

      const result = await service.getPayment(userId, paymentId);

      expect(result.id).toBe(paymentId);
      expect(paymentRepository.findOne).toHaveBeenCalledWith({
        where: { id: paymentId },
      });
    });

    it('should throw NotFoundException if payment not found', async () => {
      paymentRepository.findOne.mockResolvedValue(null);

      await expect(
        service.getPayment('user-123', 'nonexistent'),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('getOrderPayments', () => {
    it('should get payments for an order', async () => {
      const userId = 'user-123';
      const orderId = 'order-456';

      const mockOrder = {
        id: orderId,
        buyerId: userId,
      };

      const mockPayments = [
        { id: 'payment-123', orderId, status: 'succeeded' },
      ];

      orderRepository.findOne.mockResolvedValue(mockOrder);
      paymentRepository.find.mockResolvedValue(mockPayments);

      const result = await service.getOrderPayments(userId, orderId);

      expect(result).toHaveLength(1);
      expect(paymentRepository.find).toHaveBeenCalled();
    });

    it('should throw ForbiddenException if user not authorized', async () => {
      const userId = 'user-123';
      const orderId = 'order-456';

      const mockOrder = {
        id: orderId,
        buyerId: 'different-buyer',
        sellerId: 'different-seller',
      };

      orderRepository.findOne.mockResolvedValue(mockOrder);

      await expect(
        service.getOrderPayments(userId, orderId),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('refundPayment', () => {
    it('should refund a payment', async () => {
      const userId = 'user-123';
      const paymentId = 'payment-123';

      const mockPayment = {
        id: paymentId,
        userId,
        orderId: 'order-456',
        status: 'succeeded',
        stripePaymentIntentId: 'pi_test_123',
      };

      const mockOrder = {
        id: 'order-456',
        buyerId: userId,
      };

      const mockRefund = {
        id: 're_test_123',
        status: 'succeeded',
      };

      paymentRepository.findOne.mockResolvedValue(mockPayment);
      orderRepository.findOne.mockResolvedValue(mockOrder);
      jest
        .spyOn(service['stripe'].refunds, 'create')
        .mockResolvedValue(mockRefund as any);
      paymentRepository.save.mockResolvedValue({
        ...mockPayment,
        status: 'refunded',
      });
      orderRepository.update.mockResolvedValue({ affected: 1 });

      const result = await service.refundPayment(
        userId,
        paymentId,
        { reason: 'Customer request' },
      );

      expect(result.status).toBe('refunded');
      expect(paymentRepository.save).toHaveBeenCalled();
    });

    it('should throw BadRequestException if payment not succeeded', async () => {
      const userId = 'user-123';
      const paymentId = 'payment-123';

      const mockPayment = {
        id: paymentId,
        userId,
        status: 'failed',
      };

      paymentRepository.findOne.mockResolvedValue(mockPayment);

      await expect(
        service.refundPayment(userId, paymentId, { reason: 'Test' }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('releaseEscrow', () => {
    it('should release escrow funds', async () => {
      const paymentId = 'payment-123';

      const mockPayment = {
        id: paymentId,
        escrowStatus: 'held',
      };

      paymentRepository.findOne.mockResolvedValue(mockPayment);
      paymentRepository.save.mockResolvedValue({
        ...mockPayment,
        escrowStatus: 'released',
      });

      const result = await service.releaseEscrow(paymentId);

      expect(result.escrowStatus).toBe('released');
      expect(paymentRepository.save).toHaveBeenCalled();
    });

    it('should throw BadRequestException if not in escrow', async () => {
      const paymentId = 'payment-123';

      const mockPayment = {
        id: paymentId,
        escrowStatus: 'released',
      };

      paymentRepository.findOne.mockResolvedValue(mockPayment);

      await expect(service.releaseEscrow(paymentId)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('getUserPaymentHistory', () => {
    it('should get user payment history with pagination', async () => {
      const userId = 'user-123';

      const mockPayments = [
        { id: 'payment-123', status: 'succeeded' },
        { id: 'payment-124', status: 'succeeded' },
      ];

      paymentRepository.findAndCount.mockResolvedValue([mockPayments, 2]);

      const result = await service.getUserPaymentHistory(userId, 1, 20);

      expect(result.payments).toHaveLength(2);
      expect(result.total).toBe(2);
      expect(paymentRepository.findAndCount).toHaveBeenCalled();
    });

    it('should default to page 1 and limit 20', async () => {
      const userId = 'user-123';

      paymentRepository.findAndCount.mockResolvedValue([[], 0]);

      await service.getUserPaymentHistory(userId);

      expect(paymentRepository.findAndCount).toHaveBeenCalledWith({
        where: { userId },
        order: { createdAt: 'DESC' },
        skip: 0,
        take: 20,
      });
    });
  });

  describe('handleWebhookEvent', () => {
    it('should handle payment_intent.succeeded event', async () => {
      const mockPayment = {
        id: 'payment-123',
        stripePaymentIntentId: 'pi_test_123',
        status: 'pending',
      };

      paymentRepository.findOne.mockResolvedValue(mockPayment);
      paymentRepository.save.mockResolvedValue({
        ...mockPayment,
        status: 'succeeded',
      });

      const event: any = {
        type: 'payment_intent.succeeded',
        data: {
          object: {
            id: 'pi_test_123',
            status: 'succeeded',
            metadata: { orderId: 'order-123' },
          },
        },
      };

      await service.handleWebhookEvent(event);

      expect(paymentRepository.findOne).toHaveBeenCalled();
    });

    it('should handle payment_intent.payment_failed event', async () => {
      const mockPayment = {
        id: 'payment-123',
        stripePaymentIntentId: 'pi_test_123',
        status: 'succeeded',
      };

      paymentRepository.findOne.mockResolvedValue(mockPayment);
      paymentRepository.save.mockResolvedValue({
        ...mockPayment,
        status: 'failed',
      });

      const event: any = {
        type: 'payment_intent.payment_failed',
        data: {
          object: {
            id: 'pi_test_123',
            status: 'requires_payment_method',
            last_payment_error: { message: 'Card declined' },
          },
        },
      };

      await service.handleWebhookEvent(event);

      expect(paymentRepository.findOne).toHaveBeenCalled();
    });

    it('should handle charge.refunded event', async () => {
      const mockPayment = {
        id: 'payment-123',
        stripeChargeId: 'ch_test_123',
        status: 'succeeded',
      };

      paymentRepository.findOne.mockResolvedValue(mockPayment);
      paymentRepository.save.mockResolvedValue({
        ...mockPayment,
        status: 'refunded',
      });

      const event: any = {
        type: 'charge.refunded',
        data: {
          object: {
            id: 'ch_test_123',
            payment_intent: 'pi_test_123',
          },
        },
      };

      await service.handleWebhookEvent(event);

      expect(paymentRepository.findOne).toHaveBeenCalled();
    });
  });
});
