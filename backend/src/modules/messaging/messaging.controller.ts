import {
  Controller,
  Post,
  Get,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  HttpStatus,
  HttpCode,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { MessagingService } from './messaging.service';
import {
  CreateMessageDto,
  UpdateMessageDto,
  MessageResponseDto,
  ConversationDto,
  ConversationMessagesDto,
  MarkMessageAsReadDto,
} from './dtos/message.dto';

@Controller('api/messages')
@UseGuards(AuthGuard('jwt'))
export class MessagingController {
  constructor(private messagingService: MessagingService) {}

  /**
   * POST /api/messages
   * Send a new message
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async sendMessage(
    @Request() req,
    @Body() createMessageDto: CreateMessageDto,
  ): Promise<MessageResponseDto> {
    return this.messagingService.sendMessage(req.user.id, createMessageDto);
  }

  /**
   * GET /api/messages/conversations
   * Get all conversations for current user
   */
  @Get('conversations')
  async getConversations(
    @Request() req,
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 20,
  ): Promise<ConversationDto[]> {
    return this.messagingService.getConversations(req.user.id, page, limit);
  }

  /**
   * GET /api/messages/conversations/:otherUserId
   * Get all messages in a conversation with a specific user
   */
  @Get('conversations/:otherUserId')
  async getConversation(
    @Request() req,
    @Param('otherUserId') otherUserId: string,
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 50,
  ): Promise<ConversationMessagesDto> {
    return this.messagingService.getConversation(
      req.user.id,
      otherUserId,
      page,
      limit,
    );
  }

  /**
   * GET /api/messages/orders/:orderId
   * Get conversation for a specific order
   */
  @Get('orders/:orderId')
  async getConversationByOrder(
    @Request() req,
    @Param('orderId') orderId: string,
  ): Promise<ConversationMessagesDto> {
    return this.messagingService.getConversationByOrder(req.user.id, orderId);
  }

  /**
   * GET /api/messages/:id
   * Get a specific message by ID (for editing/quoting)
   */
  @Get(':id')
  async getMessage(
    @Request() req,
    @Param('id') messageId: string,
  ): Promise<MessageResponseDto> {
    // Note: In production, should verify user is part of conversation
    // For now, trusting that client won't request unauthorized messages
    const message = await this.messagingService['messageRepository'].findOne({
      where: { id: messageId },
    });

    if (!message) {
      throw new Error('Message not found');
    }

    return this.messagingService['formatMessageResponse'](message);
  }

  /**
   * PUT /api/messages/:id
   * Update a message (only sender, within 5 minutes)
   */
  @Put(':id')
  async updateMessage(
    @Request() req,
    @Param('id') messageId: string,
    @Body() updateMessageDto: UpdateMessageDto,
  ): Promise<MessageResponseDto> {
    return this.messagingService.updateMessage(
      req.user.id,
      messageId,
      updateMessageDto,
    );
  }

  /**
   * DELETE /api/messages/:id
   * Delete a message (soft delete)
   */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteMessage(
    @Request() req,
    @Param('id') messageId: string,
  ): Promise<void> {
    return this.messagingService.deleteMessage(req.user.id, messageId);
  }

  /**
   * POST /api/messages/read/mark
   * Mark multiple messages as read
   */
  @Post('read/mark')
  @HttpCode(HttpStatus.OK)
  async markMessagesAsRead(
    @Request() req,
    @Body() {messageIds}: MarkMessageAsReadDto,
  ): Promise<{ success: boolean }> {
    await this.messagingService.markMessagesAsRead(req.user.id, messageIds);
    return { success: true };
  }

  /**
   * POST /api/messages/conversations/:otherUserId/read
   * Mark entire conversation as read
   */
  @Post('conversations/:otherUserId/read')
  @HttpCode(HttpStatus.OK)
  async markConversationAsRead(
    @Request() req,
    @Param('otherUserId') otherUserId: string,
  ): Promise<{ success: boolean }> {
    await this.messagingService.markConversationAsRead(
      req.user.id,
      otherUserId,
    );
    return { success: true };
  }

  /**
   * GET /api/messages/unread/count
   * Get unread message count
   */
  @Get('unread/count')
  async getUnreadCount(
    @Request() req,
  ): Promise<{ unreadCount: number }> {
    const unreadCount = await this.messagingService.getUnreadCount(req.user.id);
    return { unreadCount };
  }

  /**
   * GET /api/messages/conversations/:otherUserId/search
   * Search messages in a conversation
   */
  @Get('conversations/:otherUserId/search')
  async searchMessages(
    @Request() req,
    @Param('otherUserId') otherUserId: string,
    @Query('q') query: string,
    @Query('limit') limit: number = 20,
  ): Promise<MessageResponseDto[]> {
    return this.messagingService.searchMessages(
      req.user.id,
      otherUserId,
      query,
      limit,
    );
  }

  /**
   * GET /api/messages/conversations/:otherUserId/count
   * Get message count for a conversation
   */
  @Get('conversations/:otherUserId/count')
  async getConversationMessageCount(
    @Request() req,
    @Param('otherUserId') otherUserId: string,
  ): Promise<{ count: number }> {
    const count = await this.messagingService.getConversationMessageCount(
      req.user.id,
      otherUserId,
    );
    return { count };
  }
}
