import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ActivityTrackingEvent - Represents a user activity
class ActivityTrackingEvent {
  final String eventType; // 'screen', 'action', 'error', 'api_call'
  final String action; // 'lot_search', 'bid_submit', 'payment_initiate', etc.
  final Map<String, dynamic>? data;
  final String? deviceType;
  final String? appVersion;
  final String? sessionId;

  ActivityTrackingEvent({
    required this.eventType,
    required this.action,
    this.data,
    this.deviceType = 'mobile',
    this.appVersion = '1.0.0',
    this.sessionId,
  });

  Map<String, dynamic> toJson() => {
        'eventType': eventType,
        'action': action,
        'data': data,
        'deviceType': deviceType,
        'appVersion': appVersion,
        'sessionId': sessionId,
      };
}

/// ActivityTracker - Singleton for tracking user activities
class ActivityTracker {
  static final ActivityTracker _instance = ActivityTracker._internal();
  final List<ActivityTrackingEvent> _eventQueue = [];
  List<ActivityTrackingEvent> get eventQueue => _eventQueue;

  factory ActivityTracker() {
    return _instance;
  }

  ActivityTracker._internal();

  /// Track a screen view
  void trackScreenView(String screenName) {
    _addEvent(ActivityTrackingEvent(
      eventType: 'screen',
      action: 'screen_view',
      data: {'screenName': screenName},
    ));
  }

  /// Track a lot search
  void trackLotSearch(String query, Map<String, dynamic>? filters) {
    _addEvent(ActivityTrackingEvent(
      eventType: 'action',
      action: 'lot_search',
      data: {
        'query': query,
        'filters': filters,
      },
    ));
  }

  /// Track a lot view (user clicks on a lot)
  void trackLotView(String lotId, String productName) {
    _addEvent(ActivityTrackingEvent(
      eventType: 'action',
      action: 'lot_view',
      data: {
        'lotId': lotId,
        'productName': productName,
      },
    ));
  }

  /// Track a bid submission
  void trackBidSubmit(String rfqId, double quotedPrice) {
    _addEvent(ActivityTrackingEvent(
      eventType: 'action',
      action: 'bid_submit',
      data: {
        'rfqId': rfqId,
        'quotedPrice': quotedPrice,
      },
    ));
  }

  /// Track payment initiation
  void trackPaymentInitiate(String orderId, double amount, String status) {
    _addEvent(ActivityTrackingEvent(
      eventType: 'action',
      action: 'payment_initiate',
      data: {
        'orderId': orderId,
        'amount': amount,
        'status': status,
      },
    ));
  }

  /// Track contract action
  void trackContractAction(String contractId, String actionType) {
    _addEvent(ActivityTrackingEvent(
      eventType: 'action',
      action: 'contract_$actionType',
      data: {
        'contractId': contractId,
        'action': actionType,
      },
    ));
  }

  /// Track shipment view
  void trackShipmentView(String shipmentId) {
    _addEvent(ActivityTrackingEvent(
      eventType: 'action',
      action: 'shipment_view',
      data: {
        'shipmentId': shipmentId,
      },
    ));
  }

  /// Track error
  void trackError(String errorMessage, String? stackTrace) {
    _addEvent(ActivityTrackingEvent(
      eventType: 'error',
      action: 'error_occurred',
      data: {
        'errorMessage': errorMessage,
        'stackTrace': stackTrace,
      },
    ));
  }

  /// Track login event
  void trackLogin(String userId) {
    _addEvent(ActivityTrackingEvent(
      eventType: 'action',
      action: 'login',
      data: {
        'userId': userId,
      },
    ));
  }

  /// Track logout event
  void trackLogout() {
    _addEvent(ActivityTrackingEvent(
      eventType: 'action',
      action: 'logout',
    ));
  }

  /// Add event to queue (private)
  void _addEvent(ActivityTrackingEvent event) {
    _eventQueue.add(event);

    // If queue reaches threshold (25 events), flush to server
    if (_eventQueue.length >= 25) {
      flushEvents();
    }
  }

  /// Flush all queued events to server
  /// Called periodically or when queue threshold reached
  Future<void> flushEvents() async {
    if (_eventQueue.isEmpty) return;

    final eventsToSend = List<ActivityTrackingEvent>.from(_eventQueue);
    _eventQueue.clear();

    // Send events to server (will be implemented in actual app)
    // await apiService.recordActivities(eventsToSend);

    // For now, just log
    print('📊 Activity Tracker: Flushed ${eventsToSend.length} events');
  }

  /// Clear all queued events
  void clear() {
    _eventQueue.clear();
  }
}

/// Riverpod provider for activity tracker singleton
final activityTrackerProvider = Provider<ActivityTracker>((ref) {
  return ActivityTracker();
});
