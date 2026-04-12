import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  DeleteDateColumn,
  ManyToMany,
  JoinTable,
} from 'typeorm';
import { User } from '../auth/entities/user.entity';
import { Order } from '../trading/entities/order.entity';

@Entity('messages')
@Index(['conversationId'])
@Index(['senderId'])
@Index(['recipientId'])
@Index(['orderId'])
@Index(['createdAt'])
@Index(['senderId', 'recipientId', 'createdAt'])
export class Message {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Conversation ID is senderId + recipientId sorted, for grouping messages
  @Column({ type: 'varchar', length: 500 })
  conversationId: string; // e.g., "user1_user2" (sorted alphabetically)

  @Column('uuid')
  senderId: string;

  @ManyToOne(() => User, (user) => user.sentMessages, {
    eager: true,
    cascade: false,
  })
  @JoinColumn({ name: 'senderId' })
  sender: User;

  @Column('uuid')
  recipientId: string;

  @ManyToOne(() => User, (user) => user.receivedMessages, {
    eager: true,
    cascade: false,
  })
  @JoinColumn({ name: 'recipientId' })
  recipient: User;

  @Column('uuid', { nullable: true })
  orderId: string;

  @ManyToOne(() => Order, { eager: false, cascade: false, nullable: true })
  @JoinColumn({ name: 'orderId' })
  order?: Order;

  @Column('text')
  content: string;

  // Message type: text, image, document, quote_update, order_status
  @Column({ type: 'varchar', length: 50, default: 'text' })
  messageType: string; // 'text' | 'image' | 'document' | 'quote_update' | 'order_status'

  // Attachments (image URLs, document URLs)
  @Column({ type: 'simple-array', nullable: true })
  attachments?: string[];

  // For quote/order-related messages, store reference data
  @Column({ type: 'jsonb', nullable: true })
  metadata?: {
    quoteId?: string;
    orderId?: string;
    referenceType?: 'quote_update' | 'order_status' | 'price_change';
    referenceData?: Record<string, any>;
  };

  @Column({ default: false })
  isRead: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Recipient read timestamp
  @Column({ type: 'timestamp', nullable: true })
  readAt: Date;

  @DeleteDateColumn({ nullable: true })
  deletedAt: Date;

  // Typing indicators cache (non-persistent, cleared regularly)
  @Column({ default: false })
  senderIsTyping: boolean;
}
