import 'package:flutter/material.dart';

class PaymentBackendRequiredScreen extends StatelessWidget {
  const PaymentBackendRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Secure payment')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.account_balance_outlined, size: 54),
                    const SizedBox(height: 16),
                    Text('Payment service is not active',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    const Text(
                      'AfriGO will not simulate payment success. Flutterwave checkout becomes available after Firebase Functions, Secret Manager, webhooks, KYC, and the escrow ledger are deployed.',
                      textAlign: TextAlign.center,
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}
