import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:afrigo_app/providers/content_providers.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';
import '../../widgets/role_dashboard_shell.dart';
import '../../widgets/dashboard_role.dart';

class LotsListScreen extends ConsumerWidget {
  const LotsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotsAsync = ref.watch(lotsListProvider);

    return RoleDashboardShell(
      role: DashboardRole.supplier,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Lots'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/lots/create'),
          child: const Icon(Icons.add),
        ),
        body: lotsAsync.when(
          data: (lots) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Stats
                    Row(
                      children: [
                        Expanded(
                          child: ScaleInTransition(
                            child: _buildSummaryCard(
                              label: 'Total Lots',
                              value: lots.length.toString(),
                              icon: Icons.inventory_2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ScaleInTransition(
                            child: _buildSummaryCard(
                              label: 'Available',
                              value: lots
                                  .where((l) => l.status == 'active')
                                  .length
                                  .toString(),
                              icon: Icons.check_circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Lots Grid
                    ...List.generate(lots.length, (index) {
                      final lot = lots[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SlideInTransition(
                          child: _buildLotCard(context, lot),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLotCard(BuildContext context, dynamic lot) {
    final statusColor = lot.status == 'active' ? Colors.green : Colors.grey;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: InkWell(
        onTap: () => context.push('/lots/detail/${lot.id}'),
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
                          lot.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${lot.originLocation}, ${lot.originCountry}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          lot.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Grade: ${lot.gradeLevel}',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${lot.quantity} ${lot.quantityUnit} available',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '\$${lot.pricePerUnit.toStringAsFixed(2)}/unit',
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
