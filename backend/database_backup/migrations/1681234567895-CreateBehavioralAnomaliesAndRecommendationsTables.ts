import { MigrationInterface, QueryRunner, Table } from 'typeorm';

export class CreateBehavioralAnomaliesAndRecommendationsTables1681234567895
  implements MigrationInterface
{
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Behavioral anomalies (fraud detection)
    await queryRunner.createTable(
      new Table({
        name: 'behavioral_anomalies',
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
            name: 'anomalyType',
            type: 'varchar',
            length: '100',
            isNullable: false,
            comment:
              'unusual_location, spike_activity, large_transaction, velocity_check, chargeback_pattern, etc.',
          },
          {
            name: 'severity',
            type: 'varchar',
            length: '20',
            isNullable: false,
            comment: 'low, medium, high, critical',
          },
          {
            name: 'detectedAt',
            type: 'timestamptz',
            default: 'NOW()',
            isNullable: false,
          },
          {
            name: 'description',
            type: 'text',
            isNullable: true,
          },
          {
            name: 'details',
            type: 'jsonb',
            isNullable: true,
            comment: 'Context-specific details about the anomaly',
          },
          {
            name: 'isReviewed',
            type: 'boolean',
            default: false,
            isNullable: false,
          },
          {
            name: 'reviewerId',
            type: 'uuid',
            isNullable: true,
            comment: 'Admin who reviewed the anomaly',
          },
          {
            name: 'actionTaken',
            type: 'varchar',
            length: '100',
            isNullable: true,
            comment: 'blocked, flagged, ignored, verified_safe',
          },
          {
            name: 'reviewedAt',
            type: 'timestamptz',
            isNullable: true,
          },
        ],
        indices: [
          {
            name: 'idx_behavioral_anomalies_user_id_severity',
            columnNames: ['userId', 'severity'],
          },
          {
            name: 'idx_behavioral_anomalies_detected_at',
            columnNames: ['detectedAt'],
          },
          {
            name: 'idx_behavioral_anomalies_is_reviewed',
            columnNames: ['isReviewed'],
          },
        ],
        comment: 'Detected suspicious user behavior patterns',
      }),
      true,
    );

    // Recommendations (to users)
    await queryRunner.createTable(
      new Table({
        name: 'recommendations',
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
            comment: 'User receiving the recommendation',
          },
          {
            name: 'recommendedUserId',
            type: 'uuid',
            isNullable: true,
            comment: 'User being recommended (null if product/market recommendation)',
          },
          {
            name: 'recommendedProductId',
            type: 'uuid',
            isNullable: true,
            comment: 'Lot/product being recommended',
          },
          {
            name: 'recommendationType',
            type: 'varchar',
            length: '50',
            isNullable: false,
            comment: 'partner, product, market, price_drop, new_supplier',
          },
          {
            name: 'score',
            type: 'smallint',
            isNullable: false,
            comment: 'Relevance score 0-100',
          },
          {
            name: 'reasons',
            type: 'jsonb',
            isNullable: true,
            comment: '[reputation, price, network, quality, frequency]',
          },
          {
            name: 'createdAt',
            type: 'timestamptz',
            default: 'NOW()',
            isNullable: false,
          },
          {
            name: 'clicked',
            type: 'boolean',
            default: false,
            isNullable: false,
          },
          {
            name: 'clickedAt',
            type: 'timestamptz',
            isNullable: true,
          },
          {
            name: 'engaged',
            type: 'boolean',
            default: false,
            isNullable: false,
            comment: 'True if user took action (message, bid, etc.) within 24h',
          },
          {
            name: 'engagedAt',
            type: 'timestamptz',
            isNullable: true,
          },
        ],
        indices: [
          {
            name: 'idx_recommendations_user_id_created_at',
            columnNames: ['userId', 'createdAt'],
          },
          {
            name: 'idx_recommendations_score',
            columnNames: ['score'],
          },
          {
            name: 'idx_recommendations_clicked',
            columnNames: ['clicked'],
          },
        ],
        comment: 'Personalized recommendations for users',
      }),
      true,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('recommendations');
    await queryRunner.dropTable('behavioral_anomalies');
  }
}
