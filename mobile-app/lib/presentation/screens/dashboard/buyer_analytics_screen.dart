import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/dashboard_records_provider.dart';

class BuyerAnalyticsScreen extends ConsumerWidget {
  const BuyerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(dashboardRecordsProvider('orders'));
    final payments = ref.watch(dashboardRecordsProvider('payments'));

    return Scaffold(
      appBar: AppBar(title: const Text('Trade analytics')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardRecordsProvider('orders'));
          ref.invalidate(dashboardRecordsProvider('payments'));
          await Future.wait([
            ref.read(dashboardRecordsProvider('orders').future),
            ref.read(dashboardRecordsProvider('payments').future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Calculated from your verified AfriGO records',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            orders.when(
              loading: _loading,
              error: (_, __) => _error(
                () => ref.invalidate(dashboardRecordsProvider('orders')),
              ),
              data: (orderRecords) => payments.when(
                loading: _loading,
                error: (_, __) => _error(
                  () => ref.invalidate(dashboardRecordsProvider('payments')),
                ),
                data: (paymentRecords) =>
                    _Analytics(records: orderRecords, payments: paymentRecords),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loading() => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );

  Widget _error(VoidCallback retry) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: 12),
            const Text(
              'Analytics could not refresh from Firebase.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ]),
        ),
      );
}

class _Analytics extends StatelessWidget {
  const _Analytics({required this.records, required this.payments});
  final List<Map<String, dynamic>> records;
  final List<Map<String, dynamic>> payments;

  double _amount(Map<String, dynamic> record) {
    final value = record['amount'] ?? record['totalAmount'] ?? 0;
    return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final verifiedPayments = payments.where((payment) {
      final status = (payment['status'] ?? '').toString().toLowerCase();
      return status == 'successful' ||
          status == 'succeeded' ||
          status == 'completed';
    }).toList();
    final spent =
        verifiedPayments.fold<double>(0, (sum, item) => sum + _amount(item));
    final currency = verifiedPayments.isEmpty
        ? ''
        : (verifiedPayments.first['currency'] ?? '').toString().toUpperCase();
    final completedOrders = records.where((order) {
      final status = (order['status'] ?? '').toString().toLowerCase();
      return status == 'completed' || status == 'delivered';
    }).length;
    final activeOrders = records.length - completedOrders;

    if (records.isEmpty && payments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(children: [
            const Icon(Icons.analytics_outlined, size: 48),
            const SizedBox(height: 12),
            Text('No trade analytics yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Metrics will appear after your first real order or verified payment. AfriGO does not manufacture sample performance.',
              textAlign: TextAlign.center,
            ),
          ]),
        ),
      );
    }

    final metrics = <(String, String, IconData)>[
      ('Verified spend', '$currency ${spent.toStringAsFixed(2)}',
          Icons.account_balance_wallet_outlined),
      ('Orders', '${records.length}', Icons.receipt_long_outlined),
      ('Completed', '$completedOrders', Icons.check_circle_outline),
      ('Active', '$activeOrders', Icons.pending_actions_outlined),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 700 ? 4 : 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: metrics.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
        ),
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: .94, end: 1),
            duration: Duration(milliseconds: 220 + index * 70),
            curve: Curves.easeOutBack,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(metric.$3),
                    const Spacer(),
                    Text(metric.$2,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            )),
                    Text(metric.$1),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
