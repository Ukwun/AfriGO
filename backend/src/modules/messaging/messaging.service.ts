import { Injectable, BadRequestException, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In, MoreThan, LessThan } from 'typeorm';
import { Message } from './entities/message.entity';
import { User } from '../auth/entities/user.entity';
import { Order } from '../trading/entities/order.entity';
import {
  CreateMessageDto,
  UpdateMessageDto,
  MessageResponseDto,
  ConversationDto,
  ConversationMessagesDto,
  MarkMessageAsReadDto,
} from './dtos/message.dto';

@Injectable()
export class MessagingService {
  constructor(
    @InjectRepository(Message)
    private messageRepository: Repository<Message>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Order)
    private orderRepository: Repository<Order>,
  ) {}

  /**
   * Generate conversation ID from two user IDs (always sorted)
   */
  private generateConversationId(userId1: string, userId2: string): string {
    const [id1, id2] = [userId1, userId2].sort();
    return `${id1}_${id2}`;
  }

  /**
   * Send a new message
   */
  async sendMessage(
    senderId: string,
    createMessageDto: CreateMessageDto,
  ): Promise<MessageResponseDto> {
    const { recipientId, content, orderId, attachments, metadata } = createMessageDto;

    // Validate sender and recipient exist
    const [sender, recipient] = await Promise.all([
      this.userRepository.findOne({ where: { id: senderId } }),
      this.userRepository.findOne({ where: { id: recipientId } }),
    ]);

    if (!sender || !recipient) {
      throw new BadRequestException('Sender or recipient user not found');
    }

    if (senderId === recipientId) {
      throw new BadRequestException('Cannot message yourself');
    }

    // Validate order if provided
    if (orderId) {
      const order = await this.orderRepository.findOne({
        where: { id: orderId },
      });
      if (!order) {
        throw new BadRequestException('Order not found');
      }

      // Only order buyer or seller can participate
      if (senderId !== order.buyerId && senderId !== order.sellerId) {
        throw new ForbiddenException('Not authorized for this order');
      }
    }

    const conversationId = this.generateConversationId(senderId, recipientId);

    const message = this.messageRepository.create({
      conversationId,
      senderId,
      recipientId,
      order: orderId ? { id: orderId } : undefined,
      orderId,
      content,
      messageType: createMessageDto.messageType || 'text',
      attachments,
      metadata,
      isRead: false,
    });

    const savedMessage = await this.messageRepository.save(message);
    return this.formatMessageResponse(savedMessage);
  }

  /**
   * Get all conversations for a user (with last message preview)
   */
  async getConversations(
    userId: string,
    page: number = 1,
    limit: number = 20,
  ): Promise<ConversationDto[]> {
    const skip = (page - 1) * limit;

    // Get all unique conversations for the user
    // Query: messages where user is either sender or recipient
    const userMessages = await this.messageRepository
      .createQueryBuilder('message')
      .where(
        '(message.senderId = :userId OR message.recipientId = :userId)',
        { userId },
      )
      .orderBy('message.createdAt', 'DESC')
      .getMany();

    // Group by conversationId and get unique conversations
    const conversationMap = new Map<string, Message>();
    for (const message of userMessages) {
      if (!conversationMap.has(message.conversationId)) {
        conversationMap.set(message.conversationId, message);
      }
    }

    const conversations = Array.from(conversationMap.values())
      .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())
      .slice(skip, skip + limit);

    // Map to DTO with last message and unread count
    const result: ConversationDto[] = [];
    for (const message of conversations) {
      const otherUserId =
        message.senderId === userId ? message.recipientId : message.senderId;
      const otherUser = await this.userRepository.findOne({
        where: { id: otherUserId },
        select: ['id', 'name', 'avatar'],
      });

      const unreadCount = await this.messageRepository.count({
        where: {
          conversationId: message.conversationId,
          recipientId: userId,
          isRead: false,
        },
      });

      result.push({
        conversationId: message.conversationId,
        otherUserId,
        otherUser: {
          id: otherUser.id,
          name: otherUser.name,
          avatar: otherUser.avatar,
        },
        lastMessage: this.formatMessageResponse(message),
        unreadCount,
        lastMessageAt: message.createdAt,
      });
    }

    return result;
  }

  /**
   * Get all messages in a conversation with pagination
   */
  async getConversation(
    userId: string,
    otherUserId: string,
    page: number = 1,
    limit: number = 50,
  ): Promise<ConversationMessagesDto> {
    const conversationId = this.generateConversationId(userId, otherUserId);
    const skip = (page - 1) * limit;

    // Validate other user exists
    const otherUser = await this.userRepository.findOne({
      where: { id: otherUserId },
      select: ['id', 'name', 'avatar'],
    });

    if (!otherUser) {
      throw new NotFoundException('User not found');
    }

    // Get messages in conversation
    const [messages, totalCount] = await this.messageRepository.findAndCount({
      where: { conversationId },
      order: { createdAt: 'DESC' },
      skip,
      take: limit,
    });

    // Mark all unread messages as read for the current user
    await this.messageRepository.update(
      {
        conversationId,
        recipientId: userId,
        isRead: false,
      },
      { isRead: true, readAt: new Date() },
    );

    const messageResponses = messages
      .map((msg) => this.formatMessageResponse(msg))
      .reverse(); // Reverse to get chronological order

    return {
      conversationId,
      messages: messageResponses,
      otherUser: {
        id: otherUser.id,
        name: otherUser.name,
        avatar: otherUser.avatar,
      },
      totalCount,
      page,
      limit,
    };
  }

  /**
   * Get conversation by order ID
   */
  async getConversationByOrder(
    userId: string,
    orderId: string,
  ): Promise<ConversationMessagesDto> {
    const order = await this.orderRepository.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new NotFoundException('Order not found');
    }

    // Only buyer or seller can see order conversation
    if (userId !== order.buyerId && userId !== order.sellerId) {
      throw new ForbiddenException('Not authorized for this order');
    }

    const otherUserId =
      userId === order.buyerId ? order.sellerId : order.buyerId;
    return this.getConversation(userId, otherUserId);
  }

  /**
   * Mark messages as read
   */
  async markMessagesAsRead(
    userId: string,
    messageIds: string[],
  ): Promise<void> {
    // Verify all messages belong to the user
    const messages = await this.messageRepository.find({
      where: { id: In(messageIds) },
    });

    const unauthorized = messages.some((msg) => msg.recipientId !== userId);
    if (unauthorized) {
      throw new ForbiddenException('Not authorized to mark these messages');
    }

    await this.messageRepository.update(
      { id: In(messageIds) },
      { isRead: true, readAt: new Date() },
    );
  }

  /**
   * Mark entire conversation as read
   */
  async markConversationAsRead(
    userId: string,
    otherUserId: string,
  ): Promise<void> {
    const conversationId = this.generateConversationId(userId, otherUserId);

    await this.messageRepository.update(
      {
        conversationId,
        recipientId: userId,
        isRead: false,
      },
      { isRead: true, readAt: new Date() },
    );
  }

  /**
   * Update message content (only sender can edit within 5 minutes)
   */
  async updateMessage(
    userId: string,
    messageId: string,
    updateMessageDto: UpdateMessageDto,
  ): Promise<MessageResponseDto> {
    const message = await this.messageRepository.findOne({
      where: { id: messageId },
    });

    if (!message) {
      throw new NotFoundException('Message not found');
    }

    if (message.senderId !== userId) {
      throw new ForbiddenException('Only sender can edit this message');
    }

    // Check if message is older than 5 minutes
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
    if (message.createdAt < fiveMinutesAgo) {
      throw new BadRequestException('Cannot edit messages older than 5 minutes');
    }

    Object.assign(message, updateMessageDto);
    const updated = await this.messageRepository.save(message);
    return this.formatMessageResponse(updated);
  }

  /**
   * Delete message (soft delete)
   */
  async deleteMessage(userId: string, messageId: string): Promise<void> {
    const message = await this.messageRepository.findOne({
      where: { id: messageId },
    });

    if (!message) {
      throw new NotFoundException('Message not found');
    }

    if (message.senderId !== userId && message.recipientId !== userId) {
      throw new ForbiddenException('Not authorized to delete this message');
    }

    await this.messageRepository.softDelete(messageId);
  }

  /**
   * Get unread message count for user
   */
  async getUnreadCount(userId: string): Promise<number> {
    return this.messageRepository.count({
      where: {
        recipientId: userId,
        isRead: false,
      },
    });
  }

  /**
   * Search messages in a conversation
   */
  async searchMessages(
    userId: string,
    otherUserId: string,
    query: string,
    limit: number = 20,
  ): Promise<MessageResponseDto[]> {
    const conversationId = this.generateConversationId(userId, otherUserId);

    const messages = await this.messageRepository
      .createQueryBuilder('message')
      .where('message.conversationId = :conversationId', { conversationId })
      .andWhere('message.content ILIKE :query', {
        query: `%${query}%`,
      })
      .orderBy('message.createdAt', 'DESC')
      .take(limit)
      .getMany();

    return messages
      .reverse()
      .map((msg) => this.formatMessageResponse(msg));
  }

  /**
   * Get message count for a conversation
   */
  async getConversationMessageCount(
    userId: string,
    otherUserId: string,
  ): Promise<number> {
    const conversationId = this.generateConversationId(userId, otherUserId);
    return this.messageRepository.count({ where: { conversationId } });
  }

  /**
   * Format message for response
   */
  private formatMessageResponse(message: Message): MessageResponseDto {
    return {
      id: message.id,
      conversationId: message.conversationId,
      senderId: message.senderId,
      sender: {
        id: message.sender.id,
        name: message.sender.name,
        avatar: message.sender.avatar,
      },
      recipientId: message.recipientId,
      recipient: {
        id: message.recipient.id,
        name: message.recipient.name,
        avatar: message.recipient.avatar,
      },
      orderId: message.orderId,
      content: message.content,
      messageType: message.messageType,
      attachments: message.attachments,
      metadata: message.metadata,
      isRead: message.isRead,
      readAt: message.readAt,
      createdAt: message.createdAt,
      updatedAt: message.updatedAt,
    };
  }
}
