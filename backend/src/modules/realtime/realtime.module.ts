import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { EventsGateway } from './gateways/events.gateway';
import { NotificationService } from './services/notification.service';

@Module({
  imports: [JwtModule.register({})],
  providers: [EventsGateway, NotificationService],
  exports: [EventsGateway, NotificationService],
})
export class RealtimeModule {}
