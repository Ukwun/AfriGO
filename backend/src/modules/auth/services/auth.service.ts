import {
  Injectable,
  BadRequestException,
  UnauthorizedException,
  ConflictException,
  NotFoundException,
  Logger,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { ConfigService } from '@nestjs/config';

import { User, UserRole, VerificationToken } from '../entities';
import {
  RegisterDto,
  LoginDto,
  RefreshTokenDto,
  VerifyTokenDto,
  AuthResponseDto,
  UserProfileDto,
  RequestPasswordResetDto,
  ResetPasswordDto,
} from '../dto/auth.dto';

/**
 * Auth Service
 * Core authentication business logic
 *
 * Responsibilities:
 * - User registration with email unique constraint
 * - Password hashing with bcrypt
 * - JWT token generation and validation
 * - Verification token management
 * - User login and profile management
 * - Immutable audit logging via TypeORM hooks
 */
@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly BCRYPT_ROUNDS = 10;
  private readonly TOKEN_LENGTH = 32;
  private readonly OTP_LENGTH = 6;

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(UserRole)
    private readonly userRoleRepository: Repository<UserRole>,
    @InjectRepository(VerificationToken)
    private readonly verificationTokenRepository: Repository<VerificationToken>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * REGISTER: Create new user account
   *
   * Flow:
   * 1. Check if email doesn't already exist
   * 2. Hash password with bcrypt (10 rounds)
   * 3. Create user (email verified=false)
   * 4. Generate verification token
   * 5. Return JWT tokens for immediate login
   * 6. Send verification email (async, don't block)
   *
   * @param registerDto - Registration details (email, password, name)
   * @param ipAddress - User's IP for security tracking
   * @param userAgent - User's device for security tracking
   * @returns AuthResponseDto with access token and user info
   */
  async register(
    registerDto: RegisterDto,
    ipAddress: string,
    userAgent: string,
  ): Promise<AuthResponseDto> {
    const { email, password, firstName, lastName, organizationName, countryCode, phone } =
      registerDto;

    this.logger.log(`Attempting to register user: ${email}`);

    // ===== VALIDATION =====
    // Check if user already exists
    const existingUser = await this.userRepository.findOne({
      where: { email },
    });
    if (existingUser) {
      this.logger.warn(`Registration failed: Email already exists: ${email}`);
      throw new ConflictException(
        'Email already registered. Please login or use a different email.',
      );
    }

    // ===== CREATE USER =====
    // Hash password using bcrypt (10 rounds = ~100ms computation)
    const passwordHash = await bcrypt.hash(password, this.BCRYPT_ROUNDS);

    // Create new user in database
    const user = this.userRepository.create({
      email,
      firstName,
      lastName,
      organizationName,
      countryCode,
      phone,
      passwordHash,
      kycStatus: 'pending',
      accountStatus: 'active',
      emailVerified: false,
      phoneVerified: false,
      trustScore: 0,
      completedTrades: 0,
      // Roles will be assigned after KYC
      roles: [],
    });

    const savedUser = await this.userRepository.save(user);
    this.logger.log(`User created successfully: ${savedUser.id}`);

    // ===== GENERATE VERIFICATION TOKEN =====
    // Create email verification token
    const verificationToken = this.generateVerificationToken();
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 15); // 15-minute expiration

    await this.verificationTokenRepository.save({
      userId: savedUser.id,
      token: verificationToken,
      type: 'email_verification',
      contactValue: email,
      expiresAt,
      createdFromIp: ipAddress,
      createdFromUserAgent: userAgent,
    });

    // ===== GENERATE JWT TOKENS =====
    // Create access token (24h expiration)
    const accessToken = this.generateAccessToken(savedUser);
    // Create refresh token (7d expiration)
    const refreshToken = this.generateRefreshToken(savedUser);

    this.logger.log(
      `Registration successful for user: ${savedUser.id} (${email})`,
    );

    // TODO: Send verification email async
    // this.emailService.sendVerificationEmail(email, verificationToken);

    return this.buildAuthResponse(savedUser, accessToken, refreshToken);
  }

  /**
   * LOGIN: Authenticate user with email & password
   *
   * Flow:
   * 1. Find user by email
   * 2. Compare provided password with stored hash
   * 3. Check account is active (not suspended/banned)
   * 4. Generate JWT tokens
   * 5. Update last login timestamp and IP
   * 6. Return auth response
   *
   * @param loginDto - Email and password
   * @param ipAddress - User's IP for security tracking
   * @param userAgent - User's device for security tracking
   * @returns AuthResponseDto with tokens and user info
   */
  async login(
    loginDto: LoginDto,
    ipAddress: string,
    userAgent: string,
  ): Promise<AuthResponseDto> {
    const { email, password } = loginDto;

    this.logger.log(`Attempting login for: ${email}`);

    // ===== FIND USER =====
    // Include relations (roles) for complete user object
    const user = await this.userRepository.findOne({
      where: { email },
      relations: ['roles'],
    });

    if (!user) {
      this.logger.warn(`Login failed: User not found: ${email}`);
      throw new UnauthorizedException(
        'Invalid email or password. Please check and try again.',
      );
    }

    // ===== CHECK ACCOUNT STATUS =====
    if (user.accountStatus === 'suspended') {
      this.logger.warn(`Login denied: Account suspended: ${user.id}`);
      throw new UnauthorizedException(
        'Your account has been suspended. Please contact support.',
      );
    }

    if (user.accountStatus === 'banned') {
      this.logger.warn(`Login denied: Account banned: ${user.id}`);
      throw new UnauthorizedException(
        'Your account has been banned. Please contact support.',
      );
    }

    // ===== VERIFY PASSWORD =====
    // Compare provided password with bcrypt hash
    // bcrypt.compare is slow (intentionally) to prevent brute force
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);

    if (!isPasswordValid) {
      this.logger.warn(`Login failed: Invalid password: ${email}`);
      throw new UnauthorizedException(
        'Invalid email or password. Please check and try again.',
      );
    }

    // ===== GENERATE TOKENS =====
    const accessToken = this.generateAccessToken(user);
    const refreshToken = this.generateRefreshToken(user);

    // ===== UPDATE LAST LOGIN =====
    // Track when user last logged in (for activity analysis)
    await this.userRepository.update(user.id, {
      lastLoginAt: new Date(),
      lastLoginIp: ipAddress,
      lastLoginUserAgent: userAgent,
    });

    this.logger.log(`Login successful for user: ${user.id} (${email})`);

    return this.buildAuthResponse(user, accessToken, refreshToken);
  }

  /**
   * REFRESH TOKEN: Generate new access token using refresh token
   *
   * Flow:
   * 1. Validate refresh token with JWT
   * 2. Find user by ID from token
   * 3. Generate new access token (keeping same refresh token)
   *
   * @param refreshTokenDto - Contains the refresh token
   * @returns New access token
   */
  async refreshToken(refreshTokenDto: RefreshTokenDto) {
    const { refreshToken } = refreshTokenDto;

    try {
      // Decode refresh token
      const decoded = this.jwtService.verify(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });

      const user = await this.userRepository.findOne({
        where: { id: decoded.sub },
        relations: ['roles'],
      });

      if (!user || user.accountStatus !== 'active') {
        throw new UnauthorizedException('Invalid refresh token');
      }

      // Generate new access token
      const newAccessToken = this.generateAccessToken(user);

      return {
        accessToken: newAccessToken,
        refreshToken: refreshToken, // Keep same refresh token
      };
    } catch (error) {
      this.logger.error(`Token refresh failed: ${error.message}`);
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  /**
   * VERIFY EMAIL/PHONE: Verify user's email or phone with token
   *
   * Flow:
   * 1. Find verification token
   * 2. Check if valid (not expired, correct type)
   * 3. Update user's verification status
   * 4. Mark token as used
   *
   * @param verifyTokenDto - Token and type to verify
   */
  async verifyToken(verifyTokenDto: VerifyTokenDto): Promise<void> {
    const { token, type, contactValue } = verifyTokenDto;

    this.logger.log(`Attempting token verification: type=${type}`);

    // ===== FIND TOKEN =====
    const verificationToken = await this.verificationTokenRepository.findOne({
      where: {
        token,
        type,
      },
      relations: ['user'],
    });

    if (!verificationToken) {
      throw new NotFoundException('Verification token not found');
    }

    // ===== CHECK VALIDITY =====
    if (verificationToken.isExpired()) {
      this.logger.warn(`Token verification failed: Token expired: ${token}`);
      throw new BadRequestException('Token has expired.');
    }

    if (verificationToken.isVerified) {
      throw new BadRequestException('Token has already been used.');
    }

    if (verificationToken.attemptCount >= 5) {
      throw new BadRequestException(
        'Too many failed attempts. Token has been locked.',
      );
    }

    // ===== UPDATE USER =====
    const user = verificationToken.user;

    if (type === 'email_verification') {
      user.emailVerified = true;
    } else if (type === 'phone_verification') {
      user.phoneVerified = true;
    }

    await this.userRepository.save(user);

    // ===== MARK TOKEN AS USED =====
    verificationToken.isVerified = true;
    verificationToken.verifiedAt = new Date();
    await this.verificationTokenRepository.save(verificationToken);

    this.logger.log(`Token verification successful for user: ${user.id}`);
  }

  /**
   * REQUEST PASSWORD RESET: Generate password reset token
   *
   * Flow:
   * 1. Find user by email
   * 2. Generate reset token (24h expiration)
   * 3. Send reset email with token
   *
   * @param requestPasswordResetDto - Email to reset
   */
  async requestPasswordReset(
    requestPasswordResetDto: RequestPasswordResetDto,
  ): Promise<void> {
    const { email } = requestPasswordResetDto;

    const user = await this.userRepository.findOne({ where: { email } });

    if (!user) {
      // For security: don't reveal if email exists
      this.logger.log(`Password reset requested for non-existent email: ${email}`);
      return;
    }

    // Generate reset token
    const resetToken = this.generateVerificationToken();
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24); // 24-hour expiration

    await this.verificationTokenRepository.save({
      userId: user.id,
      token: resetToken,
      type: 'password_reset',
      contactValue: email,
      expiresAt,
    });

    // TODO: Send password reset email
    // this.emailService.sendPasswordResetEmail(email, resetToken);

    this.logger.log(`Password reset token generated for user: ${user.id}`);
  }

  /**
   * RESET PASSWORD: Update user password with reset token
   *
   * @param resetPasswordDto - Reset token and new password
   */
  async resetPassword(resetPasswordDto: ResetPasswordDto): Promise<void> {
    const { token, newPassword } = resetPasswordDto;

    const verificationToken = await this.verificationTokenRepository.findOne({
      where: { token, type: 'password_reset' },
      relations: ['user'],
    });

    if (!verificationToken || verificationToken.isExpired()) {
      throw new BadRequestException('Invalid or expired reset token');
    }

    // Hash new password
    const passwordHash = await bcrypt.hash(newPassword, this.BCRYPT_ROUNDS);

    // Update user password
    await this.userRepository.update(verificationToken.userId, {
      passwordHash,
    });

    // Mark token as used
    verificationToken.isVerified = true;
    verificationToken.verifiedAt = new Date();
    await this.verificationTokenRepository.save(verificationToken);

    this.logger.log(
      `Password reset successful for user: ${verificationToken.userId}`,
    );
  }

  /**
   * GET PROFILE: Get current user's profile information
   *
   * @param userId - User ID from JWT token
   * @returns UserProfileDto
   */
  async getProfile(userId: string): Promise<UserProfileDto> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
      relations: ['roles'],
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.buildUserProfile(user);
  }

  /**
   * UPDATE PROFILE: Update user profile information
   *
   * @param userId - User ID from JWT
   * @param updateData - Fields to update
   */
  async updateProfile(
    userId: string,
    updateData: Partial<User>,
  ): Promise<UserProfileDto> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
      relations: ['roles'],
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Update fields
    Object.assign(user, updateData);
    const updated = await this.userRepository.save(user);

    return this.buildUserProfile(updated);
  }

  /**
   * LOGOUT: Invalidate user session
   *
   * Note: With JWT, we can't truly invalidate tokens server-side
   * This is more of a client-side operation (delete token from storage)
   * For true logout, implement a token blacklist/allowlist system
   *
   * @param userId - User logging out
   */
  async logout(userId: string): Promise<void> {
    // Update last activity
    await this.userRepository.update(userId, {
      lastLoginAt: new Date(),
    });

    this.logger.log(`User logged out: ${userId}`);

    // TODO: Implement token blacklist if needed
    // this.tokenBlacklistService.addToBlacklist(token);
  }

  // =========================================================================
  // PRIVATE HELPER METHODS
  // =========================================================================

  /**
   * Generate JWT access token
   * Expires in 24 hours
   * Contains: userId, email, roles
   */
  private generateAccessToken(user: User): string {
    const payload = {
      sub: user.id,
      email: user.email,
      roles: user.roles?.map((r) => r.name) || [],
    };

    return this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_SECRET'),
      expiresIn: this.configService.get<string>('JWT_EXPIRATION') || '24h',
    });
  }

  /**
   * Generate JWT refresh token
   * Expires in 7 days
   */
  private generateRefreshToken(user: User): string {
    const payload = {
      sub: user.id,
    };

    return this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      expiresIn: this.configService.get<string>('JWT_REFRESH_EXPIRATION') || '7d',
    });
  }

  /**
   * Generate verification token (email verification, OTP, etc.)
   * Returns 32-character random string
   */
  private generateVerificationToken(): string {
    return crypto.randomBytes(this.TOKEN_LENGTH).toString('hex');
  }

  /**
   * Build auth response DTO
   */
  private buildAuthResponse(
    user: User,
    accessToken: string,
    refreshToken: string,
  ): AuthResponseDto {
    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        fullName: user.fullName,
        roles: user.roles?.map((r) => r.name) || [],
        kycStatus: user.kycStatus,
        emailVerified: user.emailVerified,
        phoneVerified: user.phoneVerified,
        trustScore: user.trustScore,
        completedTrades: user.completedTrades,
      },
    };
  }

  /**
   * Build user profile DTO
   */
  private buildUserProfile(user: User): UserProfileDto {
    return {
      id: user.id,
      email: user.email,
      phone: user.phone,
      firstName: user.firstName,
      lastName: user.lastName,
      fullName: user.fullName,
      profileImageUrl: user.profileImageUrl,
      organizationName: user.organizationName,
      countryCode: user.countryCode,
      location: user.location,
      kycStatus: user.kycStatus,
      accountStatus: user.accountStatus,
      emailVerified: user.emailVerified,
      phoneVerified: user.phoneVerified,
      trustScore: user.trustScore,
      rating: user.rating,
      completedTrades: user.completedTrades,
      disputeCount: user.disputeCount,
      roles: user.roles?.map((r) => r.name) || [],
      lastLoginAt: user.lastLoginAt,
      createdAt: user.createdAt,
    };
  }
}
