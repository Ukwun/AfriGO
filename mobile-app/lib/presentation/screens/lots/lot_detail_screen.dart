import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/lots_model.dart';
import '../providers/lots_provider.dart';

class LotDetailScreen extends ConsumerWidget {
  final String lotId;

  const LotDetailScreen({Key? key, required this.lotId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotAsync = ref.watch(lotDetailProvider(lotId));
    final traceabilityAsync = ref.watch(lotTraceabilityProvider(lotId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Product Details'),
        elevation: 0,
      ),
      body: lotAsync.when(
        data: (lot) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image carousel
                _buildImageCarousel(lot),
                // Basic info
                _buildBasicInfo(lot),
                // Quality info
                _buildQualityInfo(lot),
                // Location & Origin
                _buildLocationInfo(lot),
                // Traceability
                _buildTraceability(traceabilityAsync),
                // Seller info
                _buildSellerInfo(lot),
                // Action buttons
                _buildActionButtons(context, lot),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(LotModel lot) {
    if (lot.images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64),
        ),
      );
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 300,
        enlargeCenterPage: true,
        autoPlay: true,
      ),
      items: lot.images
          .map((image) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(image, fit: BoxFit.cover),
              ))
          .toList(),
    );
  }

  Widget _buildBasicInfo(LotModel lot) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lot.productName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(label: Text(lot.category)),
                  Chip(label: Text('Grade ${lot.gradeLevel}')),
                  Chip(label: Text(lot.status.toUpperCase())),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Price', style: TextStyle(color: Colors.grey)),
                      Text(
                        '\$${lot.pricePerUnit.toStringAsFixed(2)}/${lot.quantityUnit}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Available',
                          style: TextStyle(color: Colors.grey)),
                      Text(
                        '${(lot.quantity - lot.quantityReserved).toInt()} ${lot.quantityUnit}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(lot.description),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQualityInfo(LotModel lot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quality Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildQualityRow('Grade Level', lot.gradeLevel),
              if (lot.moistureContent != null)
                _buildQualityRow('Moisture Content', '${lot.moistureContent}%'),
              if (lot.afflatoxinLevel != null)
                _buildQualityRow(
                    'Aflatoxin Level', '${lot.afflatoxinLevel} PPM'),
              if (lot.foreignMatterPercentage != null)
                _buildQualityRow(
                    'Foreign Matter', '${lot.foreignMatterPercentage}%'),
              if (lot.certifications.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Certifications:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: lot.certifications
                      .map((cert) => Chip(label: Text(cert)))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQualityRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(LotModel lot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Origin & Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildLocationRow('Batch Number', lot.batchNumber),
              _buildLocationRow('Origin Country', lot.originCountry),
              if (lot.originRegion != null)
                _buildLocationRow('Region', lot.originRegion!),
              if (lot.harvestDate != null)
                _buildLocationRow(
                  'Harvest Date',
                  DateFormat('MMM dd, yyyy').format(lot.harvestDate!),
                ),
              if (lot.expiryDate != null)
                _buildLocationRow(
                  'Expiry Date',
                  DateFormat('MMM dd, yyyy').format(lot.expiryDate!),
                ),
              const SizedBox(height: 12),
              Text('Pickup: ${lot.pickupLocation}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTraceability(
      AsyncValue<List<LotTraceabilityModel>> traceabilityAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Traceability History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              traceabilityAsync.when(
                data: (events) {
                  return Column(
                    children: events
                        .map((event) => _buildTraceabilityEvent(event))
                        .toList(),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error loading traceability: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTraceabilityEvent(LotTraceabilityModel event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.eventType.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('MMM dd, yyyy • HH:mm').format(event.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (event.description != null) Text(event.description!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo(LotModel lot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            child: Text(lot.seller.firstName?[0] ?? 'S'),
          ),
          title: Text('${lot.seller.firstName} ${lot.seller.lastName}'.trim()),
          subtitle: Text(lot.seller.email),
          trailing: ElevatedButton(
            onPressed: () {
              // Open chat with seller
            },
            child: const Text('Message'),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, LotModel lot) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.favorite_border),
              label: const Text('Favorite'),
              onPressed: () {
                // Add to favorites
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Make Offer'),
              onPressed: () {
                // Create RFQ
              },
            ),
          ),
        ],
      ),
    );
  }
}
