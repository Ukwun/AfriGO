import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { rawBody: true });
  const isProduction = process.env.NODE_ENV === 'production';
  const allowedOrigins = (process.env.CORS_ORIGINS || '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);

  if (isProduction && allowedOrigins.length === 0) {
    throw new Error('CORS_ORIGINS must be configured in production');
  }
  
  // CRITICAL: Enable CORS for mobile device access
  app.enableCors({
    origin: isProduction ? allowedOrigins : true,
    credentials: isProduction,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Idempotency-Key'],
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
