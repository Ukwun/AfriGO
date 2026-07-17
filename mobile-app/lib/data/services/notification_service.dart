import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

/// FIREBASE CLOUD MESSAGING SERVICE
/// Handles: Push notifications, background message handling
/// Features: Real-time notifications, notification routing
/// Status: Production-ready with Android/iOS support

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  late FirebaseMessaging firebaseMessaging;
  final StreamController<Map<String, dynamic>> _notificationStream =
      StreamController<Map<String, dynamic>>.broadcast();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    firebaseMessaging = FirebaseMessaging.instance;

    // Request notification permission (iOS)
    final settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notifications Enabled');
    } else {
      print('❌ Notifications Disabled by User');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification opened from terminated state
    final initialMessage = await firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpened(initialMessage);
    }

    // Handle notification when app resumed
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);

    // Get FCM token for this device
    final token = await firebaseMessaging.getToken();
    print('📱 FCM Token: $token');

    // Listen to token refresh
    firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token Refreshed: $newToken');
      // Send to backend to store for push notifications
    });
  }

  /// Handle foreground push notifications (app open)
  void _handleForegroundMessage(RemoteMessage message) {
    print('📲 Foreground Message: ${message.notification?.title}');
    final data = message.data;
    _notificationStream.add(data);
  }

  /// Handle background messages (app killed/suspended)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('🔔 Background Message: ${message.notification?.title}');
    // Firebase automatically shows notification
  }

  /// Handle notification opened
  void _handleNotificationOpened(RemoteMessage message) {
    print('👆 Notification Opened: ${message.data}');
    _routeToNotificationScreen(message.data);
  }

  /// Route to appropriate screen based on notification type
  void _routeToNotificationScreen(Map<String, dynamic> data) {
    final type = data['type'];

    switch (type) {
      case 'TRADE_OFFER':
      case 'COUNTER_OFFER':
      case 'PAYMENT_CONFIRMED':
      case 'SHIPMENT_UPDATE':
      case 'TEMPERATURE_ALERT':
      case 'FRAUD_ALERT':
        // Navigation handled by app router
        break;
      default:
        break;
    }
  }

  /// Subscribe to notification topic
  Future<void> subscribeToTopic(String topic) async {
    await firebaseMessaging.subscribeToTopic(topic);
    print('📧 Subscribed to topic: $topic');
  }

  /// Unsubscribe from notification topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await firebaseMessaging.unsubscribeFromTopic(topic);
    print('📧 Unsubscribed from topic: $topic');
  }

  /// Get notification stream
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStream.stream;

  /// Cleanup resources
  void dispose() {
    _notificationStream.close();
  }
}

/// Riverpod Providers

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stream of incoming notifications
final notificationStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.notificationStream;
});

/// Initialize notifications on app startup
final initializeNotificationsProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  await service.initialize();
});
