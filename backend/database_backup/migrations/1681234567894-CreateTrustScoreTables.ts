import { MigrationInterface, QueryRunner, Table } from 'typeorm';

export class CreateTrustScoreTables1681234567894 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Trust scores (current)
    await queryRunner.createTable(
      new Table({
        name: 'trust_scores',
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
            isUnique: true,
          },
          {
            name: 'score',
            type: 'smallint',
            default: 40,
            isNullable: false,
            comment: '0-100 score',
          },
          {
            name: 'rating',
            type: 'decimal',
            precision: 3,
            scale: 2,
            default: 0,
            isNullable: false,
            comment: '0-5 rating from reviews',
          },
          {
            name: 'completedTrades',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'failedTrades',
            type: 'integer',
            default: 0,
            isNullable: false,
          },
          {
            name: 'totalTransactionValue',
            type: 'decimal',
            precision: 15,
            scale: 2,
            default: 0,
            isNullable: false,
          },
          {
            name: 'components',
            type: 'jsonb',
            isNullable: true,
            comment:
              'Breakdown: {transactionHistory: 40, reputation: 30, verification: 20, platformAge: 10}',
          },
          {
            name: 'calculatedAt',
            type: 'timestamptz',
            default: 'NOW()',
            isNullable: false,
          },
          {
            name: 'updatedAt',
            type: 'timestamptz',
            default: 'NOW()',
            isNullable: false,
          },
        ],
        indices: [
          {
            name: 'idx_trust_scores_user_id',
            columnNames: ['userId'],
          },
          {
            name: 'idx_trust_scores_score',
            columnNames: ['score'],
          },
        ],
        comment: 'Current trust scores for users (updated hourly)',
      }),
      true,
    );

    // Trust score history (for tracking changes over time)
    await queryRunner.createTable(
      new Table({
        name: 'trust_score_history',
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
            name: 'score',
            type: 'smallint',
            isNullable: false,
          },
          {
            name: 'rating',
            type: 'decimal',
            precision: 3,
            scale: 2,
            isNullable: false,
          },
          {
            name: 'reason',
            type: 'varchar',
            length: '255',
            isNullable: true,
            comment: 'Why score changed: new_trade_completed, payment_delayed, dispute_resolved',
          },
          {
            name: 'components',
            type: 'jsonb',
            isNullable: true,
          },
          {
            name: 'calculatedAt',
            type: 'timestamptz',
            default: 'NOW()',
            isNullable: false,
          },
        ],
        indices: [
          {
            name: 'idx_trust_score_history_user_id_timestamp',
            columnNames: ['userId', 'calculatedAt'],
          },
        ],
        comment: 'Historical trust score snapshots (append-only)',
      }),
      true,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('trust_score_history');
    await queryRunner.dropTable('trust_scores');
  }
}
