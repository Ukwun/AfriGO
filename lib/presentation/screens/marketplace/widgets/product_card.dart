import 'package:flutter/material.dart';
import '../../../../domain/models/lot.dart';

/// Product Card Widget
/// Displays product information in list view
class ProductCard extends StatelessWidget {
  final Lot lot;
  final VoidCallback onTap;
  final VoidCallback onMakeOffer;

  const ProductCard({
    Key? key,
    required this.lot,
    required this.onTap,
    required this.onMakeOffer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Color-code fraud risk (REAL fraud detection score)
    final fraudColor = lot.fraudRiskScore == null
        ? Colors.grey
        : lot.fraudRiskScore! < 50
        ? Colors.green
        : lot.fraudRiskScore! < 70
        ? Colors.orange
        : Colors.red;

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
            // Product details
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
                              lot.location ?? 'Unknown location',
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
                  // Seller info and trust score (REAL trust score)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: lot.sellerAvatarUrl != null
                                  ? NetworkImage(lot.sellerAvatarUrl!)
                                  : null,
                              child: lot.sellerAvatarUrl == null
                                  ? const Icon(Icons.person, size: 12)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lot.sellerName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      // REAL trust score with stars
                                      Text(
                                        '${lot.sellerTrustScore!.toStringAsFixed(1)}★',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${lot.sellerCompletedTrades ?? 0} trades',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
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
                      // Fraud risk indicator (color-coded)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: fraudColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          lot.fraudRiskScore == null
                              ? '?'
                              : lot.fraudRiskScore! < 50
                              ? '🟢'
                              : lot.fraudRiskScore! < 70
                              ? '🟡'
                              : '🔴',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Quality grade and badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(
                          'Grade: ${lot.qualityGrade}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        side: const BorderSide(color: Colors.green),
                      ),
                      if (lot.sellerKycVerified ?? false)
                        const Chip(
                          label: Text(
                            '✓ Verified',
                            style: TextStyle(fontSize: 11),
                          ),
                          backgroundColor: Color(0xFFE8F5E9),
                          side: BorderSide(color: Colors.green),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // [MAKE OFFER] button - FUNCTIONAL
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onMakeOffer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Make Offer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
