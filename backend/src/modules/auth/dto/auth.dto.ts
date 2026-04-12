/**
 * Auth DTOs - Request and Response objects for API endpoints
 */

import { IsEmail, IsString, MinLength, IsOptional, IsPhoneNumber } from 'class-validator';

/**
 * Register request DTO
 */
export class RegisterDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(3)
  firstName: string;

  @IsString()
  @MinLength(3)
  lastName: string;

  @IsString()
  @MinLength(8, {
    message: 'Password must be at least 8 characters long',
  })
  password: string;

  @IsOptional()
  @IsPhoneNumber()
  phone?: string;

  @IsOptional()
  @IsString()
  organizationName?: string;

  @IsOptional()
  @IsString()
  countryCode?: string; // e.g., 'GH', 'NG', 'KE'
}

/**
 * Login request DTO
 */
export class LoginDto {
  @IsEmail()
  email: string;

  @IsString()
  password: string;
}

/**
 * Refresh token request DTO
 */
export class RefreshTokenDto {
  @IsString()
  refreshToken: string;
}

/**
 * Verify OTP/Token request DTO
 */
export class VerifyTokenDto {
  @IsString()
  token: string;

  @IsString()
  type: string; // 'email_verification', 'phone_verification', etc.

  @IsOptional()
  @IsString()
  contactValue?: string; // email or phone being verified
}

/**
 * Password reset request DTO
 */
export class RequestPasswordResetDto {
  @IsEmail()
  email: string;
}

/**
 * Password reset confirmation DTO
 */
export class ResetPasswordDto {
  @IsString()
  token: string;

  @IsString()
  @MinLength(8)
  newPassword: string;
}

/**
 * Update profile request DTO
 */
export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  @MinLength(3)
  firstName?: string;

  @IsOptional()
  @IsString()
  @MinLength(3)
  lastName?: string;

  @IsOptional()
  @IsString()
  organizationName?: string;

  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @IsString()
  countryCode?: string;

  @IsOptional()
  @IsString()
  language?: string;
}

/**
 * Auth response DTO
 * Returned on successful login/register
 */
export class AuthResponseDto {
  accessToken: string;
  refreshToken: string;
  user: {
    id: string;
    email: string;
    firstName: string;
    lastName: string;
    fullName: string;
    roles: string[];
    kycStatus: string;
    emailVerified: boolean;
    phoneVerified: boolean;
    trustScore: number;
    completedTrades: number;
  };
}

/**
 * User profile response DTO
 */
export class UserProfileDto {
  id: string;
  email: string;
  phone: string;
  firstName: string;
  lastName: string;
  fullName: string;
  profileImageUrl: string;
  organizationName: string;
  countryCode: string;
  location: string;
  kycStatus: 'pending' | 'verified' | 'rejected' | 'expired';
  accountStatus: 'active' | 'suspended' | 'banned';
  emailVerified: boolean;
  phoneVerified: boolean;
  trustScore: number;
  rating: number;
  completedTrades: number;
  disputeCount: number;
  roles: string[];
  lastLoginAt: Date;
  createdAt: Date;
}
