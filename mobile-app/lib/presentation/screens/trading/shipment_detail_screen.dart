import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShipmentDetailScreen extends StatelessWidget {
  const ShipmentDetailScreen({super.key, required this.shipmentId});
  final String shipmentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipment details')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('shipments')
            .doc(shipmentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Shipment activity could not be refreshed.'),
            );
          }
          final shipment = snapshot.data?.data();
          if (shipment == null) {
            return const Center(child: Text('Shipment not found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _section(
                context,
                'Current status',
                (shipment['status'] ?? 'pending')
                    .toString()
                    .replaceAll('_', ' ')
                    .toUpperCase(),
                Icons.local_shipping_outlined,
              ),
              _section(
                context,
                'Tracking number',
                shipment['trackingNumber'] ??
                    shipment['shipmentReference'] ??
                    'Not assigned',
                Icons.qr_code_2,
              ),
              _section(
                context,
                'Origin',
                shipment['pickupLocationName'] ??
                    shipment['origin'] ??
                    'Not assigned',
                Icons.trip_origin,
              ),
              _section(
                context,
                'Destination',
                shipment['deliveryLocationName'] ??
                    shipment['destination'] ??
                    'Not assigned',
                Icons.location_on_outlined,
              ),
              _section(
                context,
                'Carrier',
                shipment['carrierName'] ?? 'Not assigned',
                Icons.business_outlined,
              ),
              _section(
                context,
                'Live telemetry',
                shipment['telemetryEnabled'] == true
                    ? 'Enabled'
                    : 'No verified telemetry feed',
                Icons.sensors,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _section(
          BuildContext context, String label, dynamic value, IconData icon) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: .96, end: 1),
        duration: const Duration(milliseconds: 240),
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Card(
          child: ListTile(
            leading: Icon(icon),
            title: Text(label),
            subtitle: Text(value.toString()),
          ),
        ),
      );
}
