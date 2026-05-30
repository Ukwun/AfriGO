import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../models/rfq_model.dart';
import '../providers/rfq_provider.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/animated_button.dart';

class RFQBrowseScreen extends ConsumerStatefulWidget {
  const RFQBrowseScreen({super.key});

  @override
  ConsumerState<RFQBrowseScreen> createState() => _RFQBrowseScreenState();
}

class _RFQBrowseScreenState extends ConsumerState<RFQBrowseScreen> {
  late TextEditingController searchController;
  String selectedCategory = '';
  int currentPage = 1;

  final List<String> categories = [
    'All',
    'Cocoa',
    'Coffee',
    'Cashew',
    'Grains',
    'Vegetables',
    'Spices',
  ];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = {
      'status': 'open',
      'category': selectedCategory.isEmpty || selectedCategory == 'All'
          ? null
          : selectedCategory,
      'searchTerm':
          searchController.text.isEmpty ? null : searchController.text,
      'page': currentPage,
      'limit': 20,
    };

    final rfqsAsync = ref.watch(rfqListProvider(filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available RFQs'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by product or category...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() => currentPage = 1);
              },
            ),
          ),

          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = selected ? cat : '';
                          currentPage = 1;
                        });
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Colors.blue,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // RFQ List
          Expanded(
            child: rfqsAsync.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No RFQs found'),
                        SizedBox(height: 8),
                        Text(
                          'Check back later for new opportunities',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final rfq = data[index];
                    return _RFQCard(
                      rfq: rfq,
                      onTap: () =>
                          context.pushNamed('rfq-detail', arguments: rfq.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    AnimatedPrimaryButton(
                      label: 'Retry',
                      onPressed: () => ref.refresh(rfqListProvider(filters)),
                      isLargeTouchTarget: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RFQCard extends ConsumerWidget {
  final RFQModel rfq;
  final VoidCallback onTap;

  const _RFQCard({
    required this.rfq,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _daysRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);
    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else {
      return 'Expires today';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ModernCard(
      isFloating: true,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
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
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rfq.productDescription.length > 60
                            ? '${rfq.productDescription.substring(0, 60)}...'
                            : rfq.productDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _daysRemaining(rfq.expiresAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),

            // Details Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DetailColumn(
                  label: 'Quantity',
                  value:
                      '${rfq.quantity.toStringAsFixed(0)} ${rfq.quantityUnit}',
                ),
                _DetailColumn(
                  label: 'Origin Preference',
                  value: rfq.originCountryPreference ?? 'Any',
                ),
                _DetailColumn(
                  label: 'Grade Preference',
                  value: rfq.gradePreference ?? 'Any',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Buyer Info
            Row(
              children: [
                const Icon(Icons.business, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rfq.buyerCompanyName,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Footer Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expected Bids',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      '${rfq.submittedBids.length}/${rfq.maxBidsExpected}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Delivery By',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      _formatDate(rfq.deliveryDeadline),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Posted',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      _getTimeAgo(rfq.createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

class _DetailColumn extends StatelessWidget {
  final String label;
  final String value;

  const _DetailColumn({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
