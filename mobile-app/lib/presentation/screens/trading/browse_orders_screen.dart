import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';

// Orders list provider
final ordersProvider =
    FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getOrders();
});

// Buyer orders provider
final buyerOrdersProvider =
    FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMyBuyerOrders();
});

// Seller orders provider
final sellerOrdersProvider =
    FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getMySellerOrders();
});

// Selected order type filter provider
final orderTypeFilterProvider = StateProvider<String>((ref) => 'all');

class BrowseOrdersScreen extends ConsumerWidget {
  const BrowseOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterType = ref.watch(orderTypeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Filter pills
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterPill(
                    context,
                    ref,
                    'All',
                    'all',
                    filterType == 'all',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    context,
                    ref,
                    'Buying',
                    'buyer',
                    filterType == 'buyer',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    context,
                    ref,
                    'Selling',
                    'seller',
                    filterType == 'seller',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    context,
                    ref,
                    'Pending',
                    'pending',
                    filterType == 'pending',
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    context,
                    ref,
                    'Completed',
                    'completed',
                    filterType == 'completed',
                  ),
                ],
              ),
            ),
          ),
          // Orders list
          Expanded(
            child: _buildOrdersList(context, ref, filterType),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(
    BuildContext context,
    WidgetRef ref,
    String label,
    String value,
    bool isActive,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (selected) {
        ref.read(orderTypeFilterProvider.notifier).state = value;
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.green,
      labelStyle: TextStyle(
        color: isActive ? Colors.white : Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildOrdersList(
      BuildContext context, WidgetRef ref, String filterType) {
    final ordersAsync = ref.watch(ordersProvider);

    return ordersAsync.when(
      data: (allOrders) {
        final filteredOrders = _filterOrders(allOrders, filterType);

        if (filteredOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];
            return _buildOrderCard(context, order);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error: ${error.toString()}'),
      ),
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders, String filterType) {
    switch (filterType) {
      case 'buyer':
        return orders;
      case 'seller':
        return orders;
      case 'pending':
        return orders.where((o) => o.status == 'pending').toList();
      case 'completed':
        return orders
            .where((o) => o.status == 'delivered' || o.status == 'completed')
            .toList();
      default:
        return orders;
    }
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Product info
              Text(
                order.productName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Quantity and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.quantity} ${order.quantityUnit}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '\$${order.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Other party and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'with ${order.sellerName ?? 'Seller'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'disputed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class OrderCard extends ConsumerWidget {
  final OrderModel order;

  const OrderCard({required this.order, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = _getStatusColor(order.status);
    final statusLabel = _getStatusLabel(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(0, 8)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Product info
              if (order.lot != null)
                Text(
                  order.lot!.productName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 8),

              // Quantity and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Qty: ${order.quantity.toStringAsFixed(1)} ${order.quantityUnit}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${order.totalPrice.toStringAsFixed(2)} NGN',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Seller info
              if (order.seller != null)
                Row(
                  children: [
                    const Icon(Icons.store, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.seller!.fullName,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => context.push('/orders/${order.id}'),
                    label: const Text('View Details'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                  ),
                  if (order.status == 'quoted')
                    FilledButton(
                      onPressed: () =>
                          context.push('/orders/${order.id}/quotes'),
                      child: const Text('View Quotes'),
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
      case 'quoted':
        return Colors.blue;
      case 'confirmed':
        return Colors.purple;
      case 'paid':
        return Colors.teal;
      case 'shipped':
        return Colors.cyan;
      case 'delivered':
        return Colors.green;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'disputed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'quoted':
        return 'Quoted';
      case 'confirmed':
        return 'Confirmed';
      case 'paid':
        return 'Paid';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'disputed':
        return 'Disputed';
      default:
        return status;
    }
  }
}
