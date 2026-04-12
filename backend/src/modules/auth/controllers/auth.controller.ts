import {
  Controller,
  Post,
  Get,
  Put,
  Body,
  UseGuards,
  Req,
  Res,
  HttpCode,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service';
import { JwtAuthGuard } from '../guards/jwt-auth.guard';
import {
  RegisterDto,
  LoginDto,
  RefreshTokenDto,
  VerifyTokenDto,
  AuthResponseDto,
  UserProfileDto,
  RequestPasswordResetDto,
  ResetPasswordDto,
  UpdateProfileDto,
} from '../dto/auth.dto';

/**
 * Auth Controller
 * Handles all authentication endpoints
 *
 * Endpoints (documented in detail below)
 */
@Controller('auth')
export class AuthController {
  private readonly logger = new Logger(AuthController.name);

  constructor(private readonly authService: AuthService) {}

  /**
   * POST /auth/register
   *
   * Register new user account
   *
   * Flow:
   * 1. Validate email doesn't exist
   * 2. Hash password with bcrypt
   * 3. Create user with initial roles
   * 4. Generate JWT tokens
   * 5. Generate verification email token
   * 6. Return auth response with tokens
   *
   * Request Body:
   * {
   *   "email": "john@example.com",
   *   "password": "SecurePassword123",
   *   "firstName": "John",
   *   "lastName": "Osei",
   *   "phone": "+233507123456",
   *   "organizationName": "John's Farm",
   *   "countryCode": "GH"
   * }
   *
   * @response 201 - User created, returns auth tokens
   * @response 400 - Validation failed (weak password, invalid email)
   * @response 409 - Email already registered
   */
  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  async register(
    @Body() registerDto: RegisterDto,
    @Req() req: Request,
  ): Promise<AuthResponseDto> {
    const ipAddress = this.getClientIp(req);
    const userAgent = req.get('user-agent') || 'Unknown';

    this.logger.debug(
      `Register request from IP: ${ipAddress}, email: ${registerDto.email}`,
    );

    return this.authService.register(registerDto, ipAddress, userAgent);
  }

  /**
   * POST /auth/login
   *
   * Authenticate user with email & password
   *
   * Flow:
   * 1. Find user by email
   * 2. Validate password with bcrypt comparison
   * 3. Check account is active
   * 4. Generate JWT tokens
   * 5. Update last login timestamp
   * 6. Return auth response
   *
   * Request Body:
   * {
   *   "email": "john@example.com",
   *   "password": "SecurePassword123"
   * }
   *
   * @response 200 - Login successful, returns tokens
   * @response 401 - Invalid email or password
   * @response 400 - Account suspended or banned
   */
  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(
    @Body() loginDto: LoginDto,
    @Req() req: Request,
  ): Promise<AuthResponseDto> {
    const ipAddress = this.getClientIp(req);
    const userAgent = req.get('user-agent') || 'Unknown';

    this.logger.debug(
      `Login request from IP: ${ipAddress}, email: ${loginDto.email}`,
    );

    return this.authService.login(loginDto, ipAddress, userAgent);
  }

  /**
   * POST /auth/refresh
   *
   * Get new access token using refresh token
   *
   * JWT access tokens expire after 24 hours
   * Refresh tokens expire after 7 days
   * Use this endpoint to get new access token without re-login
   *
   * Request Body:
   * {
   *   "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   * }
   *
   * Response:
   * {
   *   "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
   *   "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   * }
   *
   * @response 200 - New tokens generated
   * @response 401 - Refresh token invalid or expired
   */
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refreshToken(
    @Body() refreshTokenDto: RefreshTokenDto,
  ) {
    this.logger.debug('Refresh token request');
    return this.authService.refreshToken(refreshTokenDto);
  }

  /**
   * POST /auth/verify-email
   *
   * Verify email with token (from verification email)
   *
   * Flow:
   * 1. User receives email with verification token
   * 2. User clicks link, which makes POST to this endpoint
   * 3. Token is validated (not expired, correct type)
   * 4. User's emailVerified is set to true
   * 5. Token is marked as used
   *
   * Request Body:
   * {
   *   "token": "abc123def456ghi789...",
   *   "type": "email_verification"
   * }
   *
   * @response 200 - Email verified
   * @response 400 - Token invalid, expired, or already used
   */
  @Post('verify-email')
  @HttpCode(HttpStatus.OK)
  async verifyEmail(
    @Body() verifyTokenDto: VerifyTokenDto,
  ): Promise<{ message: string }> {
    this.logger.debug('Email verification request');
    await this.authService.verifyToken({
      ...verifyTokenDto,
      type: 'email_verification',
    });
    return { message: 'Email verified successfully' };
  }

  /**
   * POST /auth/verify-phone
   *
   * Verify phone with OTP
   *
   * Similar to email verification but for phone number
   * User receives SMS with 6-digit code
   *
   * Request Body:
   * {
   *   "token": "123456",
   *   "type": "phone_verification"
   * }
   *
   * @response 200 - Phone verified
   */
  @Post('verify-phone')
  @HttpCode(HttpStatus.OK)
  async verifyPhone(
    @Body() verifyTokenDto: VerifyTokenDto,
  ): Promise<{ message: string }> {
    this.logger.debug('Phone verification request');
    await this.authService.verifyToken({
      ...verifyTokenDto,
      type: 'phone_verification',
    });
    return { message: 'Phone verified successfully' };
  }

  /**
   * POST /auth/forgot-password
   *
   * Request password reset token
   *
   * Flow:
   * 1. User provides email
   * 2. Check if email exists (don't reveal if it doesn't)
   * 3. Generate password reset token (24h expiration)
   * 4. Send reset link to email
   * 5. Return success (always, for security)
   *
   * Request Body:
   * {
   *   "email": "john@example.com"
   * }
   *
   * @response 200 - Always returns success (for security)
   */
  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  async requestPasswordReset(
    @Body() requestPasswordResetDto: RequestPasswordResetDto,
  ): Promise<{ message: string }> {
    this.logger.debug(
      `Password reset request for: ${requestPasswordResetDto.email}`,
    );
    await this.authService.requestPasswordReset(requestPasswordResetDto);
    return {
      message:
        'If an account exists with this email, a password reset link has been sent.',
    };
  }

  /**
   * POST /auth/reset-password
   *
   * Reset password with token from email
   *
   * Flow:
   * 1. User receives reset token in email
   * 2. User submits reset token + new password
   * 3. Validate token (not expired)
   * 4. Hash new password
   * 5. Update user password
   * 6. Mark token as used
   *
   * Request Body:
   * {
   *   "token": "abc123def456ghi789...",
   *   "newPassword": "NewSecurePassword123"
   * }
   *
   * @response 200 - Password reset successfully
   * @response 400 - Token invalid or expired
   */
  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  async resetPassword(
    @Body() resetPasswordDto: ResetPasswordDto,
  ): Promise<{ message: string }> {
    this.logger.debug('Password reset confirmation');
    await this.authService.resetPassword(resetPasswordDto);
    return { message: 'Password reset successfully' };
  }

  /**
   * GET /auth/me
   *
   * Get current user's profile (requires JWT auth)
   *
   * Use this to verify token is valid and get current user info
   * Must include Authorization header: Bearer <accessToken>
   *
   * @response 200 - Returns user profile
   * @response 401 - No valid token provided
   */
  @Get('me')
  @UseGuards(JwtAuthGuard)
  async getProfile(@Req() req: Request): Promise<UserProfileDto> {
    const userId = (req.user as any).id;
    this.logger.debug(`Get profile request for user: ${userId}`);
    return this.authService.getProfile(userId);
  }

  /**
   * PUT /auth/profile
   *
   * Update current user's profile (requires JWT auth)
   *
   * Can update:
   * - firstName, lastName
   * - organizationName
   * - location
   * - countryCode
   * - language
   *
   * Cannot update (use dedicated endpoints):
   * - email (use /auth/verify-email)
   * - password (use /auth/reset-password)
   * - roles (admin only)
   * - kycStatus (automatic)
   *
   * Request Body:
   * {
   *   "firstName": "Johnny",
   *   "organizationName": "Updated Farm Name",
   *   "location": "Accra, Ghana"
   * }
   *
   * @response 200 - Profile updated
   * @response 401 - Not authenticated
   */
  @Put('profile')
  @UseGuards(JwtAuthGuard)
  async updateProfile(
    @Req() req: Request,
    @Body() updateProfileDto: UpdateProfileDto,
  ): Promise<UserProfileDto> {
    const userId = (req.user as any).id;
    this.logger.debug(`Update profile request for user: ${userId}`);
    return this.authService.updateProfile(userId, updateProfileDto);
  }

  /**
   * POST /auth/logout
   *
   * Logout user (requires JWT auth)
   *
   * Notes:
   * - JWT tokens can't be revoked server-side without a blacklist
   * - Client should delete token from local storage
   * - This endpoint just marks last activity
   * - Implement token blacklist if true logout needed
   *
   * @response 200 - Logout successful
   * @response 401 - Not authenticated
   */
  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  async logout(@Req() req: Request): Promise<{ message: string }> {
    const userId = (req.user as any).id;
    this.logger.debug(`Logout request for user: ${userId}`);
    await this.authService.logout(userId);
    return { message: 'Logged out successfully' };
  }

  // =========================================================================
  // PRIVATE HELPER METHODS
  // =========================================================================

  /**
   * Get client IP address from request
   * Handles proxies (X-Forwarded-For, X-Real-IP)
   */
  private getClientIp(req: Request): string {
    const ipAddress =
      ((req.headers['x-forwarded-for'] as string)?.split(',')[0] as string) ||
      (typeof req.headers['x-real-ip'] === 'string'
        ? req.headers['x-real-ip']
        : undefined) ||
      req.connection.remoteAddress ||
      'unknown';
    return ipAddress;
  }
}
