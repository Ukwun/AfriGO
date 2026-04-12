import {
  Controller,
  Post,
  Body,
  Headers,
  BadRequestException,
  InternalServerErrorException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Stripe from 'stripe';
import { PaymentsService } from './payments.service';

@Controller('api/webhooks')
export class StripeWebhooksController {
  private stripe: Stripe;

  constructor(
    private paymentsService: PaymentsService,
    private configService: ConfigService,
  ) {
    this.stripe = new Stripe(this.configService.get('STRIPE_SECRET_KEY'), {
      apiVersion: '2022-11-15',
    });
  }

  /**
   * Stripe Webhook endpoint - handles all Stripe events
   * POST /api/webhooks/stripe
   */
  @Post('stripe')
  async handleStripeWebhook(
    @Body() rawBody: any,
    @Headers('stripe-signature') signature: string,
  ): Promise<{ success: boolean; message: string }> {
    if (!signature) {
      throw new BadRequestException('Missing stripe-signature header');
    }

    let event: Stripe.Event;

    try {
      // Verify webhook signature
      event = this.stripe.webhooks.constructEvent(
        JSON.stringify(rawBody),
        signature,
        this.configService.get('STRIPE_WEBHOOK_SECRET'),
      );
    } catch (error) {
      console.error('Stripe webhook signature verification failed:', error);
      throw new BadRequestException('Invalid stripe-signature');
    }

    try {
      // Process the webhook event
      await this.paymentsService.handleWebhookEvent(event);

      return {
        success: true,
        message: `Webhook processed: ${event.type}`,
      };
    } catch (error) {
      console.error('Error processing Stripe webhook:', error);
      throw new InternalServerErrorException('Failed to process webhook');
    }
  }

  /**
   * Health check endpoint for webhooks
   * GET /api/webhooks/health
   */
  @Post('stripe/health')
  healthCheck(): { status: string; timestamp: string } {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
    };
  }
}
