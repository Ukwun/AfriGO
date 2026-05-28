import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order_model.dart';
import 'auth_provider.dart';

final ordersServiceProvider = Provider((ref) {
  final auth = ref.watch(authProvider);
  return OrdersService(auth);
});

/// Provider to get a single order by ID (for payment screen)
final orderDetailProvider = FutureProvider.family<OrderModel, String>(
  (ref, orderId) async {
    final service = ref.watch(ordersServiceProvider);
    return service.getOrder(orderId);
  },
);

/// Provider to get user's orders list
final myOrdersProvider = FutureProvider.autoDispose((ref) async {
  final service = ref.watch(ordersServiceProvider);
  return service.getMyOrders();
});

class OrdersService {
  final auth;
  static const String baseUrl = 'http://10.0.2.2:3000'; // Emulator localhost

  OrdersService(this.auth);

  /// Get a single order by ID
  Future<OrderModel> getOrder(String orderId) async {
    try {
      final token = auth is AuthAuthenticated ? auth.token : null;
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading order: $e');
    }
  }

  /// Get current user's orders
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final token = auth is AuthAuthenticated ? auth.token : null;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ordersList =
            data is List ? data : (data['data'] is List ? data['data'] : []);
        return (ordersList as List)
            .map((order) => OrderModel.fromJson(order))
            .toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading orders: $e');
    }
  }

  /// Create an order from an RFQ/Bid
  Future<OrderModel> createOrder({
    required String lotId,
    required String bidId,
    required double quantity,
    required double totalPrice,
  }) async {
    try {
      final token = auth is AuthAuthenticated ? auth.token : null;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'lotId': lotId,
          'bidId': bidId,
          'quantity': quantity,
          'totalPrice': totalPrice,
        }),
      );

      if (response.statusCode == 201) {
        return OrderModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  /// Update order status
  Future<OrderModel> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    try {
      final token = auth is AuthAuthenticated ? auth.token : null;
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        return OrderModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating order: $e');
    }
  }
}

// Import this if not present
import '../providers/auth_provider.dart';

class AuthAuthenticated {
  final String token;
  AuthAuthenticated({required this.token});
}
