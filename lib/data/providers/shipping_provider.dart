import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/shipping_service.dart';

/// Shipment detail provider
/// Real-time updates via WebSocket for GPS, temperature, status
final shipmentDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((
      ref,
      shipmentId,
    ) async {
      final shippingService = ref.watch(shippingServiceProvider);
      return await shippingService.getShipment(shipmentId);
    });

/// Shipment events provider
/// Immutable activity log - all status changes, GPS updates, temperature readings
final shipmentEventsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      shipmentId,
    ) async {
      final shippingService = ref.watch(shippingServiceProvider);
      return await shippingService.getShipmentEvents(shipmentId);
    });

/// Shipment for trade provider
/// Get shipment associated with a specific trade
final shipmentForTradeProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, tradeId) async {
      final shippingService = ref.watch(shippingServiceProvider);
      return await shippingService.getShipmentByTrade(tradeId);
    });

/// Delivery proof provider
/// Get immutable proof of delivery with photos and GPS
final deliveryProofProvider =
    FutureProvider.family<Map<String, dynamic>, String>((
      ref,
      shipmentId,
    ) async {
      final shippingService = ref.watch(shippingServiceProvider);
      return await shippingService.getDeliveryProof(shipmentId);
    });

/// Shipment audit trail provider
/// Immutable log of all changes to shipment
final shipmentAuditTrailProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((
      ref,
      shipmentId,
    ) async {
      final shippingService = ref.watch(shippingServiceProvider);
      return await shippingService.getAuditTrail(shipmentId);
    });
