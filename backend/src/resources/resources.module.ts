import { Module } from "@nestjs/common";
import { FirebaseModule } from "../firebase/firebase.module";
import { FirebaseAuthGuard } from "../common/firebase-auth.guard";
import { ResourcesController } from "./resources.controller";
import { ResourcesService } from "./resources.service";

@Module({
  imports: [FirebaseModule],
  controllers: [ResourcesController],
  providers: [ResourcesService, FirebaseAuthGuard],
})
export class ResourcesModule {}
