import {
  Body,
  Controller,
  Get,
  Headers,
  Param,
  Post,
  Req,
  UseGuards,
} from "@nestjs/common";
import { FirebaseAuthGuard } from "../common/firebase-auth.guard";
import { PaymentsService } from "./payments.service";

@Controller("api/payments")
export class PaymentsController {
  constructor(private readonly payments: PaymentsService) {}

  @Get("config/publishable-key")
  @UseGuards(FirebaseAuthGuard)
  config() {
    return this.payments.publishableKey();
  }

  @Post()
  @UseGuards(FirebaseAuthGuard)
  create(
    @Req() request: any,
    @Body("orderId") orderId: string,
    @Headers("idempotency-key") key: string,
  ) {
    return this.payments.createIntent(request.user, orderId, key);
  }

  @Get()
  @UseGuards(FirebaseAuthGuard)
  list(@Req() request: any) {
    return this.payments.list(request.user);
  }

  @Get(":paymentId")
  @UseGuards(FirebaseAuthGuard)
  get(@Req() request: any, @Param("paymentId") paymentId: string) {
    return this.payments.get(request.user, paymentId);
  }

  @Post(":paymentId/release-escrow")
  @UseGuards(FirebaseAuthGuard)
  capture(
    @Req() request: any,
    @Param("paymentId") paymentId: string,
    @Headers("idempotency-key") key: string,
  ) {
    return this.payments.capture(request.user, paymentId, key);
  }

  @Post("webhook/stripe")
  webhook(@Req() request: any, @Headers("stripe-signature") signature: string) {
    return this.payments.handleWebhook(signature, request.rawBody);
  }

  @Post("webhook/flutterwave")
  flutterwaveWebhook(
    @Req() request: any,
    @Headers("flutterwave-signature") signature: string,
    @Body() payload: any,
  ) {
    return this.payments.handleFlutterwaveWebhook(signature, request.rawBody, payload);
  }
}
