import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/colors.dart';
import '../../providers/rfq_provider.dart';
import '../../widgets/motion_system.dart';

class RfqDetailScreen extends ConsumerWidget {
  const RfqDetailScreen({super.key, required this.rfqId});
  final String rfqId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rfqAsync = ref.watch(rfqDetailProvider(rfqId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('RFQ Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: rfqAsync.when(
        data: (rfq) => SingleChildScrollView(
          child: Column(
            children: [
              // Header with status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreenLighter,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInTransition(
                      child: Text(
                        rfq.productCategory,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SlideInTransition(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          rfq.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Info
                    Text(
                      'Product Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ScaleInTransition(
                      child: _buildInfoCard(
                        label: 'Description',
                        value: rfq.productDescription,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ScaleInTransition(
                      child: _buildInfoCard(
                        label: 'Quantity',
                        value: '${rfq.quantity} ${rfq.quantityUnit}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ScaleInTransition(
                      child: _buildInfoCard(
                        label: 'Origin',
                        value: rfq.originCountryPreference ?? 'Any',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Buyer Info
                    Text(
                      'Buyer Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SlideInTransition(
                      child: _buildInfoCard(
                        label: 'Company',
                        value: rfq.buyerCompanyName,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SlideInTransition(
                      child: _buildInfoCard(
                        label: 'Delivery Location',
                        value: rfq.deliveryLocation ?? 'Not specified',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bids Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bids Received',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withAlpha(26),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${rfq.submittedBids.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    if (rfq.status == 'open')
                      Column(
                        children: [
                          ScaleInTransition(
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () => context
                                    .push('/trading/submit-bid/${rfq.id}'),
                                icon: const Icon(Icons.send),
                                label: const Text('Submit a Bid'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ScaleInTransition(
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.message),
                                label: const Text('Contact Buyer'),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      ScaleInTransition(
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.info),
                            label: const Text('RFQ is closed'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
