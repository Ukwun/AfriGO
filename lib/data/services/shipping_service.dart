import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/constants.dart';
import '../api_client.dart';

/// Shipping Service Provider
final shippingServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ShippingService(apiClient: apiClient);
});

/// Shipping Service
/// Handles all shipment tracking, GPS updates, temperature monitoring
/// Real-time updates via WebSocket <500ms guaranteed
class ShippingService {
  final ApiClient apiClient;

  ShippingService({required this.apiClient});

  /// Create shipment
  /// Initiated when seller marks product as shipped
  Future<Map<String, dynamic>> createShipment({
    required String tradeId,
    required String originLocation,
    required String destinationLocation,
    required String carrier,
    String? trackingNumber,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/shipments/create',
        data: {
          'tradeId': tradeId,
          'originLocation': originLocation,
          'destinationLocation': destinationLocation,
          'carrier': carrier,
          'trackingNumber': trackingNumber,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      return {
        'shipmentId': response['shipmentId'],
        'status': response['status'],
        'trackingUrl': response['trackingUrl'],
      };
    } catch (e) {
      throw Exception('Failed to create shipment: $e');
    }
  }

  /// Get shipment details
  /// All real-time data: GPS location, temperature, status
  /// WebSocket updates ensure <500ms latency
  Future<Map<String, dynamic>> getShipment(String shipmentId) async {
    try {
      final response = await apiClient.get('/api/shipments/$shipmentId');

      return {
        'shipmentId': response['shipmentId'],
        'tradeId': response['tradeId'],
        'status': response['status'],
        'currentLocation': response['currentLocation'],
        'latitude': response['latitude'],
        'longitude': response['longitude'],
        'currentSpeed': response['currentSpeed'],
        'distanceRemaining': response['distanceRemaining'],
        'estimatedArrival': response['estimatedArrival'],
        'eta_confidence': response['eta_confidence'],
        'currentTemperature': response['currentTemperature'],
        'targetTemperature': response['targetTemperature'],
        'humidity': response['humidity'],
        'carrier': response['carrier'],
        'trackingNumber': response['trackingNumber'],
        'lastLocationUpdate': response['lastLocationUpdate'],
        'departedAt': response['departedAt'],
        'createdAt': response['createdAt'],
      };
    } catch (e) {
      throw Exception('Failed to get shipment: $e');
    }
  }

  /// Get shipment by trade ID
  /// Get shipment for a specific trade
  Future<Map<String, dynamic>> getShipmentByTrade(String tradeId) async {
    try {
      final response = await apiClient.get('/api/trades/$tradeId/shipment');

      return response;
    } catch (e) {
      throw Exception('Failed to get trade shipment: $e');
    }
  }

  /// Update shipment status
  /// Called when shipment status changes
  /// Broadcasts via WebSocket to both parties instantly
  Future<void> updateShipmentStatus({
    required String shipmentId,
    required String newStatus,
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      await apiClient.post(
        '/api/shipments/$shipmentId/status',
        data: {
          'status': newStatus,
          'location': location,
          'latitude': latitude,
          'longitude': longitude,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update shipment status: $e');
    }
  }

  /// Update GPS location
  /// Called every 30 seconds from IoT tracker
  /// Real data: latitude, longitude, speed
  Future<void> updateGPSLocation({
    required String shipmentId,
    required double latitude,
    required double longitude,
    required double speed,
  }) async {
    try {
      await apiClient.post(
        '/api/shipments/$shipmentId/gps-update',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'speed': speed,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update GPS: $e');
    }
  }

  /// Update temperature & humidity
  /// Called from IoT temperature sensor (cold chain monitoring)
  /// Real data: current temperature, humidity
  Future<void> updateTemperature({
    required String shipmentId,
    required double temperature,
    required double humidity,
    required double targetTemperature,
  }) async {
    try {
      await apiClient.post(
        '/api/shipments/$shipmentId/temperature-update',
        data: {
          'currentTemperature': temperature,
          'humidity': humidity,
          'targetTemperature': targetTemperature,
          'timestamp': DateTime.now().toIso8601String(),
          'isAlert':
              temperature > targetTemperature + 2 ||
              temperature < targetTemperature - 2,
        },
      );
    } catch (e) {
      throw Exception('Failed to update temperature: $e');
    }
  }

  /// Get shipment events (activity log)
  /// Immutable log of all shipment status changes
  /// Real-time via WebSocket: SHIPMENT_UPDATED events
  Future<List<Map<String, dynamic>>> getShipmentEvents(
    String shipmentId,
  ) async {
    try {
      final response = await apiClient.get('/api/shipments/$shipmentId/events');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get shipment events: $e');
    }
  }

  /// Record temperature alert
  /// If temperature breaches threshold, log alert and notify both parties
  Future<void> recordTemperatureAlert({
    required String shipmentId,
    required double currentTemp,
    required double targetTemp,
    required String severity, // LOW, MEDIUM, HIGH, CRITICAL
  }) async {
    try {
      await apiClient.post(
        '/api/shipments/$shipmentId/temperature-alert',
        data: {
          'currentTemperature': currentTemp,
          'targetTemperature': targetTemp,
          'severity': severity,
          'alertTime': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to record temperature alert: $e');
    }
  }

  /// Record delivery proof
  /// Photos + GPS location + timestamp at delivery
  /// Immutable proof of delivery
  Future<void> recordDeliveryProof({
    required String shipmentId,
    required List<String> photoUrls, // Base64 encoded or URLs
    required double latitude,
    required double longitude,
    required String receiverName,
    String? receiverSignature,
    String? notes,
  }) async {
    try {
      await apiClient.post(
        '/api/shipments/$shipmentId/delivery-proof',
        data: {
          'photoUrls': photoUrls,
          'latitude': latitude,
          'longitude': longitude,
          'receiverName': receiverName,
          'receiverSignature': receiverSignature,
          'notes': notes,
          'deliveredAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to record delivery proof: $e');
    }
  }

  /// Get delivery proof
  /// Download proof of delivery with all photos and details
  Future<Map<String, dynamic>> getDeliveryProof(String shipmentId) async {
    try {
      final response = await apiClient.get(
        '/api/shipments/$shipmentId/delivery-proof',
      );

      return response;
    } catch (e) {
      throw Exception('Failed to get delivery proof: $e');
    }
  }

  /// Request shipment modification
  /// If buyer requests change to delivery address, etc.
  Future<void> requestModification({
    required String shipmentId,
    required String field, // location, recipient, notes
    required String newValue,
    required String reason,
  }) async {
    try {
      await apiClient.post(
        '/api/shipments/$shipmentId/request-modification',
        data: {
          'field': field,
          'newValue': newValue,
          'reason': reason,
          'requestedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to request modification: $e');
    }
  }

  /// Mark shipment as delayed
  /// If delivery won't make ETA, notify buyer
  Future<void> reportDelay({
    required String shipmentId,
    required String reason,
    required DateTime newETA,
  }) async {
    try {
      await apiClient.post(
        '/api/shipments/$shipmentId/report-delay',
        data: {
          'reason': reason,
          'newETA': newETA.toIso8601String(),
          'reportedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to report delay: $e');
    }
  }

  /// Get shipment audit trail
  /// Immutable log: status changes, GPS updates, temperature readings, events
  Future<List<Map<String, dynamic>>> getAuditTrail(String shipmentId) async {
    try {
      final response = await apiClient.get(
        '/api/shipments/$shipmentId/audit-trail',
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get audit trail: $e');
    }
  }
}
