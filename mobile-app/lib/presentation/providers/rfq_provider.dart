import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/rfq_model.dart';

final rfqServiceProvider = Provider((ref) {
  return RFQService(authToken: null);
});

final rfqListProvider =
    FutureProvider.family<List<RFQModel>, Map<String, dynamic>>(
        (ref, filters) async {
  final service = ref.watch(rfqServiceProvider);
  return service.listRFQs(filters);
});

final rfqDetailProvider =
    FutureProvider.family<RFQModel, String>((ref, rfqId) async {
  final service = ref.watch(rfqServiceProvider);
  return service.getRFQDetails(rfqId);
});

final buyerRFQsProvider = FutureProvider<List<RFQModel>>((ref) async {
  final service = ref.watch(rfqServiceProvider);
  return service.getBuyerRFQs({
    'page': 1,
    'limit': 50,
  });
});

final supplierBidsProvider = FutureProvider<List<RFQBidModel>>((ref) async {
  final service = ref.watch(rfqServiceProvider);
  return service.getSupplierBids({
    'page': 1,
    'limit': 50,
  });
});

final rfqBidsProvider =
    FutureProvider.family<List<RFQBidModel>, String>((ref, rfqId) async {
  final service = ref.watch(rfqServiceProvider);
  return service.getRFQBids(rfqId);
});

class RFQService {
  final String? authToken;
  static const String _baseUrl = 'http://localhost:3000';

  RFQService({required this.authToken});

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  /// List all open RFQs for buyers to see (public)
  Future<List<RFQModel>> listRFQs(Map<String, dynamic> filters) async {
    try {
      final queryParams = _buildQueryString(filters);
      final response = await http.get(
        Uri.parse('$_baseUrl/api/rfqs?$queryParams'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final rfqs = (json['data'] as List)
            .map((item) => RFQModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return rfqs;
      } else {
        throw Exception('Failed to load RFQs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error listing RFQs: $e');
    }
  }

  /// Get single RFQ details with all bids
  Future<RFQModel> getRFQDetails(String rfqId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/rfqs/$rfqId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return RFQModel.fromJson(json['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('RFQ not found');
      } else {
        throw Exception('Failed to load RFQ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading RFQ: $e');
    }
  }

  /// Get all RFQs created by current buyer
  Future<List<RFQModel>> getBuyerRFQs(Map<String, dynamic> filters) async {
    try {
      final queryParams = _buildQueryString(filters);
      final response = await http.get(
        Uri.parse('$_baseUrl/api/rfqs/buyer/my-rfqs?$queryParams'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final rfqs = (json['data'] as List)
            .map((item) => RFQModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return rfqs;
      } else {
        throw Exception('Failed to load buyer RFQs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading buyer RFQs: $e');
    }
  }

  /// Get all bids submitted by current supplier
  Future<List<RFQBidModel>> getSupplierBids(
      Map<String, dynamic> filters) async {
    try {
      final queryParams = _buildQueryString(filters);
      final response = await http.get(
        Uri.parse('$_baseUrl/api/rfqs/supplier/my-bids?$queryParams'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final bids = (json['data'] as List)
            .map((item) => RFQBidModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return bids;
      } else {
        throw Exception('Failed to load supplier bids: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading supplier bids: $e');
    }
  }

  /// Get all bids for specific RFQ (only for RFQ creator)
  Future<List<RFQBidModel>> getRFQBids(String rfqId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/rfqs/$rfqId/bids'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final bids = (json['data'] as List)
            .map((item) => RFQBidModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return bids;
      } else {
        throw Exception('Failed to load RFQ bids: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading RFQ bids: $e');
    }
  }

  /// Create new RFQ (buyer only)
  Future<RFQModel> createRFQ(CreateRFQRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/rfqs'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return RFQModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create RFQ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating RFQ: $e');
    }
  }

  /// Submit bid for RFQ (supplier only)
  Future<RFQBidModel> submitBid(SubmitBidRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/rfqs/${request.rfqId}/bids'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return RFQBidModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to submit bid: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting bid: $e');
    }
  }

  /// Award bid to supplier (buyer only)
  Future<RFQModel> awardBid(String rfqId, String bidId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/rfqs/$rfqId/award-bid'),
        headers: _headers,
        body: jsonEncode({'bidId': bidId}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return RFQModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to award bid: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error awarding bid: $e');
    }
  }

  /// Close RFQ (buyer only)
  Future<RFQModel> closeRFQ(String rfqId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/rfqs/$rfqId/close'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return RFQModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to close RFQ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error closing RFQ: $e');
    }
  }

  String _buildQueryString(Map<String, dynamic> params) {
    final queryParams = params.entries
        .where((e) => e.value != null)
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    return queryParams;
  }
}
