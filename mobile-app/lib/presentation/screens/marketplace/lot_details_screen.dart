import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/lot_model.dart';
import '../../../services/api_service.dart';
import '../../../config/theme.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/motion_system.dart';

final lotDetailsProvider =
    FutureProvider.family<LotModel, String>((ref, lotId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getLotById(lotId);
});

class LotDetailsScreen extends ConsumerWidget {
  final String lotId;

  const LotDetailsScreen({super.key, required this.lotId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotAsync = ref.watch(lotDetailsProvider(lotId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lot Details'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: lotAsync.when(
        data: (lot) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Gallery
              _buildImageGallery(lot),

              // Product Info Card
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name and status
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
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lot.category ?? 'General',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(lot.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            lot.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Price and Quantity
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Price per Unit'),
                              Text(
                                '\$${lot.pricePerUnit.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Quantity Available'),
                              Text(
                                '${lot.quantity.toStringAsFixed(0)} ${lot.quantityUnit}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Value (approx)'),
                              Text(
                                '\$${(lot.pricePerUnit * lot.quantity).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lot.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Certifications
                    if (lot.certifications.isNotEmpty) ...[
                      const Text(
                        'Certifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: lot.certifications
                            .map((cert) => Chip(
                                  label: Text(cert),
                                  backgroundColor: Colors.green[100],
                                  labelStyle: const TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Location
                    const Text(
                      'Pickup Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lot.pickupLocation,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Seller Info Card
                    _buildSellerCard(lot),

                    const SizedBox(height: 20),

                    // QR Code (if available)
                    if (lot.qrCode != null) ...[
                      const Text(
                        'QR Code for Verification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Placeholder for QR code (in production, generate from lot.qrCode)
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border:
                                    Border.all(color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  lot.qrCode!.substring(0, 8),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Courier',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Code: ${lot.qrCode}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // View count and rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.visibility, size: 16),
                            const SizedBox(width: 4),
                            Text('${lot.viewCount} views'),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${lot.averageRating.toStringAsFixed(1)} (${lot.ratingCount} ratings)',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
            ],
          ),
        ),
        loading: () => PageSkeletonLoader(
          elements: [
            SkeletonElement(type: SkeletonType.card, height: 250),
            SkeletonElement(type: SkeletonType.card, height: 120),
            SkeletonElement(type: SkeletonType.card, height: 100),
          ],
        ),
      ),
      bottomNavigationBar:
          lotAsync.whenData((lot) => _buildActionBar(context, lot)).value,
    );
  }

  Widget _buildImageGallery(LotModel lot) {
    if (lot.images.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: lot.images.length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey[200],
            child: Image.network(
              lot.images[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image_not_supported,
                      size: 64, color: Colors.grey),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSellerCard(LotModel lot) {
    return ModernCard(
      borderRadius: 16,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Seller Avatar
            CircleAvatar(
              backgroundColor: AppTheme.primaryGreen,
              radius: 28,
              child: Text(
                (lot.sellerName ?? 'S')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lot.sellerName ?? 'Unknown Seller',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Sora',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${lot.sellerRating?.toStringAsFixed(1) ?? "4.5"} (8 reviews)',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _buildActionBar(BuildContext context, LotModel lot) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Share/Message - Secondary outlined button
          Expanded(
            child: AnimatedOutlinedButton(
              label: 'Share',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing lot...')),
                );
              },
              borderColor: AppTheme.primaryGreen,
              textColor: AppTheme.primaryGreen,
              isLargeTouchTarget: true,
            ),
          ),
          const SizedBox(width: 12),
          // Request Quote - Primary button
          Expanded(
            child: AnimatedPrimaryButton(
              label: 'Request Quote',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Requesting quote from seller...')),
                );
              },
              isLargeTouchTarget: true,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'sold':
        return Colors.grey;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
