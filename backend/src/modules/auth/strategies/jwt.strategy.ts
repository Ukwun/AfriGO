import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities';

/**
 * JWT Strategy for Passport
 * Validates JWT tokens and extracts user information
 *
 * This is used by the @UseGuards(JwtAuthGuard) decorator on controllers
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    configService: ConfigService,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {
    super({
      // Extract JWT from Authorization: Bearer <token> header
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      // Use JWT_SECRET from environment
      secretOrKey: configService.get<string>('JWT_SECRET'),
      // Ignore expiration here (we handle in controller)
      ignoreExpiration: false,
    });
  }

  /**
   * Validate JWT payload
   * Called automatically by Passport when JWT is provided
   *
   * @param payload - Decoded JWT payload { sub, email, roles }
   * @returns User object if valid, throws if invalid
   */
  async validate(payload: any) {
    // Load full user object from database
    const user = await this.userRepository.findOne({
      where: { id: payload.sub },
      relations: ['roles'],
    });

    // If user doesn't exist or is deleted, auth fails
    if (!user || user.deletedAt) {
      return null;
    }

    // Check if account is active (not suspended/banned)
    if (user.accountStatus !== 'active') {
      return null;
    }

    // Return user object (attached to req.user in controller)
    return user;
  }
}
