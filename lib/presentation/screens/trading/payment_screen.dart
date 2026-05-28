import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/trading_provider.dart';
import '../../../data/services/payment_service.dart';

/// Payment Processing Screen
/// Buyer confirms payment to escrow
/// REAL fraud detection runs BEFORE payment processes
class PaymentProcessingScreen extends ConsumerStatefulWidget {
  final String tradeId;

  const PaymentProcessingScreen({Key? key, required this.tradeId})
    : super(key: key);

  @override
  ConsumerState<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState
    extends ConsumerState<PaymentProcessingScreen> {
  bool _isProcessing = false;
  double _fraudScore = 0;
  String _fraudStatus = 'UNKNOWN';
  bool _agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    final tradeAsync = ref.watch(tradeDetailProvider(widget.tradeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: tradeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (trade) {
          final totalAmount = trade.totalValue;
          final buyerName = trade.buyerName ?? 'Buyer';
          final sellerName = trade.sellerName ?? 'Seller';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment summary
                _buildPaymentSummary(
                  trade.productType,
                  trade.quantity,
                  trade.offeredPrice,
                  totalAmount,
                ),

                const SizedBox(height: 32),

                // Fraud risk indicator
                _buildFraudRiskDisplay(trade.fraudScore),

                const SizedBox(height: 32),

                // Parties involved
                _buildPartiesCard(buyerName, sellerName),

                const SizedBox(height: 32),

                // Escrow explanation
                _buildEscrowExplanation(),

                const SizedBox(height: 32),

                // Terms agreement
                _buildTermsAgreement(),

                const SizedBox(height: 32),

                // Payment methods
                _buildPaymentMethods(),

                const SizedBox(height: 32),

                // Action buttons
                _buildActionButtons(context, totalAmount),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Payment summary card
  Widget _buildPaymentSummary(
    String productType,
    double quantity,
    double pricePerUnit,
    double totalAmount,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Product:', style: TextStyle(color: Colors.grey)),
                Text(
                  productType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Quantity:', style: TextStyle(color: Colors.grey)),
                Text(
                  '${quantity.toStringAsFixed(0)}kg',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price/kg:', style: TextStyle(color: Colors.grey)),
                Text(
                  '\$${pricePerUnit.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.blue[900]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Amount held in escrow until delivery confirmed',
                      style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fraud risk display
  Widget _buildFraudRiskDisplay(double? fraudScore) {
    final score = fraudScore ?? 0;
    final isHighRisk = score > 70;
    final isMediumRisk = score > 50 && score <= 70;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighRisk
            ? Colors.red[50]
            : isMediumRisk
            ? Colors.orange[50]
            : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHighRisk
              ? Colors.red[200]!
              : isMediumRisk
              ? Colors.orange[200]!
              : Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isHighRisk
                ? Icons.warning
                : isMediumRisk
                ? Icons.info
                : Icons.check_circle,
            color: isHighRisk
                ? Colors.red
                : isMediumRisk
                ? Colors.orange
                : Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHighRisk
                      ? 'High Fraud Risk'
                      : isMediumRisk
                      ? 'Medium Fraud Risk'
                      : 'Low Fraud Risk',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isHighRisk
                        ? Colors.red
                        : isMediumRisk
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: ${score.toStringAsFixed(0)}/100',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Parties involved card
  Widget _buildPartiesCard(String buyerName, String sellerName) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaction Parties',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buyer',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      buyerName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward, color: Colors.grey[400]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seller',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sellerName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Escrow explanation
  Widget _buildEscrowExplanation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How Escrow Works',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('1. ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text('You pay → Money held in escrow')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('2. ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text('Seller ships product')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('3. ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text('You confirm delivery & quality')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('4. ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text('Payment released to seller')),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '✓ Your money is always safe',
              style: TextStyle(fontSize: 12, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  /// Terms agreement checkbox
  Widget _buildTermsAgreement() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agreement',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'I agree to the transaction terms and payment conditions',
                style: TextStyle(fontSize: 13),
              ),
              value: _agreedToTerms,
              onChanged: (value) {
                setState(() => _agreedToTerms = value ?? false);
              },
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                // Open terms modal
                _showTermsDialog(context);
              },
              child: const Text(
                'View full terms & conditions',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Payment methods
  Widget _buildPaymentMethods() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
                color: Colors.green[50],
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.green),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flutterwave Payment Gateway',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Card, Mobile Money, Bank Transfer',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Action buttons
  Widget _buildActionButtons(BuildContext context, double amount) {
    return Column(
      children: [
        // Pay button - FUNCTIONAL with fraud detection
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_agreedToTerms && !_isProcessing)
                ? () => _processPayment(context, amount)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('PAY NOW'),
          ),
        ),
        const SizedBox(height: 12),
        // Cancel button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  /// Process payment - REAL backend call with fraud detection
  Future<void> _processPayment(BuildContext context, double amount) async {
    setState(() => _isProcessing = true);

    try {
      final paymentService = ref.read(paymentServiceProvider);
      final tradeService = ref.read(tradeServiceProvider);

      // REAL fraud detection before payment
      final fraudScore = await tradeService.detectFraud(
        amount: amount,
        action: 'PROCESS_PAYMENT',
      );

      setState(() => _fraudScore = fraudScore);

      // Check fraud score
      if (fraudScore > 80) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Payment blocked due to fraud detection. Please contact support.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // FUNCTIONAL [PAY NOW] button - REAL backend call
      // This triggers:
      // 1. Fraud detection score logged
      // 2. Payment order created in database
      // 3. Escrow account initiated (money held safely)
      // 4. Activity log entry created (immutable)
      // 5. WebSocket broadcast (PAYMENT_CONFIRMED event)
      // 6. Seller notified in real-time (<500ms)
      // 7. Contract generation initiated
      // 8. Payment gateway integration (Flutterwave)
      final result = await paymentService.initiatePayment(
        tradeId: widget.tradeId,
        amount: amount,
        fraudScore: fraudScore,
        paymentMethod: 'CARD', // Or MOBILE_MONEY, BANK_TRANSFER
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment processing... Please wait'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to Flutterwave gateway or payment success
        context.go('/payment-confirmation/${result['paymentOrderId']}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Show terms dialog
  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Terms & Conditions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '1. Payment Terms\n'
                          'Payment is held in escrow until delivery confirmed.\n\n'
                          '2. Escrow Protection\n'
                          'AfriGo holds payment safely. Release only after both parties agree.\n\n'
                          '3. Dispute Resolution\n'
                          'Any disputes resolved within 7 days by AfriGo team.\n\n'
                          '4. Quality Assurance\n'
                          'Buyer confirms quality matches agreement before payment release.\n\n'
                          '5. Fraud Detection\n'
                          'All transactions checked for fraud. Suspicious activity investigated.\n\n'
                          '6. Data Privacy\n'
                          'Your personal data protected per our privacy policy.\n\n'
                          '7. Liability\n'
                          'AfriGo not liable for product quality. Seller responsible for accuracy.',
                          style: TextStyle(fontSize: 12, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('I Understand'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
