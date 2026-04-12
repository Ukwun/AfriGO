import { MigrationInterface, QueryRunner, Table, TableIndex, TableForeignKey } from 'typeorm';

export class CreatePaymentsTable1681234567892 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'payments',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'uuid_generate_v4()',
          },
          {
            name: 'orderId',
            type: 'uuid',
            isNullable: false,
          },
          {
            name: 'userId',
            type: 'uuid',
            isNullable: false,
          },
          {
            name: 'amount',
            type: 'decimal',
            precision: 10,
            scale: 2,
            isNullable: false,
          },
          {
            name: 'currency',
            type: 'varchar',
            length: 3,
            default: "'USD'",
            isNullable: false,
          },
          {
            name: 'paymentMethod',
            type: 'varchar',
            length: 50,
            isNullable: false,
          },
          {
            name: 'status',
            type: 'varchar',
            length: 50,
            default: "'pending'",
            isNullable: false,
          },
          {
            name: 'stripePaymentIntentId',
            type: 'varchar',
            length: 255,
            isNullable: true,
          },
          {
            name: 'stripeChargeId',
            type: 'varchar',
            length: 255,
            isNullable: true,
          },
          {
            name: 'escrowStatus',
            type: 'varchar',
            length: 50,
            default: "'pending'",
            isNullable: false,
          },
          {
            name: 'cardInfo',
            type: 'jsonb',
            isNullable: true,
          },
          {
            name: 'description',
            type: 'text',
            isNullable: true,
          },
          {
            name: 'receiptUrl',
            type: 'varchar',
            length: 255,
            isNullable: true,
          },
          {
            name: 'platformFee',
            type: 'decimal',
            precision: 10,
            scale: 2,
            default: 0,
            isNullable: false,
          },
          {
            name: 'sellerPayout',
            type: 'decimal',
            precision: 10,
            scale: 2,
            default: 0,
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
            name: 'paidAt',
            type: 'timestamp',
            isNullable: true,
          },
          {
            name: 'refundedAt',
            type: 'timestamp',
            isNullable: true,
          },
          {
            name: 'failureReason',
            type: 'text',
            isNullable: true,
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
      'payments',
      new TableIndex({
        name: 'idx_payments_order_id',
        columnNames: ['orderId'],
      }),
    );

    await queryRunner.createIndex(
      'payments',
      new TableIndex({
        name: 'idx_payments_user_id',
        columnNames: ['userId'],
      }),
    );

    await queryRunner.createIndex(
      'payments',
      new TableIndex({
        name: 'idx_payments_status',
        columnNames: ['status'],
      }),
    );

    await queryRunner.createIndex(
      'payments',
      new TableIndex({
        name: 'idx_payments_created_at',
        columnNames: ['createdAt'],
      }),
    );

    await queryRunner.createIndex(
      'payments',
      new TableIndex({
        name: 'idx_payments_stripe_intent',
        columnNames: ['stripePaymentIntentId'],
      }),
    );

    // Foreign keys
    await queryRunner.createForeignKey(
      'payments',
      new TableForeignKey({
        columnNames: ['orderId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'orders',
        onDelete: 'CASCADE',
        onUpdate: 'CASCADE',
      }),
    );

    await queryRunner.createForeignKey(
      'payments',
      new TableForeignKey({
        columnNames: ['userId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'users',
        onDelete: 'CASCADE',
        onUpdate: 'CASCADE',
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('payments');
  }
}
