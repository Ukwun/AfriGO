import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shipment_model.dart';

// ======================== HTTP SERVICE ========================

class ShipmentService {
  final Dio httpClient;
  final String baseUrl;

  ShipmentService({required this.httpClient, required this.baseUrl});

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Create shipment from contract
  Future<ShipmentModel> createShipment(CreateShipmentRequest request) async {
    final headers = await _getHeaders();
    final response = await httpClient.post(
      '$baseUrl/api/shipments',
      data: request,
      options: Options(headers: headers),
    );
    return ShipmentModel.fromJson(response.data);
  }

  // Get single shipment
  Future<ShipmentDetailsModel> getShipmentById(String shipmentId) async {
    final headers = await _getHeaders();
    final response = await httpClient.get(
      '$baseUrl/api/shipments/$shipmentId',
      options: Options(headers: headers),
    );
    return ShipmentDetailsModel.fromJson(response.data);
  }

  // List shipments with filters
  Future<ShipmentListModel> listShipments({
    String? status,
    String? transportMode,
    String? driverId,
    String? contractId,
    int limit = 20,
    int offset = 0,
  }) async {
    final headers = await _getHeaders();
    final params = {
      'limit': limit,
      'offset': offset,
      if (status != null) 'status': status,
      if (transportMode != null) 'transportMode': transportMode,
      if (driverId != null) 'driverId': driverId,
      if (contractId != null) 'contractId': contractId,
    };

    final response = await httpClient.get(
      '$baseUrl/api/shipments',
      queryParameters: params,
      options: Options(headers: headers),
    );
    return ShipmentListModel.fromJson(response.data);
  }

  // Update shipment status
  Future<ShipmentModel> updateShipmentStatus(
    String shipmentId,
    UpdateShipmentStatusRequest request,
  ) async {
    final headers = await _getHeaders();
    final response = await httpClient.patch(
      '$baseUrl/api/shipments/$shipmentId/status',
      data: request,
      options: Options(headers: headers),
    );
    return ShipmentModel.fromJson(response.data);
  }

  // Add tracking event with GPS location
  Future<dynamic> addTrackingEvent(
    String shipmentId,
    AddTrackingEventRequest request,
  ) async {
    final headers = await _getHeaders();
    final response = await httpClient.post(
      '$baseUrl/api/shipments/$shipmentId/tracking-event',
      data: request,
      options: Options(headers: headers),
    );
    return response.data;
  }

  // Get tracking history
  Future<List<TrackingEventModel>> getTrackingHistory(String shipmentId) async {
    final headers = await _getHeaders();
    final response = await httpClient.get(
      '$baseUrl/api/shipments/$shipmentId/tracking',
      options: Options(headers: headers),
    );
    return (response.data as List)
        .map((event) => TrackingEventModel.fromJson(event))
        .toList();
  }

  // Capture delivery proof (signature, photo, ID)
  Future<dynamic> captureDeliveryProof(
    String shipmentId,
    CaptureDeliveryProofRequest request,
  ) async {
    final headers = await _getHeaders();
    final response = await httpClient.post(
      '$baseUrl/api/shipments/$shipmentId/delivery-proof',
      data: request,
      options: Options(headers: headers),
    );
    return response.data;
  }

  // Get delivery proofs
  Future<List<DeliveryProofModel>> getDeliveryProofs(String shipmentId) async {
    final headers = await _getHeaders();
    final response = await httpClient.get(
      '$baseUrl/api/shipments/$shipmentId/delivery-proofs',
      options: Options(headers: headers),
    );
    return (response.data as List)
        .map((proof) => DeliveryProofModel.fromJson(proof))
        .toList();
  }

  // Reschedule delivery
  Future<ShipmentModel> rescheduleDelivery(
    String shipmentId,
    RescheduleDeliveryRequest request,
  ) async {
    final headers = await _getHeaders();
    final response = await httpClient.patch(
      '$baseUrl/api/shipments/$shipmentId/reschedule',
      data: request,
      options: Options(headers: headers),
    );
    return ShipmentModel.fromJson(response.data);
  }

