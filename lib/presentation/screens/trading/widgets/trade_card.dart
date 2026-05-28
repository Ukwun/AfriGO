import 'package:flutter/material.dart';
import '../../../../domain/models/trade.dart';

/// Trade Card Widget
/// Displays trade/RFQ in list view with status, bids count, and actions
class TradeCard extends StatelessWidget {
  final Trade trade;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const TradeCard({
    Key? key,
    required this.trade,
    required this.onTap,
    this.onAccept,
    this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(trade.status);
    final riskLevel = trade.fraudScore ?? 0;
    final isHighRisk = riskLevel > 70;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Product type and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trade.productType,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created ${trade.createdAt.difference(DateTime.now()).inDays.abs()} days ago',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trade.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Terms: Quantity and price
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Qty',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        Text(
                          '${trade.quantity.toStringAsFixed(0)}kg',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Max Price',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        Text(
                          '\$${trade.offeredPrice.toStringAsFixed(2)}/kg',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                        Text(
                          trade.deliveryDate.toString().split(' ')[0],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Quotes count and fraud risk
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bids count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(trade.bids ?? []).length} quotes',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),

                  // Fraud risk
                  if (isHighRisk)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning,
                            size: 12,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'High Risk',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Action buttons (if applicable)
              if (onAccept != null || onReject != null)
                Row(
                  children: [
                    if (onReject != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    if (onReject != null && onAccept != null)
                      const SizedBox(width: 8),
                    if (onAccept != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text(
                            'Accept Best',
                            style: TextStyle(fontSize: 12),
                          ),
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

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return Colors.blue;
      case 'NEGOTIATING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
