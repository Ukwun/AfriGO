import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/lots_model.dart';
import '../../providers/lots_provider.dart';

class SellerProfileScreen extends ConsumerStatefulWidget {
  final String? supplierId;

  const SellerProfileScreen({
    super.key,
    this.supplierId,
  });

  @override
  ConsumerState<SellerProfileScreen> createState() =>
      _SellerProfileScreenState();
}

class _SellerProfileScreenState extends ConsumerState<SellerProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // For now, showing current seller's profile
    // In future: can show other suppliers' profiles (public view)

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile edit coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(24),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'John Osei',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cocoa & Coffee Supplier',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatCard(label: 'Products', value: '12'),
                      _StatCard(label: 'Transactions', value: '48'),
                      _StatCard(label: 'Rating', value: '4.8★'),
                      _StatCard(label: 'Trust', value: '92'),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Create Lot'),
                          onPressed: () => context.pushNamed('create-lot'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text('Messages'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Messages coming soon')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Business Info
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.location_on,
                    title: 'Location',
                    subtitle: 'Ashanti Region, Ghana',
                  ),
                  _InfoCard(
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: 'john.osei@example.com',
                  ),
                  _InfoCard(
                    icon: Icons.phone,
                    title: 'Phone',
                    subtitle: '+233 24 123 4567',
                  ),
                  _InfoCard(
                    icon: Icons.badge,
                    title: 'Business ID',
                    subtitle: 'GH-2024-001234',
                  ),
                  _InfoCard(
                    icon: Icons.verified,
                    title: 'Verification Status',
                    subtitle: 'Verified ✓',
                    subtitleColor: Colors.green,
                  ),
                ],
              ),
            ),

            // Products Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Listings',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => context.pushNamed('seller-lots'),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _ActiveListingsList(),
                ],
              ),
            ),

            // Certifications
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Certifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _CertificationChip(label: 'Rainforest Alliance'),
                      _CertificationChip(label: 'Fair Trade'),
                      _CertificationChip(label: 'Organic'),
                      _CertificationChip(label: 'ISO 9001'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color subtitleColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 16,
                      color: subtitleColor,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveListingsList extends ConsumerWidget {
  const _ActiveListingsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In real implementation: fetch lots for current seller
    return const Column(
      children: [
        _LotPreviewCard(
          name: 'Grade A Cocoa Beans',
          quantity: '500 kg',
          price: '₵45/kg',
          status: 'Active',
        ),
        _LotPreviewCard(
          name: 'Premium Arabica Coffee',
          quantity: '200 kg',
          price: '₵85/kg',
          status: 'Active',
        ),
        _LotPreviewCard(
          name: 'Cashew Nuts',
          quantity: '300 kg',
          price: '₵95/kg',
          status: 'Reserved',
          statusColor: Colors.orange,
        ),
      ],
    );
  }
}

class _LotPreviewCard extends StatelessWidget {
  final String name;
  final String quantity;
  final String price;
  final String status;
  final Color statusColor;

  const _LotPreviewCard({
    required this.name,
    required this.quantity,
    required this.price,
    required this.status,
    this.statusColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$quantity @ $price',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificationChip extends StatelessWidget {
  final String label;

  const _CertificationChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      icon: const Icon(Icons.verified, size: 16),
      label: Text(label),
      backgroundColor: Colors.blue.shade50,
    );
  }
}
