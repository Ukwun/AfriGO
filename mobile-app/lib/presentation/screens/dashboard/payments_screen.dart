import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:afrigo_app/providers/content_providers.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments & Transactions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: paymentsAsync.when(
        data: (payments) {
          final completed =
              payments.where((p) => p.paymentStatus == 'completed').toList();
          final pending =
              payments.where((p) => p.paymentStatus == 'pending').toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: ScaleInTransition(
                          child: _buildSummaryCard(
                            label: 'Total Received',
                            amount:
                                '\$${completed.fold<double>(0, (sum, p) => sum + p.amount).toStringAsFixed(2)}',
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ScaleInTransition(
                          child: _buildSummaryCard(
                            label: 'Pending',
                            amount:
                                '\$${pending.fold<double>(0, (sum, p) => sum + p.amount).toStringAsFixed(2)}',
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Completed Payments
                  if (completed.isNotEmpty) ...[
                    Text(
                      'Completed',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(completed.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SlideInTransition(
                          child: _buildPaymentTile(completed[index]),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // Pending Payments
                  if (pending.isNotEmpty) ...[
                    Text(
                      'Pending',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(pending.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SlideInTransition(
                          child: _buildPaymentTile(pending[index]),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile(dynamic payment) {
    final statusColor =
        payment.paymentStatus == 'completed' ? Colors.green : Colors.orange;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.relatedProduct,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payment.invoiceNumber,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+\$${payment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        payment.paymentStatus.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}
