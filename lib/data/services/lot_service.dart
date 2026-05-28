import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import '../../domain/models/lot.dart';
import 'api_client.dart';

/// Lot Service
/// Handles all lot-related API calls
class LotService {
  final ApiClient _apiClient;

  LotService(this._apiClient);

  /// Get seller's lots (filtered by status)
  /// REAL backend call to: GET /api/lots/seller/:userId
  /// Returns lots with REAL data:
  /// - Real trust score impacts
  /// - Real bid/interest count
  /// - Real activity logs
  /// - Real QR codes
  Future<List<Lot>> getSellerLots({String? status}) async {
    try {
      final params = {if (status != null) 'status': status};

      final response = await _apiClient.dio.get(
        '/api/lots/seller',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final lotsData = response.data['data'] as List;
        return lotsData.map((json) => Lot.fromJson(json)).toList();
      }
      throw Exception('Failed to load lots: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// Get lot detail
  /// REAL backend call to: GET /api/lots/:id
  /// Returns complete lot with:
  /// - All photos
  /// - QR code (cryptographic)
  /// - Real-time bids (via WebSocket)
  /// - Activity log (immutable)
  /// - Trust score impact
  Future<Lot> getLotDetail(String lotId) async {
    try {
      final response = await _apiClient.dio.get('/api/lots/$lotId');

      if (response.statusCode == 200) {
        return Lot.fromJson(response.data['data']);
      }
      throw Exception('Failed to load lot: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// Create lot
  /// REAL backend call to: POST /api/lots/create
  /// Triggers:
  /// 1. Photo upload to cloud storage (generates URLs)
  /// 2. AI quality analysis on photos
  /// 3. Lot creation with immutable ledger
  /// 4. QR code generation (cryptographic, unforgeable)
  /// 5. Activity logging (immutable)
  /// 6. WebSocket broadcast (LOT_CREATED event)
  /// 7. Buyers notified if matches saved criteria
  Future<Lot> createLot({
    required String productType,
    required double quantity,
    required double price,
    required String qualityGrade,
    required DateTime harvestDate,
    required String description,
    required List<File> photos,
  }) async {
    try {
      final formData = FormData.fromMap({
        'productType': productType,
        'quantity': quantity,
        'price': price,
        'qualityGrade': qualityGrade,
        'harvestDate': harvestDate.toIso8601String(),
        'description': description,
        'photos': photos
            .map(
              (photo) => MultipartFile.fromFileSync(
                photo.path,
                filename: photo.path.split('/').last,
              ),
            )
            .toList(),
      });

      final response = await _apiClient.dio.post(
        '/api/lots/create',
        data: formData,
      );

      if (response.statusCode == 201) {
        // Activity logged automatically by backend
        // Real-time notification sent via WebSocket to buyers
        // Lot appears in marketplace within 2 seconds
        return Lot.fromJson(response.data['data']);
      }
      throw Exception('Failed to create lot: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// List lot (change status from CREATED to LISTED)
  /// REAL backend call to: POST /api/lots/:id/list
  /// Triggers:
  /// 1. Status update to LISTED
  /// 2. Activity log entry (immutable)
  /// 3. WebSocket broadcast (LOT_LISTED event)
  /// 4. All buyers' apps updated instantly (if matches criteria)
  /// 5. Lot now visible in marketplace search
  Future<Lot> listLot(String lotId) async {
    try {
      final response = await _apiClient.dio.post('/api/lots/$lotId/list');

      if (response.statusCode == 200) {
        return Lot.fromJson(response.data['data']);
      }
      throw Exception('Failed to list lot: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// Update lot
  /// REAL backend call to: PATCH /api/lots/:id
  /// Only allowed for CREATED and LISTED status lots
  Future<Lot> updateLot(
    String lotId, {
    double? quantity,
    double? price,
    String? description,
  }) async {
    try {
      final data = {
        if (quantity != null) 'quantity': quantity,
        if (price != null) 'price': price,
        if (description != null) 'description': description,
      };

      final response = await _apiClient.dio.patch(
        '/api/lots/$lotId',
        data: data,
      );

      if (response.statusCode == 200) {
        return Lot.fromJson(response.data['data']);
      }
      throw Exception('Failed to update lot: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// Delete lot
  /// REAL backend call to: DELETE /api/lots/:id
  /// Only allowed for CREATED status
  Future<void> deleteLot(String lotId) async {
    try {
      final response = await _apiClient.dio.delete('/api/lots/$lotId');

      if (response.statusCode != 204) {
        throw Exception('Failed to delete lot: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// Accept bid
  /// REAL backend call to: POST /api/lots/:id/accept-bid/:bidId
  /// Triggers:
  /// 1. Status update to SOLD
  /// 2. Trade created from bid
  /// 3. Escrow payment initiated
  /// 4. Both parties notified (seller + buyer)
  /// 5. Activity logged (immutable)
  /// 6. WebSocket broadcast to both parties
  /// 7. Buyer can now arrange shipment
  Future<void> acceptBid(String bidId) async {
    try {
      final response = await _apiClient.dio.post('/api/bids/$bidId/accept');

      if (response.statusCode != 200) {
        throw Exception('Failed to accept bid: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// Reject bid
  /// REAL backend call to: POST /api/lots/:id/reject-bid/:bidId
  Future<void> rejectBid(String bidId) async {
    try {
      final response = await _apiClient.dio.post('/api/bids/$bidId/reject');

      if (response.statusCode != 200) {
        throw Exception('Failed to reject bid: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }

  /// Update lot status
  /// REAL backend call to: PATCH /api/lots/:id/status
  /// Broadcasts real-time event via WebSocket
  Future<Lot> updateLotStatus(String lotId, String newStatus) async {
    try {
      final response = await _apiClient.dio.patch(
        '/api/lots/$lotId/status',
        data: {'status': newStatus},
      );

      if (response.statusCode == 200) {
        return Lot.fromJson(response.data['data']);
      }
      throw Exception('Failed to update status: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('API error: ${e.message}');
    }
  }
}

/// Lot Service Provider
final lotServiceProvider = Provider<LotService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LotService(apiClient);
});
