import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './modules/auth/auth.module';
import { LotsModule } from './modules/lots/lots.module';

@Module({
  imports: [
    // Load environment variables from .env.local
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env.local',
    }),

    // TypeORM: Database configuration
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('DATABASE_HOST'),
        port: configService.get<number>('DATABASE_PORT'),
        username: configService.get<string>('DATABASE_USER'),
        password: configService.get<string>('DATABASE_PASSWORD'),
        database: configService.get<string>('DATABASE_NAME'),
        entities: ['src/**/*.entity.ts'],
        subscribers: ['src/**/*.subscriber.ts'],
        migrations: ['migrations/*.ts'],
        migrationsTableName: 'typeorm_migrations',
        cli: {
          migrationsDir: 'migrations',
        },
        logging: configService.get<boolean>('DATABASE_LOG_QUERIES') || false,
        synchronize: false, // Use migrations instead
        ssl:
          configService.get<string>('NODE_ENV') === 'production'
            ? { rejectUnauthorized: false }
            : false,
      }),
    }),

    // Feature modules
    AuthModule,
    LotsModule,
    // TODO: MarketplaceModule,
    // TODO: ContractsModule,
    // TODO: PaymentsModule,
    // TODO: LogisticsModule,
    // TODO: DocumentsModule,
    // TODO: ZoneServicesModule,
    // TODO: QualityModule,
  ],

  controllers: [AppController],

  providers: [AppService],
})
export class AppModule {}
