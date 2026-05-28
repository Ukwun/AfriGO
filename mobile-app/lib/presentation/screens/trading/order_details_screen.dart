import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/order_model.dart';
import '../../models/user_data_model.dart';
import '../../services/api_service.dart';

final orderDetailProvider = FutureProvider.autoDispose<OrderModel>(
  (ref) async {
    // Will be overridden with orderId
    throw UnimplementedError();
  },
);

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({required this.orderId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(
      orderDetailProvider.overrideWithValue(
        FutureProvider.autoDispose<OrderModel>((ref) async {
          final apiService = ref.watch(apiServiceProvider);
          return apiService.getOrderById(orderId);
        }).future,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        elevation: 0,
      ),
      body: orderAsync.when(
        data: (order) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order header
              _buildOrderHeader(context, order),
              const SizedBox(height: 24),

              // Product details section
              _buildSectionTitle(context, 'Product Details'),
              _buildProductDetails(context, order),
              const SizedBox(height: 24),

              // Pricing breakdown
              _buildSectionTitle(context, 'Price Breakdown'),
              _buildPricingBreakdown(context, order),
              const SizedBox(height: 24),

              // Parties information
              _buildSectionTitle(context, 'Party Information'),
              if (order.buyer != null)
                _buildUserCard(context, 'Buyer', order.buyer!),
              const SizedBox(height: 12),
              if (order.seller != null)
                _buildUserCard(context, 'Seller', order.seller!),
              const SizedBox(height: 24),

              // Timeline
              _buildSectionTitle(context, 'Order Timeline'),
              _buildTimeline(context, order),
              const SizedBox(height: 24),

              // Ratings (if order is delivered or completed)
              if (order.status == 'delivered' ||
                  order.status == 'completed') ...[
                _buildSectionTitle(context, 'Ratings & Reviews'),
                _buildRatingsSection(context, order),
                const SizedBox(height: 24),
              ],

              // Action buttons
              _buildActionButtons(context, ref, order),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text('Failed to load order: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context, OrderModel order) {
    final statusColor = _getStatusColor(order.status);
    final statusLabel = _getStatusLabel(order.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created ${_formatDate(order.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, OrderModel order) {
    final lot = order.lot;
    if (lot == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lot.productImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  lot.productImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              lot.productName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${order.quantity.toStringAsFixed(2)} ${order.quantityUnit}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Price per Unit',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${order.pricePerUnit.toStringAsFixed(2)} NGN',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildPricingBreakdown(BuildContext context, OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPricingRow(
              context,
              'Subtotal',
              order.totalPrice,
              isBold: false,
            ),
            const Divider(height: 16),
            _buildPricingRow(
              context,
              'Total',
              order.totalPrice,
              isBold: true,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingRow(
    BuildContext context,
    String label,
    double amount, {
    bool isBold = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          '${amount.toStringAsFixed(2)} NGN',
          style: isBold
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  )
              : Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, String title, UserData user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (user.phoneNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(user.phoneNumber!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, OrderModel order) {
    final events = <MapEntry<String, DateTime?>>[
      if (order.confirmedAt != null)
        MapEntry('Order Confirmed', order.confirmedAt!),
      if (order.paidAt != null) MapEntry('Payment Made', order.paidAt!),
      if (order.shippedAt != null) MapEntry('Shipped', order.shippedAt!),
      if (order.deliveredAt != null) MapEntry('Delivered', order.deliveredAt!),
      if (order.completedAt != null) MapEntry('Completed', order.completedAt!),
    ];

    if (events.isEmpty) {
      return Text(
        'No timeline events yet',
        style: Theme.of(context).textTheme.bodySmall,
      );
    }

    return Column(
      children: List.generate(events.length, (index) {
        final event = events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  if (index < events.length - 1)
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.green.withOpacity(0.3),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.key,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _formatDate(event.value),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRatingsSection(BuildContext context, OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (order.sellerRating != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Rating of Seller',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < order.sellerRating!
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  if (order.sellerReview != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      order.sellerReview!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              )
            else
              FilledButton(
                onPressed: () {
                  // Open rating dialog
                },
                child: const Text('Rate Seller'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) {
    return Column(
      children: [
        if (order.status == 'pending')
          FilledButton(
            onPressed: () {
              // Confirm order
            },
            child: const Text('Confirm Order'),
          ),
        if (order.status == 'quoted')
          FilledButton(
            onPressed: () => context.push('/orders/${order.id}/quotes'),
            child: const Text('View & Accept Quotes'),
          ),
        if (order.status == 'shipped')
          FilledButton(
            onPressed: () {
              // Confirm delivery
            },
            child: const Text('Confirm Delivery'),
          ),
        if (order.status != 'completed' && order.status != 'cancelled')
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: OutlinedButton(
              onPressed: () {
                // Cancel order
              },
              child: const Text('Cancel Order'),
            ),
          ),
      ],
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
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
