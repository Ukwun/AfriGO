import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // CRITICAL: Enable CORS for mobile device access
  app.enableCors({
    origin: '*',
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });
  
  const port = process.env.API_PORT || 3000;
  // Listen on 0.0.0.0 so Android device can connect from network
  const host = process.env.API_HOST || '0.0.0.0';
  
  await app.listen(port, host);
  
  const logger = new Logger('Bootstrap');
  logger.log(`🚀 AfriGo Backend running on http://${host}:${port}`);
  logger.log(`📱 Accessible from network at: http://[YOUR_IP]:${port}`);
}

bootstrap().catch((err) => {
  console.error('Failed to start application:', err);
  process.exit(1);
});
