import 'package:flutter/material.dart';
import '../../../../domain/models/trade.dart';

/// Bid Card Widget
/// Displays seller quote/bid with price, delivery info, and seller trust score
class BidCard extends StatelessWidget {
  final Bid bid;
  final VoidCallback? onAccept;
  final VoidCallback? onCounter;

  const BidCard({Key? key, required this.bid, this.onAccept, this.onCounter})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(bid.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seller info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bid.sellerName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${bid.sellerTrustScore?.toStringAsFixed(1) ?? "N/A"}/5.0',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${bid.sellerCompletedTrades ?? 0} trades',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    bid.status,
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

            // Price and terms
            Container(
              padding: const EdgeInsets.all(12),
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
                      const Text('Price', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        '\$${bid.offeredPrice.toStringAsFixed(2)}/kg',
                        style: const TextStyle(
                          fontSize: 16,
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
                        'Quantity',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${bid.quantity.toStringAsFixed(0)}kg',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bid.estimatedDeliveryDays.toString() + ' days',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Quality info
            Row(
              children: [
                const Icon(Icons.verified, size: 14, color: Colors.teal),
                const SizedBox(width: 6),
                Text(
                  'Quality: ${bid.qualityGrade}',
                  style: const TextStyle(fontSize: 12),
                ),
                if (bid.sellerKycVerified == true) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.check_circle, size: 14, color: Colors.green),
                  const SizedBox(width: 6),
                  const Text(
                    'KYC Verified',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            if (bid.status == 'PENDING')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCounter,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Counter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              )
            else if (bid.status == 'ACCEPTED')
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Quote Accepted - Proceeding to Payment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.blue;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'COUNTERED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
