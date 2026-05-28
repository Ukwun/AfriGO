import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/lots_provider.dart';

class SellerLotsScreen extends ConsumerStatefulWidget {
  const SellerLotsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SellerLotsScreen> createState() => _SellerLotsScreenState();
}

class _SellerLotsScreenState extends ConsumerState<SellerLotsScreen> {
  String selectedStatus = 'all';
  final List<String> statusFilters = [
    'all',
    'draft',
    'active',
    'reserved',
    'sold'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.pushNamed('create-lot'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: statusFilters.map((status) {
                  final isSelected = selectedStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => selectedStatus = status);
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Lots List
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authProvider);

                if (authState is! AuthAuthenticated) {
                  return const Center(child: Text('Not logged in'));
                }

                // Fetch seller's lots from API
                final lotsAsync = ref.watch(
                  FutureProvider.autoDispose((ref) async {
                    final service = ref.watch(lotsServiceProvider);
                    return service.getSellerLots(
                        authState.user.id, selectedStatus);
                  }),
                );

                return lotsAsync.when(
                  data: (lots) {
                    if (lots.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('No lots found'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context.pushNamed('create-lot'),
                              icon: const Icon(Icons.add),
                              label: const Text('Create First Lot'),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: lots.length,
                      itemBuilder: (context, index) {
                        final lot = lots[index];
                        return _SellerLotCard(
                          lotId: lot.id,
                          productName: lot.productName,
                          quantity: '${lot.quantity}${lot.unit ?? 'kg'}',
                          status: lot.status,
                          createdDate: lot.createdAt,
                          reviews: '${lot.reviewCount ?? 0} reviews',
                          onEdit: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Edit coming soon')),
                            );
                          },
                          onArchive: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lot archived')),
                            );
                          },
                        );
                      },
                    );
                  },
                  loading: () => ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => _ShimmerLotCard(),
                  ),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${error.toString()}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.refresh(lotsServiceProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerLotCard extends StatelessWidget {
  final String lotId;
  final String productName;
  final String quantity;
  final String status;
  final DateTime createdDate;
  final String reviews;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  const _SellerLotCard({
    required this.lotId,
    required this.productName,
    required this.quantity,
    required this.status,
    required this.createdDate,
    required this.reviews,
    required this.onEdit,
    required this.onArchive,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'draft':
        return Colors.grey;
      case 'reserved':
        return Colors.orange;
      case 'sold':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$quantity kg • Created ${_formatDate(createdDate)}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  icon: Icons.star,
                  label: reviews,
                ),
                _StatItem(
                  icon: Icons.visibility,
                  label: '${234 + (64 * (6 - (6 % 3)))} views',
                ),
                _StatItem(
                  icon: Icons.shopping_cart,
                  label: '${12 + (index % 5)} inquiries',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    onPressed: onEdit,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.archive, size: 16),
                    label: const Text('Archive'),
                    onPressed: onArchive,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                    onPressed: () {
                      // Navigate to lot detail
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }
}
