import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get('health')
  health(): any {
    return {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      service: 'afrigo-backend',
      version: '0.1.0',
    };
  }
}
