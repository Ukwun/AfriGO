import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../config/constants.dart';
import 'token_storage.dart';

/// WebSocket Service
/// Real-time communication using Socket.io
/// Handles:
/// - Event broadcasting from backend
/// - Notifications in real-time (<500ms latency)
/// - Trade updates, shipment tracking, payments
class WebSocketService {
  late IO.Socket _socket;
  bool _isConnected = false;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // Get JWT token
      final tokenStorage = TokenStorage();
      final token = await tokenStorage.getToken();

      if (token == null) {
        throw Exception('No authentication token available');
      }

      // Verify token is still valid
      if (JwtDecoder.isExpired(token)) {
        throw Exception('Token expired');
      }

      // Connect to WebSocket with JWT authentication
      _socket = IO.io(
        Constants.baseUrl.replaceFirst('http', 'ws'),
        OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );

      // Handle connection events
      _socket.onConnect((_) {
        _isConnected = true;
        print('✅ WebSocket connected');
      });

      _socket.onDisconnect((_) {
        _isConnected = false;
        print('❌ WebSocket disconnected');
      });

      _socket.onConnectError((dynamic error) {
        print('❌ WebSocket connection error: $error');
      });

      _socket.connect();
    } catch (e) {
      print('❌ WebSocket connection failed: $e');
      rethrow;
    }
  }

  void disconnect() {
    if (_isConnected) {
      _socket.disconnect();
      _isConnected = false;
    }
  }

  /// Listen to real-time events from backend
  /// Events include:
  /// - LOT_CREATED: New product listed
  /// - TRADE_ACCEPTED: Seller accepted offer
  /// - PAYMENT_CONFIRMED: Payment received
  /// - SHIPMENT_UPDATED: GPS/status change
  /// - MESSAGE_RECEIVED: New message
  /// - NOTIFICATION: General notifications
  void on(String event, Function(dynamic) callback) {
    _socket.on(event, (data) {
      print('📨 Event received: $event - $data');
      callback(data);
    });
  }

  /// Stop listening to specific event
  void off(String event) {
    _socket.off(event);
  }

  /// Broadcast event to backend
  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socket.emit(event, data);
      print('📤 Event emitted: $event');
    } else {
      print('❌ WebSocket not connected, cannot emit event: $event');
    }
  }

  bool get isConnected => _isConnected;
}

/// WebSocket Service Provider
final websocketServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService();
});
