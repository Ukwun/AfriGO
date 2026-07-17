import {
  Body,
  Controller,
  Get,
  Headers,
  Patch,
  Post,
  UnauthorizedException,
} from "@nestjs/common";
import { AuthService } from "./auth.service";

@Controller("api/auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post("session")
  createSession(@Body() body: any) {
    if (!body.idToken)
      throw new UnauthorizedException("Firebase ID token required");
    return this.authService.createSession(
      String(body.idToken),
      body.profile || {},
    );
  }

  @Get("me")
  async me(@Headers("authorization") authorization?: string) {
    const identity = await this.identity(authorization);
    return {
      success: true,
      user: await this.authService.getUserById(identity.uid),
    };
  }

  @Patch("me")
  async updateMe(
    @Headers("authorization") authorization: string | undefined,
    @Body() body: any,
  ) {
    const identity = await this.identity(authorization);
    return {
      success: true,
      user: await this.authService.updateProfile(identity.uid, body),
    };
  }

  private async identity(authorization?: string) {
    if (!authorization?.startsWith("Bearer "))
      throw new UnauthorizedException("Authentication required");
    return this.authService.verifyToken(authorization.slice(7));
  }
}
