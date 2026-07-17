import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../common/firebase-auth.guard';
import { AnalyticsService } from './analytics.service';

@Controller('api/analytics')
@UseGuards(FirebaseAuthGuard)
export class AnalyticsController {
  constructor(private readonly analytics: AnalyticsService) {}

  @Get('market')
  market(@Req() request: any) {
    return this.analytics.market(request.user);
  }
}
