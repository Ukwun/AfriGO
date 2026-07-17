import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';
import '../../widgets/role_dashboard_shell.dart';
import '../../widgets/dashboard_role.dart';

class ExportPipelineScreen extends ConsumerWidget {
  const ExportPipelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleDashboardShell(
      role: DashboardRole.exporter,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Export Pipeline'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pipeline Overview
                Text(
                  'Current Pipeline Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                // Pipeline Stages
                ...List.generate(5, (index) {
                  final stages = [
                    _PipelineStage(
                      title: 'Order Received',
                      count: 12,
                      icon: Icons.inbox,
                      color: Colors.blue,
                    ),
                    _PipelineStage(
                      title: 'Warehouse Preparation',
                      count: 8,
                      icon: Icons.warehouse,
                      color: Colors.orange,
                    ),
                    _PipelineStage(
                      title: 'Documentation',
                      count: 5,
                      icon: Icons.description,
                      color: Colors.purple,
                    ),
                    _PipelineStage(
                      title: 'Quality Control',
                      count: 3,
                      icon: Icons.verified_user,
                      color: Colors.green,
                    ),
                    _PipelineStage(
                      title: 'Ready to Ship',
                      count: 2,
                      icon: Icons.local_shipping,
                      color: Colors.teal,
                    ),
                  ];
                  final stage = stages[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ScaleInTransition(
                      child: _buildPipelineStageCard(stage),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Recent Orders
                Text(
                  'Recent Export Orders',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...List.generate(3, (index) {
                  final orders = [
                    _ExportOrder(
                      orderNumber: 'EXP-2026-001',
                      product: 'Cocoa Beans (5,000 kg)',
                      buyer: 'Global Traders Ltd',
                      stage: 'Documentation',
                      daysLeft: 3,
                    ),
                    _ExportOrder(
                      orderNumber: 'EXP-2026-002',
                      product: 'Shea Butter (2,000 L)',
                      buyer: 'European Import Co',
                      stage: 'Quality Control',
                      daysLeft: 5,
                    ),
                    _ExportOrder(
                      orderNumber: 'EXP-2026-003',
                      product: 'Cashew Nuts (20,000 kg)',
                      buyer: 'Asian Export Hub',
                      stage: 'Warehouse Preparation',
                      daysLeft: 7,
                    ),
                  ];
                  final order = orders[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SlideInTransition(
                      child: _buildOrderCard(order),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineStageCard(_PipelineStage stage) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: stage.color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stage.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(stage.icon, color: stage.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${stage.count} orders',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: stage.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                stage.count.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: stage.color,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(_ExportOrder order) {
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
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.stage,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.product,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'To: ${order.buyer}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${order.daysLeft} days left',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PipelineStage {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  _PipelineStage({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });
}

class _ExportOrder {
  final String orderNumber;
  final String product;
  final String buyer;
  final String stage;
  final int daysLeft;

  _ExportOrder({
    required this.orderNumber,
    required this.product,
    required this.buyer,
    required this.stage,
    required this.daysLeft,
  });
}
