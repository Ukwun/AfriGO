import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/colors.dart';
import '../../providers/dashboard_records_provider.dart';
import '../../widgets/motion_system.dart';
import '../../widgets/role_dashboard_shell.dart';
import '../../widgets/dashboard_role.dart';

class RfqListScreen extends ConsumerWidget {
  const RfqListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rfqsAsync = ref.watch(dashboardRecordsProvider('rfqs'));

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
            if (rfqs.isEmpty) {
              return _EmptyRfqs(
                onCreate: () => context.push('/rfqs/create'),
              );
            }
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
          error: (_, __) => _LoadFailure(
            onRetry: () => ref.invalidate(dashboardRecordsProvider('rfqs')),
          ),
        ),
      ),
    );
  }

  Widget _buildRFQCard(
      BuildContext context, Map<String, dynamic> rfq) {
    final status = (rfq['status'] ?? 'draft').toString();
    final statusColor = _getStatusColor(status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: InkWell(
        onTap: () => context.push('/rfqs/detail/${rfq['id']}'),
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
                          (rfq['productCategory'] ??
                                  rfq['commodity'] ??
                                  rfq['productName'] ??
                                  'Request for quote')
                              .toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (rfq['productDescription'] ??
                                  rfq['description'] ??
                                  'No additional description')
                              .toString(),
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
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
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
                      '${rfq['quantity'] ?? 0} ${rfq['quantityUnit'] ?? rfq['unit'] ?? ''}',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    'Offers: ${(rfq['submittedBids'] as List?)?.length ?? rfq['offerCount'] ?? 0}',
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

class _EmptyRfqs extends StatelessWidget {
  const _EmptyRfqs({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.request_quote_outlined, size: 52),
            const SizedBox(height: 16),
            Text('No RFQs yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Create your first request and it will appear here as soon as Firebase confirms it.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create RFQ'),
            ),
          ]),
        ),
      );
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Firebase could not refresh your RFQs. Existing cached records may become available when connectivity returns.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ]),
        ),
      );
}
