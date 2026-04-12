import { IsString, IsUUID, IsOptional, IsArray, IsNotEmpty, MaxLength } from 'class-validator';

export class CreateMessageDto {
  @IsUUID()
  recipientId: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(5000)
  content: string;

  @IsOptional()
  @IsUUID()
  orderId?: string;

  @IsOptional()
  @IsString()
  messageType?: string; // 'text', 'image', 'document', etc.

  @IsOptional()
  @IsArray()
  attachments?: string[];

  @IsOptional()
  metadata?: {
    quoteId?: string;
    orderId?: string;
    referenceType?: 'quote_update' | 'order_status' | 'price_change';
    referenceData?: Record<string, any>;
  };
}

export class UpdateMessageDto {
  @IsOptional()
  @IsString()
  content?: string;

  @IsOptional()
  @IsArray()
  attachments?: string[];
}

export class MarkMessageAsReadDto {
  @IsArray()
  @IsString({ each: true })
  messageIds: string[];
}

export class MessageResponseDto {
  id: string;
  conversationId: string;
  senderId: string;
  sender: {
    id: string;
    name: string;
    avatar?: string;
  };
  recipientId: string;
  recipient: {
    id: string;
    name: string;
    avatar?: string;
  };
  orderId?: string;
  content: string;
  messageType: string;
  attachments?: string[];
  metadata?: any;
  isRead: boolean;
  readAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export class ConversationDto {
  conversationId: string;
  otherUserId: string;
  otherUser: {
    id: string;
    name: string;
    avatar?: string;
    isOnline?: boolean;
  };
  lastMessage: MessageResponseDto;
  unreadCount: number;
  lastMessageAt: Date;
}

export class ConversationMessagesDto {
  conversationId: string;
  messages: MessageResponseDto[];
  otherUser: {
    id: string;
    name: string;
    avatar?: string;
    isOnline?: boolean;
  };
  totalCount: number;
  page: number;
  limit: number;
}
