import 'package:flutter/material.dart';
import '../../../../domain/models/lot.dart';

/// Lot Card Widget
/// Displays lot information in list view
class LotCard extends StatelessWidget {
  final Lot lot;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LotCard({
    Key? key,
    required this.lot,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Status color coding
    final statusColor = _getStatusColor(lot.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            SizedBox(
              height: 180,
              width: double.infinity,
              child: lot.photoUrls.isNotEmpty
                  ? Image.network(
                      lot.photoUrls[0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 48),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
            ),
            // Lot details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lot.productName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lot.qualityGrade,
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
                          Text(
                            '\$${lot.price.toStringAsFixed(2)}/kg',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            '${lot.quantity.toStringAsFixed(0)}kg',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                      lot.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Meta info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Posted ${lot.createdAt.difference(DateTime.now()).inDays.abs()} days ago',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      if ((lot.bids ?? []).isNotEmpty)
                        Text(
                          '${lot.bids!.length} bid${lot.bids!.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action buttons
                  Row(
                    children: [
                      if (lot.status == 'CREATED' || lot.status == 'LISTED')
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 14),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 14),
                          label: const Text('Delete'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
      case 'CREATED':
        return Colors.blue;
      case 'LISTED':
        return Colors.green;
      case 'RESERVED':
        return Colors.orange;
      case 'SOLD':
        return Colors.purple;
      case 'IN_TRANSIT':
        return Colors.cyan;
      case 'DELIVERED':
        return Colors.teal;
      case 'ARCHIVED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
