import { Module } from "@nestjs/common";
import { FirebaseModule } from "../firebase/firebase.module";
import { FirebaseAuthGuard } from "../common/firebase-auth.guard";
import { PaymentsController } from "./payments.controller";
import { PaymentsService } from "./payments.service";

@Module({
  imports: [FirebaseModule],
  controllers: [PaymentsController],
  providers: [PaymentsService, FirebaseAuthGuard],
})
export class PaymentsModule {}
