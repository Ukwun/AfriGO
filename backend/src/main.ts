import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  const port = process.env.API_PORT || 3000;
  const host = process.env.API_HOST || 'localhost';
  
  await app.listen(port, host);
  
  const logger = new Logger('Bootstrap');
  logger.log(`🚀 AfriGo Backend running on http://${host}:${port}`);
}

bootstrap().catch((err) => {
  console.error('Failed to start application:', err);
  process.exit(1);
});
