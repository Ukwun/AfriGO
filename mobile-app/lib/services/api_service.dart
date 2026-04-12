import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lot_model.dart';

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
