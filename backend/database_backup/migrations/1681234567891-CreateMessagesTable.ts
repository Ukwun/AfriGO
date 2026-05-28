import { MigrationInterface, QueryRunner, Table, TableIndex, TableForeignKey } from 'typeorm';

export class CreateMessagesTable1681234567891 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'messages',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'uuid_generate_v4()',
          },
          {
            name: 'conversationId',
            type: 'varchar',
            length: 500,
            isNullable: false,
          },
          {
            name: 'senderId',
            type: 'uuid',
            isNullable: false,
          },
          {
            name: 'recipientId',
            type: 'uuid',
            isNullable: false,
          },
          {
            name: 'orderId',
            type: 'uuid',
            isNullable: true,
          },
          {
            name: 'content',
            type: 'text',
            isNullable: false,
          },
          {
            name: 'messageType',
            type: 'varchar',
            length: 50,
            default: "'text'",
            isNullable: false,
          },
          {
            name: 'attachments',
            type: 'simple-array',
            isNullable: true,
          },
          {
            name: 'metadata',
            type: 'jsonb',
            isNullable: true,
          },
          {
            name: 'isRead',
            type: 'boolean',
            default: false,
            isNullable: false,
          },
          {
            name: 'readAt',
            type: 'timestamp',
            isNullable: true,
          },
          {
            name: 'senderIsTyping',
            type: 'boolean',
            default: false,
            isNullable: false,
          },
          {
            name: 'createdAt',
            type: 'timestamp',
            default: 'now()',
            isNullable: false,
          },
          {
            name: 'updatedAt',
            type: 'timestamp',
            default: 'now()',
            isNullable: false,
          },
          {
            name: 'deletedAt',
            type: 'timestamp',
            isNullable: true,
          },
        ],
      }),
      true,
    );

    // Create indexes for performance
    await queryRunner.createIndex(
      'messages',
      new TableIndex({
        name: 'idx_messages_conversation_id',
        columnNames: ['conversationId'],
      }),
    );

    await queryRunner.createIndex(
      'messages',
      new TableIndex({
        name: 'idx_messages_sender_id',
        columnNames: ['senderId'],
      }),
    );

    await queryRunner.createIndex(
      'messages',
      new TableIndex({
        name: 'idx_messages_recipient_id',
        columnNames: ['recipientId'],
      }),
    );

    await queryRunner.createIndex(
      'messages',
      new TableIndex({
        name: 'idx_messages_order_id',
        columnNames: ['orderId'],
      }),
    );

    await queryRunner.createIndex(
      'messages',
      new TableIndex({
        name: 'idx_messages_created_at',
        columnNames: ['createdAt'],
      }),
    );

    // Composite index for efficient conversation queries
    await queryRunner.createIndex(
      'messages',
      new TableIndex({
        name: 'idx_messages_conversation_created',
        columnNames: ['conversationId', 'createdAt'],
      }),
    );

    // Composite index for unread messages
    await queryRunner.createIndex(
      'messages',
      new TableIndex({
        name: 'idx_messages_recipient_unread',
        columnNames: ['recipientId', 'isRead'],
      }),
    );

    // Foreign keys
    await queryRunner.createForeignKey(
      'messages',
      new TableForeignKey({
        columnNames: ['senderId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'users',
        onDelete: 'CASCADE',
        onUpdate: 'CASCADE',
      }),
    );

    await queryRunner.createForeignKey(
      'messages',
      new TableForeignKey({
        columnNames: ['recipientId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'users',
        onDelete: 'CASCADE',
        onUpdate: 'CASCADE',
      }),
    );

    await queryRunner.createForeignKey(
      'messages',
      new TableForeignKey({
        columnNames: ['orderId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'orders',
        onDelete: 'SET NULL',
        onUpdate: 'CASCADE',
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('messages');
  }
}
