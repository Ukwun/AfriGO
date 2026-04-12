import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { MessagingService } from '../messaging.service';
import { Message } from '../entities/message.entity';
import { User } from '../../auth/entities/user.entity';
import { Order } from '../../trading/entities/order.entity';
import { BadRequestException, NotFoundException, ForbiddenException } from '@nestjs/common';

describe('MessagingService', () => {
  let service: MessagingService;
  let messageRepository: any;
  let userRepository: any;
  let orderRepository: any;

  const mockUser = {
    id: 'user-1',
    email: 'test@example.com',
    name: 'Test User',
    avatar: null,
  };

  const mockOtherUser = {
    id: 'user-2',
    email: 'other@example.com',
    name: 'Other User',
    avatar: null,
  };

  const mockOrder = {
    id: 'order-1',
    buyerId: 'user-1',
    sellerId: 'user-2',
    lotId: 'lot-1',
    quantity: 100,
    totalPrice: 5000,
    status: 'pending',
  };

  const mockMessage = {
    id: 'msg-1',
    conversationId: 'user-1_user-2',
    senderId: 'user-1',
    sender: mockUser,
    recipientId: 'user-2',
    recipient: mockOtherUser,
    orderId: null,
    content: 'Hello there',
    messageType: 'text',
    attachments: null,
    metadata: null,
    isRead: false,
    readAt: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    deletedAt: null,
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MessagingService,
        {
          provide: getRepositoryToken(Message),
          useValue: {
            create: jest.fn(),
            save: jest.fn(),
            find: jest.fn(),
            findOne: jest.fn(),
            findAndCount: jest.fn(),
            count: jest.fn(),
            update: jest.fn(),
            softDelete: jest.fn(),
            createQueryBuilder: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(User),
          useValue: {
            findOne: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(Order),
          useValue: {
            findOne: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<MessagingService>(MessagingService);
    messageRepository = module.get(getRepositoryToken(Message));
    userRepository = module.get(getRepositoryToken(User));
    orderRepository = module.get(getRepositoryToken(Order));
  });

  describe('sendMessage', () => {
    it('should send a message successfully', async () => {
      userRepository.findOne.mockResolvedValueOnce(mockUser);
      userRepository.findOne.mockResolvedValueOnce(mockOtherUser);
      messageRepository.create.mockReturnValue(mockMessage);
      messageRepository.save.mockResolvedValue(mockMessage);

      const createMessageDto = {
        recipientId: 'user-2',
        content: 'Hello there',
      };

      const result = await service.sendMessage('user-1', createMessageDto);

      expect(result.content).toBe('Hello there');
      expect(result.senderId).toBe('user-1');
      expect(messageRepository.create).toHaveBeenCalled();
      expect(messageRepository.save).toHaveBeenCalled();
    });

    it('should throw error if recipient not found', async () => {
      userRepository.findOne.mockResolvedValueOnce(mockUser);
      userRepository.findOne.mockResolvedValueOnce(null);

      const createMessageDto = {
        recipientId: 'invalid-user',
        content: 'Hello',
      };

      await expect(
        service.sendMessage('user-1', createMessageDto),
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw error if trying to message yourself', async () => {
      userRepository.findOne.mockResolvedValueOnce(mockUser);
      userRepository.findOne.mockResolvedValueOnce(mockUser);

      const createMessageDto = {
        recipientId: 'user-1',
        content: 'Hello',
      };

      await expect(
        service.sendMessage('user-1', createMessageDto),
      ).rejects.toThrow(BadRequestException);
    });

    it('should validate order if orderId provided', async () => {
      userRepository.findOne.mockResolvedValueOnce(mockUser);
      userRepository.findOne.mockResolvedValueOnce(mockOtherUser);
      orderRepository.findOne.mockResolvedValueOnce(null);

      const createMessageDto = {
        recipientId: 'user-2',
        content: 'Hello',
        orderId: 'invalid-order',
      };

      await expect(
        service.sendMessage('user-1', createMessageDto),
      ).rejects.toThrow(BadRequestException);
    });

    it('should validate user is part of order', async () => {
      userRepository.findOne.mockResolvedValueOnce(mockUser);
      userRepository.findOne.mockResolvedValueOnce(mockOtherUser);
      orderRepository.findOne.mockResolvedValueOnce({
        ...mockOrder,
        buyerId: 'other-user',
        sellerId: 'another-user',
      });

      const createMessageDto = {
        recipientId: 'user-2',
        content: 'Hello',
        orderId: 'order-1',
      };

      await expect(
        service.sendMessage('user-1', createMessageDto),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('getConversations', () => {
    it('should get all conversations for user', async () => {
      const messages = [mockMessage];
      const queryBuilder = {
        where: jest.fn().returnThis(),
        andWhere: jest.fn().returnThis(),
        orderBy: jest.fn().returnThis(),
        getMany: jest.fn().resolvedValue(messages),
      };
      messageRepository.createQueryBuilder.mockReturnValue(queryBuilder);
      userRepository.findOne.mockResolvedValue(mockOtherUser);
      messageRepository.count.mockResolvedValue(0);

      const result = await service.getConversations('user-1', 1, 20);

      expect(result).toHaveLength(1);
      expect(result[0].otherUserId).toBe('user-2');
      expect(result[0].unreadCount).toBe(0);
    });
  });

  describe('getConversation', () => {
    it('should get messages in a conversation', async () => {
      userRepository.findOne.mockResolvedValueOnce(mockOtherUser);
      messageRepository.findAndCount.mockResolvedValueOnce([
        [mockMessage],
        1,
      ]);
      messageRepository.update.mockResolvedValue({ affected: 0 });

      const result = await service.getConversation('user-1', 'user-2', 1, 50);

      expect(result.messages).toHaveLength(1);
      expect(result.totalCount).toBe(1);
      expect(result.conversationId).toBe('user-1_user-2');
    });

    it('should throw error if other user not found', async () => {
      userRepository.findOne.mockResolvedValueOnce(null);

      await expect(
        service.getConversation('user-1', 'invalid-user', 1, 50),
      ).rejects.toThrow(NotFoundException);
    });

    it('should mark unread messages as read', async () => {
      userRepository.findOne.mockResolvedValueOnce(mockOtherUser);
      messageRepository.findAndCount.mockResolvedValueOnce([
        [mockMessage],
        1,
      ]);
      messageRepository.update.mockResolvedValue({ affected: 1 });

      await service.getConversation('user-1', 'user-2', 1, 50);

      expect(messageRepository.update).toHaveBeenCalledWith(
        {
          conversationId: 'user-1_user-2',
          recipientId: 'user-1',
          isRead: false,
        },
        expect.objectContaining({
          isRead: true,
        }),
      );
    });
  });

  describe('markMessagesAsRead', () => {
    it('should mark messages as read', async () => {
      messageRepository.find.mockResolvedValueOnce([
        { ...mockMessage, recipientId: 'user-1' },
      ]);
      messageRepository.update.mockResolvedValue({ affected: 1 });

      await service.markMessagesAsRead('user-1', ['msg-1']);

      expect(messageRepository.update).toHaveBeenCalledWith(
        { id: expect.any(Object) },
        expect.objectContaining({
          isRead: true,
        }),
      );
    });

    it('should throw error if user not recipient', async () => {
      messageRepository.find.mockResolvedValueOnce([
        { ...mockMessage, recipientId: 'user-2' },
      ]);

      await expect(
        service.markMessagesAsRead('user-1', ['msg-1']),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('updateMessage', () => {
    it('should update message if sender and within 5 minutes', async () => {
      messageRepository.findOne.mockResolvedValueOnce({
        ...mockMessage,
        senderId: 'user-1',
        createdAt: new Date(),
      });
      messageRepository.save.mockResolvedValueOnce({
        ...mockMessage,
        content: 'Updated message',
      });

      const result = await service.updateMessage('user-1', 'msg-1', {
        content: 'Updated message',
      });

      expect(result.content).toBe('Updated message');
    });

    it('should throw error if not sender', async () => {
      messageRepository.findOne.mockResolvedValueOnce({
        ...mockMessage,
        senderId: 'user-2',
      });

      await expect(
        service.updateMessage('user-1', 'msg-1', {
          content: 'Updated',
        }),
      ).rejects.toThrow(ForbiddenException);
    });

    it('should throw error if message older than 5 minutes', async () => {
      const oldDate = new Date(Date.now() - 6 * 60 * 1000);
      messageRepository.findOne.mockResolvedValueOnce({
        ...mockMessage,
        senderId: 'user-1',
        createdAt: oldDate,
      });

      await expect(
        service.updateMessage('user-1', 'msg-1', {
          content: 'Updated',
        }),
      ).rejects.toThrow(BadRequestException);
    });
  });

  describe('deleteMessage', () => {
    it('should soft delete message', async () => {
      messageRepository.findOne.mockResolvedValueOnce({
        ...mockMessage,
        senderId: 'user-1',
      });
      messageRepository.softDelete.mockResolvedValue({ affected: 1 });

      await service.deleteMessage('user-1', 'msg-1');

      expect(messageRepository.softDelete).toHaveBeenCalledWith('msg-1');
    });

    it('should throw error if not sender or recipient', async () => {
      messageRepository.findOne.mockResolvedValueOnce({
        ...mockMessage,
        senderId: 'user-2',
        recipientId: 'user-3',
      });

      await expect(
        service.deleteMessage('user-1', 'msg-1'),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe('getUnreadCount', () => {
    it('should return unread message count', async () => {
      messageRepository.count.mockResolvedValueOnce(5);

      const count = await service.getUnreadCount('user-1');

      expect(count).toBe(5);
      expect(messageRepository.count).toHaveBeenCalledWith({
        where: {
          recipientId: 'user-1',
          isRead: false,
        },
      });
    });
  });

  describe('searchMessages', () => {
    it('should search messages in conversation', async () => {
      const queryBuilder = {
        where: jest.fn().returnThis(),
        andWhere: jest.fn().returnThis(),
        orderBy: jest.fn().returnThis(),
        take: jest.fn().returnThis(),
        getMany: jest.fn().resolvedValue([mockMessage]),
      };
      messageRepository.createQueryBuilder.mockReturnValue(queryBuilder);

      const result = await service.searchMessages(
        'user-1',
        'user-2',
        'hello',
        20,
      );

      expect(result).toHaveLength(1);
    });
  });

  describe('getConversationMessageCount', () => {
    it('should return message count for conversation', async () => {
      messageRepository.count.mockResolvedValueOnce(42);

      const count = await service.getConversationMessageCount('user-1', 'user-2');

      expect(count).toBe(42);
    });
  });
});
