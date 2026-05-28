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

  async register(email: string, password: string, firstName: string, lastName: string): Promise<any> {
    // Check if user exists in Firestore
    const existingUserSnapshot = await this.firebaseService
      .users()
      .where('email', '==', email)
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
      email,
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
      roles: ['buyer'],
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    // Save to Firestore
    await this.firebaseService.users().doc(newUser.id).set(newUser);

    // Generate JWT token
    const token = jwt.sign(
      { id: newUser.id, email: newUser.email },
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
    // Find user in Firestore
    const userSnapshot = await this.firebaseService
      .users()
      .where('email', '==', email)
      .limit(1)
      .get();

    if (userSnapshot.empty) {
      throw new BadRequestException('Invalid email or password');
    }

    const userDoc = userSnapshot.docs[0];
    const user = userDoc.data();

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new BadRequestException('Invalid email or password');
    }

    // Generate JWT token
    const token = jwt.sign(
      { id: user.id, email: user.email },
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
        fullName: user.fullName,
        roles: user.roles,
        kycStatus: user.kycStatus,
        emailVerified: user.emailVerified,
      },
      token,
    };
  }
}
