import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lot_model.dart';
import '../models/order_model.dart';
import '../models/quote_model.dart';
import '../models/message_model.dart';
import '../models/payment_model.dart';

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

  // ==================== MESSAGING ENDPOINTS ====================

  /// POST /api/messages
  /// Send a new message
  Future<MessageModel> sendMessage({
    required String recipientId,
    required String content,
    String? orderId,
    String? messageType,
    List<String>? attachments,
  }) async {
    try {
      final response = await _dio.post(
        '/api/messages',
        data: {
          'recipientId': recipientId,
          'content': content,
          if (orderId != null) 'orderId': orderId,
          if (messageType != null) 'messageType': messageType,
          if (attachments != null) 'attachments': attachments,
        },
      );

      if (response.statusCode == 201) {
        return MessageModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to send message');
      }
    } on DioException catch (e) {
      throw Exception('Error sending message: ${e.message}');
    }
  }

  /// GET /api/messages/conversations
  /// Get all conversations for current user
  Future<List<ConversationModel>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/messages/conversations',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> conversationsList = response.data ?? [];
        return conversationsList
            .map((conv) =>
                ConversationModel.fromJson(conv as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load conversations');
      }
    } on DioException catch (e) {
      throw Exception('Error loading conversations: ${e.message}');
    }
  }

  /// GET /api/messages/conversations/:otherUserId
  /// Get messages in conversation with specific user
  Future<List<MessageModel>> getConversationMessages(
    String otherUserId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/api/messages/conversations/$otherUserId',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesList = response.data['messages'] ?? [];
        return messagesList
            .map((msg) => MessageModel.fromJson(msg as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load conversation');
      }
    } on DioException catch (e) {
      throw Exception('Error loading conversation: ${e.message}');
    }
  }

  /// GET /api/messages/orders/:orderId
  /// Get conversation for a specific order
  Future<List<MessageModel>> getOrderConversation(String orderId) async {
    try {
      final response = await _dio.get('/api/messages/orders/$orderId');

      if (response.statusCode == 200) {
        final List<dynamic> messagesList = response.data['messages'] ?? [];
        return messagesList
            .map((msg) => MessageModel.fromJson(msg as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load order conversation');
      }
    } on DioException catch (e) {
      throw Exception('Error loading order conversation: ${e.message}');
    }
  }

  /// PUT /api/messages/:id
  /// Update message content (within 5 minutes of sending)
  Future<MessageModel> updateMessage(
    String messageId, {
    required String content,
  }) async {
    try {
      final response = await _dio.put(
        '/api/messages/$messageId',
        data: {'content': content},
      );

      if (response.statusCode == 200) {
        return MessageModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update message');
      }
    } on DioException catch (e) {
      throw Exception('Error updating message: ${e.message}');
    }
  }

  /// DELETE /api/messages/:id
  /// Delete (soft delete) a message
  Future<bool> deleteMessage(String messageId) async {
    try {
      final response = await _dio.delete('/api/messages/$messageId');

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete message');
      }
    } on DioException catch (e) {
      throw Exception('Error deleting message: ${e.message}');
    }
  }

  /// POST /api/messages/read/mark
  /// Mark multiple messages as read
  Future<bool> markMessagesAsRead(List<String> messageIds) async {
    try {
      final response = await _dio.post(
        '/api/messages/read/mark',
        data: {'messageIds': messageIds},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to mark messages as read');
      }
    } on DioException catch (e) {
      throw Exception('Error marking messages: ${e.message}');
    }
  }

  /// POST /api/messages/conversations/:otherUserId/read
  /// Mark entire conversation as read
  Future<bool> markConversationAsRead(String otherUserId) async {
    try {
      final response = await _dio.post(
        '/api/messages/conversations/$otherUserId/read',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to mark conversation as read');
      }
    } on DioException catch (e) {
      throw Exception('Error marking conversation: ${e.message}');
    }
  }

  /// GET /api/messages/unread/count
  /// Get count of unread messages
  Future<int> getUnreadMessageCount() async {
    try {
      final response = await _dio.get('/api/messages/unread/count');

      if (response.statusCode == 200) {
        return response.data['unreadCount'] as int? ?? 0;
      } else {
        throw Exception('Failed to get unread count');
      }
    } on DioException catch (e) {
      throw Exception('Error getting unread count: ${e.message}');
    }
  }

  /// GET /api/messages/conversations/:otherUserId/search
  /// Search messages in a conversation
  Future<List<MessageModel>> searchMessages(
    String otherUserId,
    String query, {
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/messages/conversations/$otherUserId/search',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesList = response.data ?? [];
        return messagesList
            .map((msg) => MessageModel.fromJson(msg as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Search failed');
      }
    } on DioException catch (e) {
      throw Exception('Error searching messages: ${e.message}');
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

  // ==================== PAYMENTS ENDPOINTS ====================

  /// GET /api/payments/config/publishable-key
  /// Get Stripe publishable key for frontend
  Future<String> getStripePublishableKey() async {
    try {
      final response = await _dio.get('/api/payments/config/publishable-key');
      if (response.statusCode == 200) {
        return response.data['publishableKey'] as String;
      }
      throw Exception('Failed to fetch publishable key');
    } on DioException catch (e) {
      throw Exception('Error fetching publishable key: ${e.message}');
    }
  }

  /// POST /api/payments
  /// Create a new payment (initialize PaymentIntent)
  Future<PaymentModel> createPayment(CreatePaymentRequestModel request) async {
    try {
      final response = await _dio.post(
        '/api/payments',
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return PaymentModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to create payment');
    } on DioException catch (e) {
      throw Exception('Error creating payment: ${e.message}');
    }
  }

  /// POST /api/payments/:id/confirm
  /// Confirm payment (for 3D Secure or additional authentication)
  Future<PaymentModel> confirmPayment(
    String paymentId,
    ConfirmPaymentRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/payments/$paymentId/confirm',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to confirm payment');
    } on DioException catch (e) {
      throw Exception('Error confirming payment: ${e.message}');
    }
  }

  /// GET /api/payments/:id
  /// Get payment by ID
  Future<PaymentModel> getPayment(String paymentId) async {
    try {
      final response = await _dio.get('/api/payments/$paymentId');

      if (response.statusCode == 200) {
        return PaymentModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to fetch payment');
    } on DioException catch (e) {
      throw Exception('Error fetching payment: ${e.message}');
    }
  }

  /// GET /api/payments/order/:orderId
  /// Get payment for an order
  Future<List<PaymentModel>> getOrderPayments(String orderId) async {
    try {
      final response = await _dio.get('/api/payments/order/$orderId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => PaymentModel.fromJson(item)).toList();
      }
      throw Exception('Failed to fetch order payments');
    } on DioException catch (e) {
      throw Exception('Error fetching order payments: ${e.message}');
    }
  }

  /// POST /api/payments/:id/refund
  /// Refund a payment
  Future<PaymentModel> refundPayment(
    String paymentId,
    RefundPaymentRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/payments/$paymentId/refund',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to refund payment');
    } on DioException catch (e) {
      throw Exception('Error refunding payment: ${e.message}');
    }
  }

  /// GET /api/payments
  /// Get user payment history with pagination
  Future<PaymentHistoryResponseModel> getUserPaymentHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/payments',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return PaymentHistoryResponseModel.fromJson(response.data);
      }
      throw Exception('Failed to fetch payment history');
    } on DioException catch (e) {
      throw Exception('Error fetching payment history: ${e.message}');
    }
  }

  /// POST /api/payments/:id/release-escrow
  /// Release escrow funds (seller receives payout)
  Future<PaymentModel> releaseEscrow(String paymentId) async {
    try {
      final response =
          await _dio.post('/api/payments/$paymentId/release-escrow');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PaymentModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to release escrow');
    } on DioException catch (e) {
      throw Exception('Error releasing escrow: ${e.message}');
    }
  }
}
