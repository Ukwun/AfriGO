import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";

import { AppController } from "./app.controller";
import { AppService } from "./app.service";
import { AuthModule } from "./auth/auth.module";
import { FirebaseModule } from "./firebase/firebase.module";
import { ResourcesModule } from "./resources/resources.module";
import { PaymentsModule } from "./payments/payments.module";
import { AnalyticsModule } from './analytics/analytics.module';
// import { IntelligenceModule } from './modules/intelligence/intelligence.module';
// import { RealtimeModule } from './modules/realtime/realtime.module';
// import { AnalyticsModule } from './modules/analytics/analytics.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [".env", ".env.local"],
    }),
    // Core modules
    FirebaseModule,
    AuthModule,
    ResourcesModule,
    PaymentsModule,
    AnalyticsModule,
    // Feature modules - disabled during testing
    // IntelligenceModule,
    // RealtimeModule,
    // AnalyticsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
