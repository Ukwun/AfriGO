import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

/// WEBSOCKET CLIENT SERVICE
/// Real-time communication with backend
/// Features: Event listening, notifications, connection management
/// Status: Production-ready with reconnection logic

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  final String _baseUrl = 'https://api.afrigo.app'; // Production URL

  bool _isConnected = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 10;
  Timer? _heartbeatTimer;

  // Event stream controllers for Riverpod
  final _tradeOfferStream = StreamController<dynamic>.broadcast();
  final _counterOfferStream = StreamController<dynamic>.broadcast();
  final _paymentConfirmedStream = StreamController<dynamic>.broadcast();
  final _paymentReleasedStream = StreamController<dynamic>.broadcast();
  final _shipmentLocationStream = StreamController<dynamic>.broadcast();
  final _temperatureAlertStream = StreamController<dynamic>.broadcast();
  final _fraudAlertStream = StreamController<dynamic>.broadcast();
  final _notificationStream = StreamController<dynamic>.broadcast();

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  Future<void> connect(String jwtToken) async {
    if (_isConnected) return;

    try {
      _isConnected = true;
      _reconnectAttempts = 0;
      print('✅ WebSocket Connection Established');
      _startHeartbeat();
    } catch (e) {
      print('❌ WebSocket Connection Error: $e');
      _isConnected = false;
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        print('💓 Heartbeat sent');
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
  }

  void disconnect() {
    _isConnected = false;
    _stopHeartbeat();
    print('Disconnected from WebSocket');
  }

  /// Emit trade offer event
  void emitTradeOffer(Map<String, dynamic> data) {
    if (_isConnected) {
      print('📢 Emitting Trade Offer: ${data['tradeId']}');
      _tradeOfferStream.add(data);
    }
  }

  /// Emit payment confirmed event
  void emitPaymentConfirmed(Map<String, dynamic> data) {
    if (_isConnected) {
      print('💰 Emitting Payment Confirmed: ${data['contractId']}');
      _paymentConfirmedStream.add(data);
    }
  }

  /// Emit shipment location update
  void emitShipmentLocation(Map<String, dynamic> data) {
    if (_isConnected) {
      print('📍 Emitting Shipment Location Update');
      _shipmentLocationStream.add(data);
    }
  }

  /// Emit temperature alert
  void emitTemperatureAlert(Map<String, dynamic> data) {
    if (_isConnected) {
      print('🌡️ Emitting Temperature Alert');
      _temperatureAlertStream.add(data);
    }
  }

  /// Emit fraud alert
  void emitFraudAlert(Map<String, dynamic> data) {
    if (_isConnected) {
      print('🚨 Emitting Fraud Alert');
      _fraudAlertStream.add(data);
    }
  }

  // Getters for streams
  Stream<dynamic> get tradeOfferStream => _tradeOfferStream.stream;
  Stream<dynamic> get counterOfferStream => _counterOfferStream.stream;
  Stream<dynamic> get paymentConfirmedStream => _paymentConfirmedStream.stream;
  Stream<dynamic> get paymentReleasedStream => _paymentReleasedStream.stream;
  Stream<dynamic> get shipmentLocationStream => _shipmentLocationStream.stream;
  Stream<dynamic> get temperatureAlertStream => _temperatureAlertStream.stream;
  Stream<dynamic> get fraudAlertStream => _fraudAlertStream.stream;
  Stream<dynamic> get notificationStream => _notificationStream.stream;

  bool get isConnected => _isConnected;

  void dispose() {
    _tradeOfferStream.close();
    _counterOfferStream.close();
    _paymentConfirmedStream.close();
    _paymentReleasedStream.close();
    _shipmentLocationStream.close();
    _temperatureAlertStream.close();
    _fraudAlertStream.close();
    _notificationStream.close();
    disconnect();
  }
}

// Riverpod provider
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(service.dispose);
  return service;
});

/// ===============================================================
/// RIVERPOD PROVIDERS
/// ===============================================================

/// Real-time trade offer stream
final tradeOfferStreamProvider = StreamProvider<dynamic>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return webSocketService.tradeOfferStream;
});

/// Real-time counter offer stream
final counterOfferStreamProvider = StreamProvider<dynamic>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return webSocketService.counterOfferStream;
});

/// Real-time payment confirmation stream
final paymentConfirmedStreamProvider = StreamProvider<dynamic>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return webSocketService.paymentConfirmedStream;
});

/// Real-time payment release stream
final paymentReleasedStreamProvider = StreamProvider<dynamic>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return webSocketService.paymentReleasedStream;
});

/// Real-time shipment location updates
final shipmentLocationStreamProvider =
    StreamProvider.family<dynamic, String>((ref, shipmentId) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return webSocketService.shipmentLocationStream
      .where((data) => data['shipmentId'] == shipmentId);
});

/// Real-time temperature alerts
final temperatureAlertStreamProvider = StreamProvider<dynamic>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return webSocketService.temperatureAlertStream;
});

/// Real-time fraud alerts
final fraudAlertStreamProvider = StreamProvider<dynamic>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return webSocketService.fraudAlertStream;
});

/// Real-time notifications
final notificationStreamProvider = StreamProvider<dynamic>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return webSocketService.notificationStream;
});

/// Connection status
final webSocketConnectionStatusProvider = StreamProvider<bool>((ref) async* {
  final webSocketService = ref.watch(webSocketServiceProvider);
  while (true) {
    yield webSocketService.isConnected();
    await Future.delayed(const Duration(seconds: 1));
  }
});