  // Get shipment statistics
  Future<ShipmentSummaryModel> getShipmentStatistics(String shipmentId) async {
    final headers = await _getHeaders();
    final response = await httpClient.get(
      '$baseUrl/api/shipments/$shipmentId/summary',
      options: Options(headers: headers),
    );
    return ShipmentSummaryModel.fromJson(response.data);
  }

  // Cancel shipment
  Future<ShipmentModel> cancelShipment(String shipmentId, String reason) async {
    final headers = await _getHeaders();
    final response = await httpClient.delete(
      '$baseUrl/api/shipments/$shipmentId',
      queryParameters: {'reason': reason},
      options: Options(headers: headers),
    );
    return ShipmentModel.fromJson(response.data);
  }
}

// ======================== RIVERPOD PROVIDERS ========================

// Service provider
final shipmentServiceProvider = Provider<ShipmentService>((ref) {
  final dio = Dio();
  return ShipmentService(
    httpClient: dio,
    baseUrl: 'http://localhost:3000', // Change to production URL
  );
});

// List shipments provider
final shipmentsProvider =
    FutureProvider.family<ShipmentListModel, ShipmentFilters>((
  ref,
  filters,
) async {
  final service = ref.watch(shipmentServiceProvider);
  return service.listShipments(
    status: filters.status,
    transportMode: filters.transportMode,
    driverId: filters.driverId,
    contractId: filters.contractId,
    limit: filters.limit,
    offset: filters.offset,
  );
});

// Single shipment provider
final shipmentProvider = FutureProvider.family<ShipmentDetailsModel, String>((
  ref,
  shipmentId,
) async {
  final service = ref.watch(shipmentServiceProvider);
  return service.getShipmentById(shipmentId);
});

// Tracking history provider
final trackingHistoryProvider =
    FutureProvider.family<List<TrackingEventModel>, String>((
  ref,
  shipmentId,
) async {
  final service = ref.watch(shipmentServiceProvider);
  return service.getTrackingHistory(shipmentId);
});

// Delivery proofs provider
final deliveryProofsProvider =
    FutureProvider.family<List<DeliveryProofModel>, String>((
  ref,
  shipmentId,
) async {
  final service = ref.watch(shipmentServiceProvider);
  return service.getDeliveryProofs(shipmentId);
});

// Shipment statistics provider
final shipmentStatisticsProvider =
    FutureProvider.family<ShipmentSummaryModel, String>((
  ref,
  shipmentId,
) async {
  final service = ref.watch(shipmentServiceProvider);
  return service.getShipmentStatistics(shipmentId);
});

// Days until delivery provider
final daysUntilDeliveryProvider =
    Provider.family<int?, String>((ref, shipmentId) {
  final shipmentAsync = ref.watch(shipmentProvider(shipmentId));
  return shipmentAsync.whenData((shipment) {
    final now = DateTime.now();
    final days = shipment.expectedDeliveryDate.difference(now).inDays;
    return days > 0 ? days : 0;
  }).value;
});

// Is delayed provider
final isDelayedProvider = Provider.family<bool, String>((ref, shipmentId) {
  final shipmentAsync = ref.watch(shipmentProvider(shipmentId));
  return shipmentAsync.maybeWhen(
    data: (shipment) => shipment.isDelayed ?? false,
    orElse: () => false,
  );
});

// ======================== HELPER MODELS ========================

class ShipmentFilters {
  final String? status;
  final String? transportMode;
  final String? driverId;
  final String? contractId;
  final int limit;
  final int offset;

  ShipmentFilters({
    this.status,
    this.transportMode,
    this.driverId,
    this.contractId,
    this.limit = 20,
    this.offset = 0,
  });

  ShipmentFilters copyWith({
    String? status,
    String? transportMode,
    String? driverId,
    String? contractId,
    int? limit,
    int? offset,
  }) {
    return ShipmentFilters(
      status: status ?? this.status,
      transportMode: transportMode ?? this.transportMode,
      driverId: driverId ?? this.driverId,
      contractId: contractId ?? this.contractId,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}
