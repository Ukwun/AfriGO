import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/colors.dart';
import '../../providers/shipment_provider.dart';
import '../../widgets/motion_system.dart';
import '../../widgets/role_dashboard_shell.dart';
import '../../widgets/dashboard_role.dart';

class ShipmentListScreen extends ConsumerWidget {
  const ShipmentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipmentsAsync =
        ref.watch(shipmentsProvider(const ShipmentFilters()));

    return RoleDashboardShell(
      role: DashboardRole.buyer,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shipments'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: shipmentsAsync.when(
          data: (shipments) {
            final shipmentList = shipments.data;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: ScaleInTransition(
                            child: _buildStatCard(
                              icon: Icons.local_shipping,
                              label: 'In Transit',
                              value: shipmentList
                                  .where((s) => s.status == 'in_transit')
                                  .length
                                  .toString(),
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ScaleInTransition(
                            child: _buildStatCard(
                              icon: Icons.check_circle,
                              label: 'Delivered',
                              value: shipmentList
                                  .where((s) => s.status == 'delivered')
                                  .length
                                  .toString(),
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Shipments List
                    Text(
                      'All Shipments',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(shipmentList.length, (index) {
                      final shipment = shipmentList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SlideInTransition(
                          child: _buildShipmentCard(context, shipment),
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

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentCard(BuildContext context, dynamic shipment) {
    final statusColor = _getStatusColor(shipment.status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: InkWell(
        onTap: () => context.push('/shipments/detail/${shipment.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    shipment.shipmentReference,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      shipment.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'From: ${shipment.pickupLocationName}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'To: ${shipment.deliveryLocationName}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Expected: ${shipment.expectedDeliveryDate.day}/${shipment.expectedDeliveryDate.month}/${shipment.expectedDeliveryDate.year}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_transit':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
