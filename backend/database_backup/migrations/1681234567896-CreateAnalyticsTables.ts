import { MigrationInterface, QueryRunner, Table } from 'typeorm';

export class CreateAnalyticsTables1681234567896 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Daily analytics snapshots
    await queryRunner.createTable(
      new Table({
        name: 'daily_analytics',
        columns: [
          {
            name: 'id',
            type: 'uuid',
            isPrimary: true,
            generationStrategy: 'uuid',
            default: 'uuid_generate_v4()',
          },
          {
            name: 'date',
            type: 'date',
            isNullable: false,
            comment: 'Date of analytics (YYYY-MM-DD)',
          },
          {
            name: 'totalUsers',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'newUsers',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'verifiedUsers',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'activeUsers',
            type: 'integer',
            default: 0,
            isNullable: false,
            comment: 'Users with at least one activity',
          },
          {
            name: 'dailyActiveUsers',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'lotsCreated',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'lotsPublished',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'bidsSubmitted',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'contractsSigned',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'transactionsCount',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'transactionVolumeUSD',
            type: 'decimal',
            precision: 15,
            scale: 2,
            default: 0,
            isNullable: false,
          },
          {
            name: 'escrowHeldUSD',
            type: 'decimal',
            precision: 15,
            scale: 2,
            default: 0,
            isNullable: false,
          },
          {
            name: 'paymentsProcessed',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'paymentFailures',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'disputes',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'disputesResolved',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'fraudFlags',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'messagesExchanged',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'avgOrderValue',
            type: 'decimal',
            precision: 10,
            scale: 2,
            default: 0,
            isNullable: false,
          },
          {
            name: 'successRate',
            type: 'decimal',
            precision: 5,
            scale: 2,
            default: 0,
            isNullable: false,
            comment: 'Percentage (0-100)',
          },
          {
            name: 'createdAt',
            type: 'timestamptz',
            default: 'NOW()',
            isNullable: false,
          },
        ],
        indices: [
          {
            name: 'idx_daily_analytics_date',
            columnNames: ['date'],
          },
        ],
        comment: 'Daily snapshot of platform metrics',
      }),
      true,
    );

    // User daily activity summary
    await queryRunner.createTable(
      new Table({
        name: 'user_daily_activity',
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
            name: 'date',
            type: 'date',
            isNullable: false,
          },
          {
            name: 'activityCount',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'lotsCreated',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'bidsSubmitted',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'messagesReceived',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'sessionCount',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'totalSessionDuration',
            type: 'integer',
            default: 0,
            isNullable: false,
            comment: 'In seconds',
          },
          {
            name: 'createdAt',
            type: 'timestamptz',
            default: 'NOW()',
            isNullable: false,
          },
        ],
        indices: [
          {
            name: 'idx_user_daily_activity_user_date',
            columnNames: ['userId', 'date'],
          },
        ],
        comment: 'Daily activity summary per user',
      }),
      true,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('user_daily_activity');
    await queryRunner.dropTable('daily_analytics');
  }
}
