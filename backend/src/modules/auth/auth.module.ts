import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';

import { AuthController } from './controllers/auth.controller';
import { AuthService } from './services/auth.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { User, UserRole, VerificationToken } from './entities';

/**
 * Auth Module
 *
 * Handles:
 * - User registration and login
 * - JWT token generation and validation
 * - Email/phone verification
 * - Password reset
 * - User profile management
 *
 * Exports:
 * - AuthService (for other modules to use)
 * - JwtAuthGuard (for protecting routes)
 */
@Module({
  imports: [
    // TypeORM: Register entities this module uses
    TypeOrmModule.forFeature([User, UserRole, VerificationToken]),

    // Passport: Authentication library
    PassportModule.register({ defaultStrategy: 'jwt' }),

    // JWT: Configure JWT module with dynamic config
    JwtModule.registerAsync({
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => {
        const expiresIn = configService.get<string>('JWT_EXPIRATION') || '24h';
        return {
          secret: configService.get<string>('JWT_SECRET'),
          signOptions: {
            expiresIn,
          },
        };
      },
    }),
  ],

  // Controllers: Handle HTTP requests
  controllers: [AuthController],

  // Providers: Services and strategies
  providers: [AuthService, JwtStrategy],

  // Exports: Make these available to other modules
  exports: [AuthService, JwtModule, PassportModule],
})
export class AuthModule {}
