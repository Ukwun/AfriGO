import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/shipment_model.dart';

part 'shipment_provider.freezed.dart';

// Mock Shipment data provider
final shipmentListProvider = FutureProvider<List<ShipmentModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));

  return [
    ShipmentModel(
      id: 'ship-001',
      shipmentReference: 'SHIP-2026-0001',
      status: 'in_transit',
      transportMode: 'Sea',
      pickupLocationName: 'Kumasi Port, Ghana',
      deliveryLocationName: 'Port of Lagos, Nigeria',
      pickupDate: DateTime.now().subtract(const Duration(days: 3)),
      expectedDeliveryDate: DateTime.now().add(const Duration(days: 5)),
      actualDeliveryDate: null,
      daysInTransit: 3,
      isDelayed: false,
      driver: const DriverModel(
        id: 'driver-001',
        firstName: 'Kwasi',
        lastName: 'Mensah',
        email: 'kwasi@logistics.com',
        phone: '+233501234567',
        licenseNumber: 'GHA-LIC-12345',
      ),
      vehicleRegistration: 'GH-12-A-1234',
      trackingUrl: 'https://tracking.afrigo.com/ship-001',
      deliveryProofCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
    ShipmentModel(
      id: 'ship-002',
      shipmentReference: 'SHIP-2026-0002',
      status: 'delivered',
      transportMode: 'Air',
      pickupLocationName: 'Accra International Airport',
      deliveryLocationName: 'Johannesburg, South Africa',
      pickupDate: DateTime.now().subtract(const Duration(days: 7)),
      expectedDeliveryDate: DateTime.now().subtract(const Duration(days: 2)),
      actualDeliveryDate: DateTime.now().subtract(const Duration(days: 2)),
      daysInTransit: 5,
      isDelayed: false,
      driver: null,
      vehicleRegistration: null,
      trackingUrl: 'https://tracking.afrigo.com/ship-002',
      deliveryProofCount: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ShipmentModel(
      id: 'ship-003',
      shipmentReference: 'SHIP-2026-0003',
      status: 'pending',
      transportMode: 'Land',
      pickupLocationName: 'Ouagadougou, Burkina Faso',
      deliveryLocationName: 'Abidjan, Ivory Coast',
      pickupDate: DateTime.now().add(const Duration(days: 2)),
      expectedDeliveryDate: DateTime.now().add(const Duration(days: 4)),
      actualDeliveryDate: null,
      daysInTransit: null,
      isDelayed: false,
      driver: null,
      vehicleRegistration: null,
      trackingUrl: 'https://tracking.afrigo.com/ship-003',
      deliveryProofCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
});

// Provider for detailed shipment view
final shipmentDetailProvider =
    FutureProvider.family<ShipmentModel, String>((ref, shipmentId) async {
  final list = await ref.watch(shipmentListProvider.future);
  return list.firstWhere((ship) => ship.id == shipmentId);
});

// Provider to track active shipments (in transit or pending)
final activeShipmentsProvider =
    FutureProvider<List<ShipmentModel>>((ref) async {
  final list = await ref.watch(shipmentListProvider.future);
  return list
      .where((ship) => ship.status == 'in_transit' || ship.status == 'pending')
      .toList();
});

// Provider for shipment timeline/history
final shipmentTimelineProvider =
    FutureProvider.family<List<ShipmentEventModel>, String>(
        (ref, shipmentId) async {
  await Future.delayed(const Duration(milliseconds: 200));

  return [
    ShipmentEventModel(
      id: 'event-001',
      shipmentId: shipmentId,
      eventType: 'pickup',
      title: 'Package picked up',
      description: 'Shipment collected from Kumasi Port',
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      location: 'Kumasi Port, Ghana',
      status: 'completed',
    ),
    ShipmentEventModel(
      id: 'event-002',
      shipmentId: shipmentId,
      eventType: 'in_transit',
      title: 'En route to Lagos',
      description: 'Shipment is currently in transit by sea vessel',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      location: 'Gulf of Guinea',
      status: 'completed',
    ),
    ShipmentEventModel(
      id: 'event-003',
      shipmentId: shipmentId,
      eventType: 'delay_alert',
      title: 'Minor weather delay',
      description: 'Slight delay due to sea conditions',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      location: 'Gulf of Guinea',
      status: 'active',
    ),
    ShipmentEventModel(
      id: 'event-004',
      shipmentId: shipmentId,
      eventType: 'destination',
      title: 'Arriving soon',
      description: 'Expected arrival in Lagos in 5 hours',
      timestamp: DateTime.now().add(const Duration(hours: 5)),
      location: 'Port of Lagos, Nigeria',
      status: 'pending',
    ),
  ];
});

// Shipment event model for timeline
@freezed
class ShipmentEventModel with _$ShipmentEventModel {
  const factory ShipmentEventModel({
    required String id,
    required String shipmentId,
    required String eventType,
    required String title,
    required String description,
    required DateTime timestamp,
    required String location,
    required String status,
  }) = _ShipmentEventModel;
}
