import { MigrationInterface, QueryRunner, Table, TableIndex } from 'typeorm';

export class CreateLotsTable1681234567890 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'lots',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'uuid_generate_v4()',
          },
          {
            name: 'sellerId',
            type: 'uuid',
            isNullable: false,
          },
          {
            name: 'productName',
            type: 'varchar',
            length: '255',
            isNullable: false,
          },
          {
            name: 'quantity',
            type: 'decimal',
            precision: 10,
            scale: 2,
            isNullable: false,
          },
          {
            name: 'quantityUnit',
            type: 'varchar',
            length: '50',
            isNullable: false,
          },
          {
            name: 'pricePerUnit',
            type: 'decimal',
            precision: 10,
            scale: 2,
            isNullable: false,
          },
          {
            name: 'description',
            type: 'text',
            isNullable: false,
          },
          {
            name: 'images',
            type: 'text',
            isArray: true,
            default: 'ARRAY[]::text[]',
            isNullable: false,
          },
          {
            name: 'pickupLocation',
            type: 'varchar',
            length: '255',
            isNullable: false,
          },
          {
            name: 'latitude',
            type: 'decimal',
            precision: 9,
            scale: 6,
            isNullable: false,
          },
          {
            name: 'longitude',
            type: 'decimal',
            precision: 9,
            scale: 6,
            isNullable: false,
          },
          {
            name: 'qrCode',
            type: 'varchar',
            length: '255',
            isNullable: true,
          },
          {
            name: 'status',
            type: 'varchar',
            length: '50',
            default: "'draft'",
            isNullable: false,
          },
          {
            name: 'verifyStatus',
            type: 'varchar',
            length: '50',
            default: "'pending'",
            isNullable: false,
          },
          {
            name: 'certifications',
            type: 'text',
            isArray: true,
            default: 'ARRAY[]::text[]',
            isNullable: false,
          },
          {
            name: 'category',
            type: 'varchar',
            length: '50',
            isNullable: true,
          },
          {
            name: 'viewCount',
            type: 'int',
            default: 0,
            isNullable: false,
          },
          {
            name: 'averageRating',
            type: 'decimal',
            precision: 3,
            scale: 2,
            default: 0,
            isNullable: false,
          },
          {
            name: 'ratingCount',
            type: 'int',
            default: 0,
            isNullable: false,
          },
          {
            name: 'createdAt',
            type: 'timestamp',
            default: 'CURRENT_TIMESTAMP',
            isNullable: false,
          },
          {
            name: 'updatedAt',
            type: 'timestamp',
            default: 'CURRENT_TIMESTAMP',
            onUpdate: 'CURRENT_TIMESTAMP',
            isNullable: false,
          },
          {
            name: 'deletedAt',
            type: 'timestamp',
            isNullable: true,
          },
        ],
        foreignKeys: [
          {
            columnNames: ['sellerId'],
            referencedTableName: 'users',
            referencedColumnNames: ['id'],
            onDelete: 'CASCADE',
          },
        ],
      }),
      true,
    );

    // Create indexes for better query performance
    await queryRunner.createIndex(
      'lots',
      new TableIndex({
        name: 'IDX_LOTS_SELLER_ID',
        columnNames: ['sellerId'],
      }),
    );

    await queryRunner.createIndex(
      'lots',
      new TableIndex({
        name: 'IDX_LOTS_STATUS',
        columnNames: ['status'],
      }),
    );

    await queryRunner.createIndex(
      'lots',
      new TableIndex({
        name: 'IDX_LOTS_VERIFY_STATUS',
        columnNames: ['verifyStatus'],
      }),
    );

    await queryRunner.createIndex(
      'lots',
      new TableIndex({
        name: 'IDX_LOTS_CREATED_AT',
        columnNames: ['createdAt'],
      }),
    );

    await queryRunner.createIndex(
      'lots',
      new TableIndex({
        name: 'IDX_LOTS_PRODUCT_NAME',
        columnNames: ['productName'],
      }),
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('lots');
  }
}
