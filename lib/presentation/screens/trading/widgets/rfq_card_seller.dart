import 'package:flutter/material.dart';
import '../../../../domain/models/trade.dart';

/// RFQ Card for Seller View
/// Displays RFQ details with seller-specific info
class RFQCardSeller extends StatelessWidget {
  final Trade rfq;
  final VoidCallback onTap;
  final VoidCallback? onSubmitBid;
  final VoidCallback? onViewBid;

  const RFQCardSeller({
    Key? key,
    required this.rfq,
    required this.onTap,
    this.onSubmitBid,
    this.onViewBid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasBid = onViewBid != null;
    final buyerTrustScore = 3.8; // Would come from buyer data

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rfq.productType,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${rfq.quantity.toStringAsFixed(0)}kg @ \$${rfq.offeredPrice.toStringAsFixed(2)}/kg',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: hasBid ? Colors.green[100] : Colors.blue[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          hasBid ? 'I Quoted' : 'Open',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: hasBid
                                ? Colors.green[900]
                                : Colors.blue[900],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Posted ${_daysAgo(rfq.createdAt)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Buyer info
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Buyer',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          rfq.buyerName ?? 'Buyer',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              size: 12,
                              color:
                                  i <
                                      buyerTrustScore
                                          .floor() // Simplified, would use real trust score
                                  ? Colors.amber
                                  : Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${buyerTrustScore.toStringAsFixed(1)}★',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Delivery info
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Delivery: ${rfq.deliveryDate?.toString().split(" ")[0] ?? "TBD"}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    rfq.deliveryLocation ?? 'TBD',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTap,
                      child: const Text(
                        'View Details',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (onSubmitBid != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onSubmitBid,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Quote Now',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  if (onViewBid != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onViewBid,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'View My Quote',
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

  String _daysAgo(DateTime date) {
    final difference = DateTime.now().difference(date).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return '$difference days ago';
  }
}
