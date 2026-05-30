import { Injectable, BadRequestException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import * as jwt from 'jsonwebtoken';
import { FirebaseService } from '../firebase/firebase.service';

@Injectable()
export class AuthService {
  private jwtSecret = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

  constructor(private firebaseService: FirebaseService) {}

  private generateId(): string {
    return `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  private normalizeEmail(email: string): string {
    return email.trim().toLowerCase();
  }

  private normalizeRole(role?: string): string {
    const value = (role || 'buyer').trim().toLowerCase();
    if (value === 'supplier') return 'supplier';
    if (value === 'seller') return 'seller';
    if (value === 'exporter') return 'exporter';
    return 'buyer';
  }

  async register(
    email: string,
    password: string,
    firstName: string,
    lastName: string,
    role?: string,
  ): Promise<any> {
    const normalizedEmail = this.normalizeEmail(email);
    const normalizedRole = this.normalizeRole(role);

    // Check if user exists in Firestore
    const existingUserSnapshot = await this.firebaseService
      .users()
      .where('email', '==', normalizedEmail)
      .limit(1)
      .get();

    if (!existingUserSnapshot.empty) {
      throw new BadRequestException('User with this email already exists');
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user object
    const newUser = {
      id: this.generateId(),
      email: normalizedEmail,
      passwordHash: hashedPassword,
      firstName,
      lastName,
      fullName: `${firstName} ${lastName}`,
      emailVerified: false,
      phoneVerified: false,
      kycStatus: 'pending',
      accountStatus: 'active',
      trustScore: 0,
      completedTrades: 0,
      roles: [normalizedRole],
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    // Save to Firestore
    await this.firebaseService.users().doc(newUser.id).set(newUser);

    // Generate JWT token
    const token = jwt.sign(
      { sub: newUser.id, id: newUser.id, email: newUser.email },
      this.jwtSecret,
      { expiresIn: '24h' }
    );

    return {
      success: true,
      message: 'User registered successfully',
      user: {
        id: newUser.id,
        email: newUser.email,
        firstName: newUser.firstName,
        lastName: newUser.lastName,
        fullName: newUser.fullName,
        roles: newUser.roles,
        kycStatus: newUser.kycStatus,
        emailVerified: newUser.emailVerified,
      },
      token,
    };
  }

  async login(email: string, password: string): Promise<any> {
    const normalizedEmail = this.normalizeEmail(email);

    // Find user in Firestore
    const userSnapshot = await this.firebaseService
      .users()
      .where('email', '==', normalizedEmail)
      .limit(1)
      .get();

    if (userSnapshot.empty) {
      throw new BadRequestException('Invalid email or password');
    }

    const userDoc = userSnapshot.docs[0];
    const user = userDoc.data() as any;

    if (!user.passwordHash) {
      throw new BadRequestException('This account cannot use password login. Please sign in with its original provider.');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new BadRequestException('Invalid email or password');
    }

    // Generate JWT token
    const token = jwt.sign(
      { sub: user.id, id: user.id, email: user.email },
      this.jwtSecret,
      { expiresIn: '24h' }
    );

    return {
      success: true,
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        fullName: user.fullName ?? `${user.firstName ?? ''} ${user.lastName ?? ''}`.trim(),
        roles: user.roles ?? ['buyer'],
        kycStatus: user.kycStatus ?? 'pending',
        emailVerified: !!user.emailVerified,
        phoneVerified: !!user.phoneVerified,
        trustScore: user.trustScore ?? 0,
        completedTrades: user.completedTrades ?? 0,
      },
      token,
    };
  }
}
