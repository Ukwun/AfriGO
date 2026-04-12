import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lot_model.dart';
import '../models/order_model.dart';
import '../models/quote_model.dart';

// API service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  static const String _baseUrl =
      'https://api.afrigo.com'; // Replace with your API URL
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO: Add JWT token from secure storage
          // final token = await secureStorage.read(key: 'jwt_token');
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors (401 unauthorized, 500 server error, etc.)
          print('API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // ==================== LOTS ENDPOINTS ====================

  /// GET /api/lots
  /// Get all lots with filtering, pagination, and sorting
  Future<List<LotModel>> getLots({
    String? productName,
    double? minPrice,
    double? maxPrice,
    String? location,
    String? status,
    int page = 1,
    int limit = 20,
    String sortBy = 'newest',
  }) async {
    try {
      final response = await _dio.get(
        '/api/lots',
        queryParameters: {
          if (productName != null) 'productName': productName,
          if (minPrice != null) 'minPrice': minPrice,
          if (maxPrice != null) 'maxPrice': maxPrice,
          if (location != null) 'location': location,
          if (status != null) 'status': status,
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> lotsList = response.data['data'] ?? [];
        return lotsList
            .map((lot) => LotModel.fromJson(lot as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load lots');
      }
    } on DioException catch (e) {
      throw Exception('Error loading lots: ${e.message}');
    }
  }

  /// GET /api/lots/:id
  /// Get single lot by ID
  Future<LotModel> getLotById(String lotId) async {
    try {
      final response = await _dio.get('/api/lots/$lotId');

      if (response.statusCode == 200) {
        return LotModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load lot');
      }
    } on DioException catch (e) {
      throw Exception('Error loading lot: ${e.message}');
    }
  }

  /// GET /api/lots/qr/:code
  /// Get lot by QR code
  Future<LotModel> getLotByQRCode(String qrCode) async {
    try {
      final response = await _dio.get('/api/lots/qr/$qrCode');

      if (response.statusCode == 200) {
        return LotModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('QR code not found');
      }
    } on DioException catch (e) {
      throw Exception('Error scanning QR code: ${e.message}');
    }
  }

  /// POST /api/lots
  /// Create new lot (seller only)
  Future<LotModel> createLot({
    required String productName,
    required double quantity,
    required String quantityUnit,
    required double pricePerUnit,
    required String description,
    required List<String> images,
    required String pickupLocation,
    required double latitude,
    required double longitude,
    String? category,
    List<String>? certifications,
  }) async {
    try {
      final response = await _dio.post(
        '/api/lots',
        data: {
          'productName': productName,
          'quantity': quantity,
          'quantityUnit': quantityUnit,
          'pricePerUnit': pricePerUnit,
          'description': description,
          'images': images,
          'pickupLocation': pickupLocation,
          'latitude': latitude,
          'longitude': longitude,
          if (category != null) 'category': category,
          if (certifications != null) 'certifications': certifications,
        },
      );

      if (response.statusCode == 201) {
        return LotModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create lot');
      }
    } on DioException catch (e) {
      throw Exception('Error creating lot: ${e.message}');
    }
  }

  /// PUT /api/lots/:id
  /// Update lot (seller only)
  Future<LotModel> updateLot(
    String lotId, {
    String? productName,
    double? quantity,
    String? quantityUnit,
    double? pricePerUnit,
    String? description,
    List<String>? images,
    String? pickupLocation,
    double? latitude,
    double? longitude,
    String? status,
    List<String>? certifications,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (productName != null) data['productName'] = productName;
      if (quantity != null) data['quantity'] = quantity;
      if (quantityUnit != null) data['quantityUnit'] = quantityUnit;
      if (pricePerUnit != null) data['pricePerUnit'] = pricePerUnit;
      if (description != null) data['description'] = description;
      if (images != null) data['images'] = images;
      if (pickupLocation != null) data['pickupLocation'] = pickupLocation;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (status != null) data['status'] = status;
      if (certifications != null) data['certifications'] = certifications;

      final response = await _dio.put('/api/lots/$lotId', data: data);

      if (response.statusCode == 200) {
        return LotModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update lot');
      }
    } on DioException catch (e) {
      throw Exception('Error updating lot: ${e.message}');
    }
  }

  /// DELETE /api/lots/:id
  /// Delete lot (seller only, soft delete)
  Future<bool> deleteLot(String lotId) async {
    try {
      final response = await _dio.delete('/api/lots/$lotId');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete lot');
      }
    } on DioException catch (e) {
      throw Exception('Error deleting lot: ${e.message}');
    }
  }

  /// GET /api/lots/search/:query
  /// Search lots by full-text search
  Future<List<LotModel>> searchLots(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '/api/lots/search/$query',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> lotsList = response.data as List? ?? [];
        return lotsList
            .map((lot) => LotModel.fromJson(lot as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Search failed');
      }
    } on DioException catch (e) {
      throw Exception('Error searching lots: ${e.message}');
    }
  }

  /// GET /api/lots/location/:latitude/:longitude?radius=50
  /// Get lots by geographic location
  Future<List<LotModel>> getLotsByLocation(
    double latitude,
    double longitude, {
    double radiusKm = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/api/lots/location/$latitude/$longitude',
        queryParameters: {'radius': radiusKm},
      );

      if (response.statusCode == 200) {
        final List<dynamic> lotsList = response.data as List? ?? [];
        return lotsList
            .map((lot) => LotModel.fromJson(lot as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load lots by location');
      }
    } on DioException catch (e) {
      throw Exception('Error loading lots by location: ${e.message}');
    }
  }

  /// GET /api/lots/seller/me
  /// Get current user's lots (seller dashboard)
  Future<List<LotModel>> getMyLots({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/lots/seller/me',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> lotsList = response.data['data'] ?? [];
        return lotsList
            .map((lot) => LotModel.fromJson(lot as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load your lots');
      }
    } on DioException catch (e) {
      throw Exception('Error loading your lots: ${e.message}');
    }
  }

  /// POST /api/lots/:id/verify
  /// Verify lot (admin only)
  Future<LotModel> verifyLot(String lotId, bool approved) async {
    try {
      final response = await _dio.post(
        '/api/lots/$lotId/verify',
        data: {'approved': approved},
      );

      if (response.statusCode == 200) {
        return LotModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to verify lot');
      }
    } on DioException catch (e) {
      throw Exception('Error verifying lot: ${e.message}');
    }
  }

  // ==================== ORDERS ENDPOINTS ====================

  /// POST /api/orders
  /// Create new order
  Future<OrderModel> createOrder({
    required String lotId,
    required double quantity,
    required String shippingAddress,
    required DateTime deliveryDate,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/api/orders',
        data: {
          'lotId': lotId,
          'quantity': quantity,
          'shippingAddress': shippingAddress,
          'deliveryDate': deliveryDate.toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201) {
        return OrderModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create order');
      }
    } on DioException catch (e) {
      throw Exception('Error creating order: ${e.message}');
    }
  }

  /// GET /api/orders
  /// Get all orders (both bought and sold)
  Future<List<OrderModel>> getOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/orders',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersList = response.data['data'] ?? [];
        return ordersList
            .map((order) => OrderModel.fromJson(order as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } on DioException catch (e) {
      throw Exception('Error loading orders: ${e.message}');
    }
  }

  /// GET /api/orders/:id
  /// Get order by ID
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _dio.get('/api/orders/$orderId');

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Order not found');
      }
    } on DioException catch (e) {
      throw Exception('Error loading order: ${e.message}');
    }
  }

  /// GET /api/orders/buyer/me
  /// Get current user's orders as buyer
  Future<List<OrderModel>> getMyBuyerOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/orders/buyer/me',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersList = response.data['data'] ?? [];
        return ordersList
            .map((order) => OrderModel.fromJson(order as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load buyer orders');
      }
    } on DioException catch (e) {
      throw Exception('Error loading buyer orders: ${e.message}');
    }
  }

  /// GET /api/orders/seller/me
  /// Get current user's orders as seller
  Future<List<OrderModel>> getMySellerOrders({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/orders/seller/me',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> ordersList = response.data['data'] ?? [];
        return ordersList
            .map((order) => OrderModel.fromJson(order as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load seller orders');
      }
    } on DioException catch (e) {
      throw Exception('Error loading seller orders: ${e.message}');
    }
  }

  /// PUT /api/orders/:id
  /// Update order
  Future<OrderModel> updateOrder(
    String orderId, {
    String? status,
    String? paymentStatus,
    String? trackingNumber,
    DateTime? deliveryDate,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (status != null) data['status'] = status;
      if (paymentStatus != null) data['paymentStatus'] = paymentStatus;
      if (trackingNumber != null) data['trackingNumber'] = trackingNumber;
      if (deliveryDate != null)
        data['deliveryDate'] = deliveryDate.toIso8601String();
      if (notes != null) data['notes'] = notes;

      final response = await _dio.put('/api/orders/$orderId', data: data);

      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update order');
      }
    } on DioException catch (e) {
      throw Exception('Error updating order: ${e.message}');
    }
  }

  /// DELETE /api/orders/:id
  /// Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await _dio.delete('/api/orders/$orderId');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to cancel order');
      }
    } on DioException catch (e) {
      throw Exception('Error cancelling order: ${e.message}');
    }
  }

  // ==================== QUOTES ENDPOINTS ====================

  /// POST /api/quotes
  /// Create new quote (price offer)
  Future<QuoteModel> createQuote({
    required String lotId,
    required double suggestedPricePerUnit,
    required double quantity,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/api/quotes',
        data: {
          'lotId': lotId,
          'suggestedPricePerUnit': suggestedPricePerUnit,
          'quantity': quantity,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201) {
        return QuoteModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create quote');
      }
    } on DioException catch (e) {
      throw Exception('Error creating quote: ${e.message}');
    }
  }

  /// GET /api/quotes/:id
  /// Get quote by ID
  Future<QuoteModel> getQuoteById(String quoteId) async {
    try {
      final response = await _dio.get('/api/quotes/$quoteId');

      if (response.statusCode == 200) {
        return QuoteModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Quote not found');
      }
    } on DioException catch (e) {
      throw Exception('Error loading quote: ${e.message}');
    }
  }

  /// GET /api/quotes/lot/:lotId
  /// Get all quotes for a lot (seller only)
  Future<List<QuoteModel>> getQuotesForLot(
    String lotId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/quotes/lot/$lotId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> quotesList = response.data['data'] ?? [];
        return quotesList
            .map((quote) => QuoteModel.fromJson(quote as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load quotes');
      }
    } on DioException catch (e) {
      throw Exception('Error loading quotes: ${e.message}');
    }
  }

  /// GET /api/quotes/buyer/me
  /// Get current user's quotes as buyer
  Future<List<QuoteModel>> getMyQuotes({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/quotes/buyer/me',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> quotesList = response.data['data'] ?? [];
        return quotesList
            .map((quote) => QuoteModel.fromJson(quote as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load quotes');
      }
    } on DioException catch (e) {
      throw Exception('Error loading quotes: ${e.message}');
    }
  }

  /// PUT /api/quotes/:id
  /// Update quote (counter-offer)
  Future<QuoteModel> updateQuote(
    String quoteId, {
    double? suggestedPricePerUnit,
    String? status,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (suggestedPricePerUnit != null)
        data['suggestedPricePerUnit'] = suggestedPricePerUnit;
      if (status != null) data['status'] = status;
      if (notes != null) data['notes'] = notes;

      final response = await _dio.put('/api/quotes/$quoteId', data: data);

      if (response.statusCode == 200) {
        return QuoteModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update quote');
      }
    } on DioException catch (e) {
      throw Exception('Error updating quote: ${e.message}');
    }
  }

  /// POST /api/quotes/:id/accept
  /// Accept a quote (create order from quote)
  Future<OrderModel> acceptQuote(String quoteId) async {
    try {
      final response = await _dio.post('/api/quotes/$quoteId/accept');

      if (response.statusCode == 201) {
        return OrderModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to accept quote');
      }
    } on DioException catch (e) {
      throw Exception('Error accepting quote: ${e.message}');
    }
  }

  /// DELETE /api/quotes/:id
  /// Reject/delete a quote
  Future<bool> rejectQuote(String quoteId) async {
    try {
      final response = await _dio.delete('/api/quotes/$quoteId');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to reject quote');
      }
    } on DioException catch (e) {
      throw Exception('Error rejecting quote: ${e.message}');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Upload image to cloud storage (AWS S3, Firebase Storage, etc.)
  /// Returns the image URL
  Future<String> uploadImage(String imagePath) async {
    try {
      final file = await MultipartFile.fromFile(imagePath);
      final formData = FormData.fromMap({'file': file});

      final response = await _dio.post(
        '/api/upload', // Endpoint for image upload
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['url'] as String;
      } else {
        throw Exception('Image upload failed');
      }
    } on DioException catch (e) {
      throw Exception('Error uploading image: ${e.message}');
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadImages(List<String> imagePaths) async {
    try {
      final files = await Future.wait(
        imagePaths.map((path) => MultipartFile.fromFile(path)),
      );
      final formData = FormData.fromMap({'files': files});

      final response = await _dio.post(
        '/api/upload-multiple', // Endpoint for multiple image upload
        data: formData,
      );

      if (response.statusCode == 200) {
        final List<dynamic> urls = response.data['urls'] ?? [];
        return urls.map((url) => url.toString()).toList();
      } else {
        throw Exception('Image upload failed');
      }
    } on DioException catch (e) {
      throw Exception('Error uploading images: ${e.message}');
    }
  }
}
