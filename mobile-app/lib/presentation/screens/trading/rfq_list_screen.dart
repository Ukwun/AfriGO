import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/colors.dart';
import '../../providers/rfq_provider.dart';
import '../../widgets/motion_system.dart';
import '../../widgets/role_dashboard_shell.dart';
import '../../widgets/dashboard_role.dart';

class RfqListScreen extends ConsumerWidget {
  const RfqListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rfqsAsync = ref.watch(rfqListProvider({
      'page': 1,
      'limit': 50,
    }));

    return RoleDashboardShell(
      role: DashboardRole.buyer,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Requests for Quotes'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: rfqsAsync.when(
          data: (rfqs) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Create RFQ Button
                    SlideInTransition(
                      child: FilledButton.icon(
                        onPressed: () => context.push('/rfqs/create'),
                        icon: const Icon(Icons.add),
                        label: const Text('Create New RFQ'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // RFQ List
                    ...List.generate(rfqs.length, (index) {
                      final rfq = rfqs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ScaleInTransition(
                          child: _buildRFQCard(context, rfq),
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

  Widget _buildRFQCard(BuildContext context, dynamic rfq) {
    final statusColor = _getStatusColor(rfq.status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: InkWell(
        onTap: () => context.push('/rfqs/detail/${rfq.id}'),
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
                          rfq.productCategory,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rfq.productDescription,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      rfq.status.toUpperCase(),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${rfq.quantity} ${rfq.quantityUnit}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    'Bids: ${rfq.submittedBids.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.blue;
      case 'evaluating':
        return Colors.orange;
      case 'awarded':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
