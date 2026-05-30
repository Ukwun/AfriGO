import { Controller, Post, Body, BadRequestException } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('api/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body() body: any): Promise<any> {
    const { email, password, firstName, lastName, role } = body;

    // Validation
    if (!email || !password || !firstName || !lastName) {
      throw new BadRequestException('Missing required fields: email, password, firstName, lastName');
    }

    if (password.length < 6) {
      throw new BadRequestException('Password must be at least 6 characters');
    }

    if (!String(email).includes('@')) {
      throw new BadRequestException('Invalid email format');
    }

    return await this.authService.register(
      String(email),
      String(password),
      String(firstName),
      String(lastName),
      role ? String(role) : undefined,
    );
  }

  @Post('login')
  async login(@Body() body: any): Promise<any> {
    const { email, password } = body;

    if (!email || !password) {
      throw new BadRequestException('Email and password are required');
    }

    return await this.authService.login(email, password);
  }
}
