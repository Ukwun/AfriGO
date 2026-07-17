import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { FirebaseService } from "../firebase/firebase.service";

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(private readonly firebase: FirebaseService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const authorization = request.headers.authorization as string | undefined;
    if (!authorization?.startsWith("Bearer "))
      throw new UnauthorizedException("Authentication required");
    try {
      const identity = await this.firebase.verifyIdToken(
        authorization.slice(7),
      );
      const profile = await this.firebase.users().doc(identity.uid).get();
      if (!profile.exists)
        throw new UnauthorizedException("User profile not found");
      request.user = { uid: identity.uid, ...profile.data() };
      return true;
    } catch (error) {
      if (error instanceof UnauthorizedException) throw error;
      throw new UnauthorizedException("Invalid or expired session");
    }
  }
}
