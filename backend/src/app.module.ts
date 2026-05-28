import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { FirebaseModule } from './firebase/firebase.module';
// import { IntelligenceModule } from './modules/intelligence/intelligence.module';
// import { RealtimeModule } from './modules/realtime/realtime.module';
// import { AnalyticsModule } from './modules/analytics/analytics.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', '.env.local'],
    }),
    // Core modules
    FirebaseModule,
    AuthModule,
    // Feature modules - disabled during testing
    // IntelligenceModule,
    // RealtimeModule,
    // AnalyticsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
