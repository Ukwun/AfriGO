import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:afrigo_app/providers/content_providers.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class ContractsListScreen extends ConsumerWidget {
  const ContractsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(contractsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contracts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: contractsAsync.when(
        data: (contracts) {
          final active = contracts.where((c) => c.status == 'active').toList();
          final pending =
              contracts.where((c) => c.status.contains('pending')).toList();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary
                  Row(
                    children: [
                      Expanded(
                        child: ScaleInTransition(
                          child: _buildStatusCard(
                            label: 'Active',
                            count: active.length,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ScaleInTransition(
                          child: _buildStatusCard(
                            label: 'Pending Signature',
                            count: pending.length,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Active Contracts
                  if (active.isNotEmpty) ...[
                    Text(
                      'Active Contracts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(active.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SlideInTransition(
                          child: _buildContractCard(context, active[index]),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // Pending Contracts
                  if (pending.isNotEmpty) ...[
                    Text(
                      'Pending Signature',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(pending.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SlideInTransition(
                          child: _buildContractCard(context, pending[index]),
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

  Widget _buildStatusCard({
    required String label,
    required int count,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractCard(BuildContext context, dynamic contract) {
    final pendingSignature = contract.status.contains('pending');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: InkWell(
        onTap: () => context.push('/contracts/detail/${contract.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contract ${contract.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${contract.buyerName} ↔ ${contract.sellerName}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (pendingSignature)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PENDING',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${contract.totalQuantity.toStringAsFixed(1)} ${contract.unit}',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${contract.currency} ${contract.totalValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
