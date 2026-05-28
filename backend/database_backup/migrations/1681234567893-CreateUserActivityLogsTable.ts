import { MigrationInterface, QueryRunner, Table, TableIndex } from 'typeorm';

export class CreateUserActivityLogsTable1681234567893 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(
      new Table({
        name: 'user_activity_logs',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'uuid_generate_v4()',
          },
          {
            name: 'userId',
            type: 'uuid',
            isNullable: false,
          },
          {
            name: 'activityType',
            type: 'varchar',
            length: '50',
            isNullable: false,
            comment: 'login, logout, create_lot, submit_bid, place_order, etc.',
          },
          {
            name: 'timestamp',
            type: 'timestamptz',
            default: 'NOW()',
            isNullable: false,
          },
          {
            name: 'ipAddress',
            type: 'varchar',
            length: '45',
            isNullable: true,
          },
          {
            name: 'userAgent',
            type: 'text',
            isNullable: true,
          },
          {
            name: 'deviceInfo',
            type: 'jsonb',
            isNullable: true,
            comment: 'Contains OS, browser, device type, app version',
          },
          {
            name: 'location',
            type: 'jsonb',
            isNullable: true,
            comment: 'Contains latitude, longitude, country, city',
          },
          {
            name: 'actionData',
            type: 'jsonb',
            isNullable: true,
            comment: 'Context-specific data: lot_id, amount, bid_id, order_id, etc.',
          },
          {
            name: 'metadata',
            type: 'jsonb',
            isNullable: true,
            comment: 'Any additional context',
          },
        ],
        indices: [
          {
            name: 'idx_user_activity_logs_user_id_timestamp',
            columnNames: ['userId', 'timestamp'],
          },
          {
            name: 'idx_user_activity_logs_activity_type_timestamp',
            columnNames: ['activityType', 'timestamp'],
          },
          {
            name: 'idx_user_activity_logs_timestamp',
            columnNames: ['timestamp'],
          },
        ],
        comment: 'Immutable log of all user activities (append-only)',
      }),
      true,
    );

    // Partition by timestamp for better performance
    await queryRunner.query(
      `CREATE INDEX idx_user_activity_logs_user_activity_type 
       ON user_activity_logs(userId, activityType)`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('user_activity_logs');
  }
}
