import { NestFactory } from "@nestjs/core";
import { ExpressAdapter } from "@nestjs/platform-express";
import { onRequest } from "firebase-functions/v2/https";
import express from "express";
import { AppModule } from "./app.module";

const server = express();
let initialized: Promise<void> | undefined;

function initialize(): Promise<void> {
  initialized ??= NestFactory.create(AppModule, new ExpressAdapter(server), {
    logger:
      process.env.NODE_ENV === "production"
        ? ["error", "warn", "log"]
        : undefined,
  }).then(async (app) => {
    app.enableCors({
      origin: true,
      credentials: false,
      allowedHeaders: ["Content-Type", "Authorization", "Idempotency-Key"],
    });
    await app.init();
  });
  return initialized;
}

export const api = onRequest(
  {
    region: "europe-west1",
    memory: "512MiB",
    timeoutSeconds: 60,
    concurrency: 40,
    secrets: [
      "STRIPE_SECRET_KEY",
      "STRIPE_WEBHOOK_SECRET",
      "STRIPE_PUBLISHABLE_KEY",
      "FLUTTERWAVE_SECRET_KEY",
      "FLUTTERWAVE_PUBLIC_KEY",
      "FLUTTERWAVE_WEBHOOK_SECRET",
      "FLUTTERWAVE_REDIRECT_URL",
    ],
  },
  async (request, response) => {
    await initialize();
    server(request, response);
  },
);
