import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/shipment_model.dart';
import '../providers/shipment_provider.dart';

class ShipmentDetailsScreen extends ConsumerStatefulWidget {
  final String shipmentId;

  const ShipmentDetailsScreen({
    Key? key,
    required this.shipmentId,
  }) : super(key: key);

  @override
  ConsumerState<ShipmentDetailsScreen> createState() =>
      _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends ConsumerState<ShipmentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final shipmentAsync = ref.watch(shipmentProvider(widget.shipmentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Details'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Tracking'),
            Tab(text: 'Proof'),
          ],
        ),
      ),
      body: shipmentAsync.when(
        data: (shipment) => TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(context, shipment),
            _buildTrackingTab(context, widget.shipmentId),
            _buildProofTab(context, widget.shipmentId),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text('Error loading shipment'),
              const SizedBox(height: 8),
              Text(error.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(BuildContext context, ShipmentDetailsModel shipment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shipment Status',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shipment.shipmentReference,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(
                                shipment.status.replaceAll('_', ' '),
                              ),
                              backgroundColor: Colors.blue.shade100,
                            ),
                          ],
                        ),
                      ),
                      if (shipment.isDelayed == true)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Delayed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Financial Terms
          _buildSection(
            context,
            'Financial Details',
            [
              _buildDetailRow('Amount', '${shipment.contract.currency} ${shipment.contract.totalValue}'),
              _buildDetailRow('Buyer', shipment.contract.buyer.name),
              _buildDetailRow('Seller', shipment.contract.seller.name),
            ],
          ),
          const SizedBox(height: 16),

          // Location Details
          _buildSection(
            context,
            'Locations',
            [
              _buildDetailRow('Pickup', shipment.pickupLocationName),
              _buildDetailRow('Pickup Date', _formatDate(shipment.pickupDate)),
              _buildDetailRow('Delivery Location', shipment.deliveryLocationName),
              _buildDetailRow(
                'Expected Delivery',
                _formatDate(shipment.expectedDeliveryDate),
              ),
              if (shipment.actualDeliveryDate != null)
                _buildDetailRow(
                  'Actual Delivery',
                  _formatDate(shipment.actualDeliveryDate!),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Logistics Details
          if (shipment.driver != null)
            _buildSection(
              context,
              'Driver & Vehicle',
              [
                _buildDetailRow('Driver', shipment.driver!.name),
                _buildDetailRow('Phone', shipment.driver!.phone),
                if (shipment.vehicleRegistration != null)
                  _buildDetailRow('Vehicle', shipment.vehicleRegistration!),
              ],
            ),
          const SizedBox(height: 16),

          // Delivery Instructions
          if (shipment.recipientName != null || shipment.specialHandlingInstructions != null)
            _buildSection(
              context,
              'Delivery Instructions',
              [
                if (shipment.recipientName != null)
                  _buildDetailRow('Recipient', shipment.recipientName!),
                if (shipment.recipientPhone != null)
                  _buildDetailRow('Recipient Phone', shipment.recipientPhone!),
                if (shipment.requiresSignature == true)
                  _buildDetailRow('Signature Required', 'Yes'),
                if (shipment.specialHandlingInstructions != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Instructions'),
                      const SizedBox(height: 4),
                      Text(
                        shipment.specialHandlingInstructions!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ],
                  ),
              ],
            ),
          const SizedBox(height: 16),

          // Summary Statistics
          if (shipment.daysInTransit != null)
            _buildSection(
              context,
              'Statistics',
              [
                _buildDetailRow('Days in Transit', '${shipment.daysInTransit}'),
                _buildDetailRow('Delivery Proofs', '${shipment.deliveryProofCount ?? 0}'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTrackingTab(BuildContext context, String shipmentId) {
    final trackingAsync = ref.watch(trackingHistoryProvider(shipmentId));

    return trackingAsync.when(
      data: (trackingEvents) {
        if (trackingEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text('No tracking updates yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: trackingEvents.length,
          itemBuilder: (context, index) {
            final event = trackingEvents[index];
            final isFirst = index == 0;

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        if (!isFirst)
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.blue.shade200,
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.eventType.replaceAll('_', ' '),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.message,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          if (event.locationName != null)
                            Text(
                              event.locationName!,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                          Text(
                            _formatDate(event.createdAt),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildProofTab(BuildContext context, String shipmentId) {
    final proofsAsync = ref.watch(deliveryProofsProvider(shipmentId));

    return proofsAsync.when(
      data: (proofs) {
        if (proofs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text('No delivery proofs yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: proofs.length,
          itemBuilder: (context, index) {
            final proof = proofs[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          proof.proofType.replaceAll('_', ' '),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        if (proof.isVerified)
                          Chip(
                            label: const Text('Verified'),
                            backgroundColor: Colors.green.shade100,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(proof.description),
                    const SizedBox(height: 8),
                    if (proof.recipientName != null)
                      Text('Recipient: ${proof.recipientName}'),
                    if (proof.dataBlobUrl != null && proof.dataBlobUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: proof.dataBlobUrl!.startsWith('data:image')
                              ? Image.memory(
                                  _dataUrlToBytes(proof.dataBlobUrl!),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  proof.dataBlobUrl!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(proof.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  List<int> _dataUrlToBytes(String dataUrl) {
    final base64String = dataUrl.split(',').last;
    return base64Decode(base64String);
  }
}

import 'dart:convert';
