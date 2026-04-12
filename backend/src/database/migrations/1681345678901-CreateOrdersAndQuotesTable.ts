import { MigrationInterface, QueryRunner, Table, TableIndex, TableForeignKey } from 'typeorm';

export class CreateOrdersAndQuotesTable1681345678901 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create orders table
    await queryRunner.createTable(
      new Table({
        name: 'orders',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'uuid_generate_v4()',
          },
          {
            name: 'lotId',
            type: 'uuid',
          },
          {
            name: 'buyerId',
            type: 'uuid',
          },
          {
            name: 'sellerId',
            type: 'uuid',
          },
          {
            name: 'quantity',
            type: 'decimal',
            precision: 10,
            scale: 2,
          },
          {
            name: 'quantityUnit',
            type: 'varchar',
            length: '50',
          },
          {
            name: 'pricePerUnit',
            type: 'decimal',
            precision: 10,
            scale: 2,
          },
          {
            name: 'totalPrice',
            type: 'decimal',
            precision: 10,
            scale: 2,
          },
          {
            name: 'commissionPercentage',
            type: 'varchar',
            length: '50',
            default: "'pending'",
          },
          {
            name: 'commissionAmount',
            type: 'decimal',
            precision: 10,
            scale: 2,
            default: 0,
          },
          {
            name: 'status',
            type: 'varchar',
            length: '50',
            default: "'pending'",
          },
          {
            name: 'paymentStatus',
            type: 'varchar',
            length: '50',
            default: "'not_paid'",
          },
          {
            name: 'escrowId',
            type: 'varchar',
            length: '255',
            isNullable: true,
          },
          {
            name: 'escrowReleased',
            type: 'boolean',
            default: false,
          },
          {
            name: 'confirmedAt',
            type: 'timestamp',
            isNullable: true,
          },
          {
            name: 'paidAt',
            type: 'timestamp',
            isNullable: true,
          },
          {
            name: 'shippedAt',
            type: 'timestamp',
            isNullable: true,
          },
          {
            name: 'deliveredAt',
            type: 'timestamp',
            isNullable: true,
          },
          {
            name: 'completedAt',
            type: 'timestamp',
            isNullable: true,
          },
          {
            name: 'buyerRating',
            type: 'int',
            isNullable: true,
          },
          {
            name: 'buyerReview',
            type: 'text',
            isNullable: true,
          },
          {
            name: 'sellerRating',
            type: 'int',
            isNullable: true,
          },
          {
            name: 'sellerReview',
            type: 'text',
            isNullable: true,
          },
          {
            name: 'createdAt',
            type: 'timestamp',
            default: 'CURRENT_TIMESTAMP',
          },
          {
            name: 'updatedAt',
            type: 'timestamp',
            default: 'CURRENT_TIMESTAMP',
            onUpdate: 'CURRENT_TIMESTAMP',
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

    // Create indexes on orders table
    await queryRunner.createIndex(
      'orders',
      new TableIndex({
        name: 'IDX_orders_buyerId',
        columnNames: ['buyerId'],
      }),
    );

    await queryRunner.createIndex(
      'orders',
      new TableIndex({
        name: 'IDX_orders_sellerId',
        columnNames: ['sellerId'],
      }),
    );

    await queryRunner.createIndex(
      'orders',
      new TableIndex({
        name: 'IDX_orders_lotId',
        columnNames: ['lotId'],
      }),
    );

    await queryRunner.createIndex(
      'orders',
      new TableIndex({
        name: 'IDX_orders_status',
        columnNames: ['status'],
      }),
    );

    await queryRunner.createIndex(
      'orders',
      new TableIndex({
        name: 'IDX_orders_createdAt',
        columnNames: ['createdAt'],
      }),
    );

    await queryRunner.createIndex(
      'orders',
      new TableIndex({
        name: 'IDX_orders_paymentStatus',
        columnNames: ['paymentStatus'],
      }),
    );

    // Create foreign keys for orders
    await queryRunner.createForeignKey(
      'orders',
      new TableForeignKey({
        columnNames: ['lotId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'lots',
        onDelete: 'CASCADE',
      }),
    );

    await queryRunner.createForeignKey(
      'orders',
      new TableForeignKey({
        columnNames: ['buyerId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'users',
        onDelete: 'CASCADE',
      }),
    );

    await queryRunner.createForeignKey(
      'orders',
      new TableForeignKey({
        columnNames: ['sellerId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'users',
        onDelete: 'CASCADE',
      }),
    );

    // Create quotes table
    await queryRunner.createTable(
      new Table({
        name: 'quotes',
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
          },
          {
            name: 'lotId',
            type: 'uuid',
          },
          {
            name: 'fromUserId',
            type: 'uuid',
          },
          {
            name: 'toUserId',
            type: 'uuid',
          },
          {
            name: 'quoteType',
            type: 'varchar',
            length: '50',
            isNullable: true,
          },
          {
            name: 'quotedPrice',
            type: 'decimal',
            precision: 10,
            scale: 2,
          },
          {
            name: 'quotedQuantity',
            type: 'decimal',
            precision: 10,
            scale: 2,
          },
          {
            name: 'quantityUnit',
            type: 'varchar',
            length: '50',
          },
          {
            name: 'termsAndConditions',
            type: 'text',
            isNullable: true,
          },
          {
            name: 'notes',
            type: 'text',
            isNullable: true,
          },
          {
            name: 'deliveryLocation',
            type: 'varchar',
            length: '255',
            isNullable: true,
          },
          {
            name: 'proposedDeliveryDate',
            type: 'timestamp',
            isNullable: true,
          },
          {
            name: 'status',
            type: 'varchar',
            length: '50',
            default: "'pending'",
          },
          {
            name: 'expiresAt',
            type: 'timestamp',
          },
          {
            name: 'isExpired',
            type: 'boolean',
            default: false,
          },
          {
            name: 'acceptedAt',
            type: 'timestamp',
            isNullable: true,
          },
          {
            name: 'rejectedAt',
            type: 'timestamp',
            isNullable: true,
          },
          {
            name: 'rejectionReason',
            type: 'text',
            isNullable: true,
          },
          {
            name: 'counterQuoteId',
            type: 'uuid',
            isNullable: true,
          },
          {
            name: 'createdAt',
            type: 'timestamp',
            default: 'CURRENT_TIMESTAMP',
          },
          {
            name: 'updatedAt',
            type: 'timestamp',
            default: 'CURRENT_TIMESTAMP',
            onUpdate: 'CURRENT_TIMESTAMP',
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

    // Create indexes on quotes table
    await queryRunner.createIndex(
      'quotes',
      new TableIndex({
        name: 'IDX_quotes_orderId',
        columnNames: ['orderId'],
      }),
    );

    await queryRunner.createIndex(
      'quotes',
      new TableIndex({
        name: 'IDX_quotes_fromUserId',
        columnNames: ['fromUserId'],
      }),
    );

    await queryRunner.createIndex(
      'quotes',
      new TableIndex({
        name: 'IDX_quotes_toUserId',
        columnNames: ['toUserId'],
      }),
    );

    await queryRunner.createIndex(
      'quotes',
      new TableIndex({
        name: 'IDX_quotes_status',
        columnNames: ['status'],
      }),
    );

    await queryRunner.createIndex(
      'quotes',
      new TableIndex({
        name: 'IDX_quotes_expiresAt',
        columnNames: ['expiresAt'],
      }),
    );

    // Create foreign keys for quotes
    await queryRunner.createForeignKey(
      'quotes',
      new TableForeignKey({
        columnNames: ['orderId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'orders',
        onDelete: 'CASCADE',
      }),
    );

    await queryRunner.createForeignKey(
      'quotes',
      new TableForeignKey({
        columnNames: ['lotId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'lots',
        onDelete: 'CASCADE',
      }),
    );

    await queryRunner.createForeignKey(
      'quotes',
      new TableForeignKey({
        columnNames: ['fromUserId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'users',
        onDelete: 'CASCADE',
      }),
    );

    await queryRunner.createForeignKey(
      'quotes',
      new TableForeignKey({
        columnNames: ['toUserId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'users',
        onDelete: 'CASCADE',
      }),
    );

    await queryRunner.createForeignKey(
      'quotes',
      new TableForeignKey({
        columnNames: ['counterQuoteId'],
        referencedColumnNames: ['id'],
        referencedTableName: 'quotes',
        onDelete: 'SET NULL',
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Drop quotes table first (has FK to orders)
    const quotesForeignKeys = await queryRunner.query(
      `SELECT constraint_name FROM information_schema.table_constraints 
       WHERE table_name = 'quotes' AND constraint_type = 'FOREIGN KEY'`,
    );

    for (const fk of quotesForeignKeys) {
      await queryRunner.query(`ALTER TABLE quotes DROP CONSTRAINT "${fk.constraint_name}"`);
    }

    await queryRunner.dropTable('quotes');

    // Drop orders table
    const ordersForeignKeys = await queryRunner.query(
      `SELECT constraint_name FROM information_schema.table_constraints 
       WHERE table_name = 'orders' AND constraint_type = 'FOREIGN KEY'`,
    );

    for (const fk of ordersForeignKeys) {
      await queryRunner.query(`ALTER TABLE orders DROP CONSTRAINT "${fk.constraint_name}"`);
    }

    await queryRunner.dropTable('orders');
  }
}
