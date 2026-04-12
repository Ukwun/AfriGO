import {
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/**
 * JWT Auth Guard
 * Used with @UseGuards(JwtAuthGuard) to protect routes
 *
 * Example:
 * @Post('/profile')
 * @UseGuards(JwtAuthGuard)
 * updateProfile(@Req() req) {
 *   // req.user is automatically populated by Passport
 *   const userId = req.user.id;
 * }
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    // Let Passport validate the JWT
    return super.canActivate(context);
  }

  handleRequest(err: any, user: any, info: any) {
    // If there's an error or no user, throw UnauthorizedException
    if (err || !user) {
      throw err || new UnauthorizedException('Unauthorized access');
    }
    return user;
  }
}

/**
 * Optional JWT Guard
 * Used for routes that work with or without authentication
 *
 * Example:
 * @Get('/lots')
 * @UseGuards(OptionalJwtAuthGuard)
 * getLots(@Req() req) {
 *   const userId = req.user?.id; // user might be undefined
 * }
 */
@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard('jwt') {
  canActivate(context: ExecutionContext) {
    // Try to activate, but don't fail if no token
    return super.canActivate(context);
  }

  handleRequest(err: any, user: any, info: any) {
    // Don't throw error, just return user (might be undefined)
    return user;
  }
}
