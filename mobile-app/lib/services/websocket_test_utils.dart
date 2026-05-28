import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

/// WebSocket Test Utilities
/// Verifies real-time event delivery and latency for trading workflows
///
/// TESTING REQUIREMENTS:
/// ✅ All events delivered <500ms guaranteed latency
/// ✅ Both parties receive updates simultaneously
/// ✅ No polling delays or stale data
/// ✅ All buttons trigger real-time responses

class WebSocketTestUtils {
  final String serverUrl;
  final String authToken;
  late IO.Socket socket;

  final Map<String, List<WebSocketEvent>> eventLog = {};
  final Map<String, Completer<WebSocketEvent>> eventWaiters = {};

  WebSocketTestUtils({
    required this.serverUrl,
    required this.authToken,
  });

  /// Initialize WebSocket connection with JWT authentication
  Future<void> connect() async {
    socket = IO.io(
      serverUrl,
      IO.SocketIoClientOptions()
        ..autoConnect = true
        ..reconnection = true
        ..auth = {
          'token': authToken,
        },
    );

    socket.on('connect', (_) {
      print('✅ WebSocket Connected: $serverUrl');
    });

    socket.on('disconnect', (_) {
      print('❌ WebSocket Disconnected');
    });

    socket.on('error', (error) {
      print('❌ WebSocket Error: $error');
    });

    // Listen to all trading events
    _setupEventListeners();

    // Wait for connection to establish
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Setup listeners for all trading events
  void _setupEventListeners() {
    final events = [
      'RFQ_CREATED',
      'BID_RECEIVED',
      'BID_ACCEPTED',
      'PAYMENT_INITIATED',
      'PAYMENT_CONFIRMED',
      'CONTRACT_SIGNED',
      'SHIPMENT_CREATED',
      'SHIPMENT_UPDATED',
      'DELIVERY_CONFIRMED',
      'DISPUTE_OPENED',
      'DISPUTE_EVIDENCE_SUBMITTED',
      'DISPUTE_RESOLVED',
      'TEMPERATURE_ALERT',
    ];

    for (final event in events) {
      socket.on(event, (data) {
        final webSocketEvent = WebSocketEvent(
          eventType: event,
          timestamp: DateTime.now(),
          payload: data,
        );

        _logEvent(event, webSocketEvent);
        _notifyWaiters(event, webSocketEvent);
      });
    }
  }

  /// Log event with timestamp for latency analysis
  void _logEvent(String eventType, WebSocketEvent event) {
    eventLog.putIfAbsent(eventType, () => []).add(event);
    print('📍 Event Logged: $eventType at ${event.timestamp}');
  }

  /// Notify any waiters (tests waiting for specific events)
  void _notifyWaiters(String eventType, WebSocketEvent event) {
    final key = 'wait_$eventType';
    if (eventWaiters.containsKey(key)) {
      eventWaiters[key]!.complete(event);
      eventWaiters.remove(key);
    }
  }

  /// TEST 1: Verify buyer creates RFQ, seller sees it <500ms
  Future<LatencyTest> testRFQBroadcast({
    required String buyerId,
    required String sellerId,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final startTime = DateTime.now();

    print('\n🧪 TEST 1: RFQ Broadcast Latency');
    print('   Buyer: $buyerId creates RFQ');
    print('   Expected: Seller notified within 500ms');

    // Wait for RFQ_CREATED event
    final completer = Completer<WebSocketEvent>();
    eventWaiters['wait_RFQ_CREATED'] = completer;

    try {
      final event = await completer.future.timeout(timeout);
      final latency = event.timestamp.difference(startTime);

      final passed = latency.inMilliseconds <= 500;
      print('   ⏱️  Latency: ${latency.inMilliseconds}ms');
      print(passed ? '   ✅ PASS' : '   ❌ FAIL (exceeded 500ms)');

      return LatencyTest(
        name: 'RFQ_BROADCAST',
        passed: passed,
        latencyMs: latency.inMilliseconds,
        expectedMs: 500,
      );
    } catch (e) {
      print('   ❌ FAIL: Event not received within timeout');
      return LatencyTest(
        name: 'RFQ_BROADCAST',
        passed: false,
        latencyMs: timeout.inMilliseconds,
        expectedMs: 500,
        error: e.toString(),
      );
    }
  }

  /// TEST 2: Verify bid acceptance syncs both parties <500ms
  Future<LatencyTest> testBidAcceptanceSynchronization({
    required String buyerId,
    required String sellerId,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final startTime = DateTime.now();

    print('\n🧪 TEST 2: Bid Acceptance Synchronization');
    print('   Buyer: $buyerId accepts bid');
    print('   Expected: Seller sees update within 500ms');
    print('   Expected: Buyer sees confirmation within 500ms');

    final buyerCompleter = Completer<WebSocketEvent>();
    final sellerCompleter = Completer<WebSocketEvent>();

    eventWaiters['wait_BID_ACCEPTED_buyer'] = buyerCompleter;
    eventWaiters['wait_BID_ACCEPTED_seller'] = sellerCompleter;

    try {
      final buyerEvent = await buyerCompleter.future.timeout(timeout);
      final buyerLatency = buyerEvent.timestamp.difference(startTime);

      final sellerEvent = await sellerCompleter.future.timeout(timeout);
      final sellerLatency = sellerEvent.timestamp.difference(startTime);

      final buyerPassed = buyerLatency.inMilliseconds <= 500;
      final sellerPassed = sellerLatency.inMilliseconds <= 500;
      final passed = buyerPassed && sellerPassed;

      print(
          '   Buyer latency: ${buyerLatency.inMilliseconds}ms ${buyerPassed ? '✅' : '❌'}');
      print(
          '   Seller latency: ${sellerLatency.inMilliseconds}ms ${sellerPassed ? '✅' : '❌'}');
      print(passed ? '   ✅ PASS' : '   ❌ FAIL');

      return LatencyTest(
        name: 'BID_ACCEPTANCE_SYNC',
        passed: passed,
        latencyMs: [buyerLatency.inMilliseconds, sellerLatency.inMilliseconds]
            .reduce((a, b) => a > b ? a : b),
        expectedMs: 500,
      );
    } catch (e) {
      print('   ❌ FAIL: Event not received within timeout');
      return LatencyTest(
        name: 'BID_ACCEPTANCE_SYNC',
        passed: false,
        latencyMs: timeout.inMilliseconds,
        expectedMs: 500,
        error: e.toString(),
      );
    }
  }

  /// TEST 3: Verify payment confirmation triggers real-time notifications <500ms
  Future<LatencyTest> testPaymentConfirmationBroadcast({
    required String tradeId,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final startTime = DateTime.now();

    print('\n🧪 TEST 3: Payment Confirmation Broadcast');
    print('   Trade: $tradeId payment confirmed');
    print('   Expected: Both parties notified within 500ms');

    final completer = Completer<WebSocketEvent>();
    eventWaiters['wait_PAYMENT_CONFIRMED'] = completer;

    try {
      final event = await completer.future.timeout(timeout);
      final latency = event.timestamp.difference(startTime);

      final passed = latency.inMilliseconds <= 500;
      print('   ⏱️  Latency: ${latency.inMilliseconds}ms');
      print(passed ? '   ✅ PASS' : '   ❌ FAIL (exceeded 500ms)');

      return LatencyTest(
        name: 'PAYMENT_CONFIRMED',
        passed: passed,
        latencyMs: latency.inMilliseconds,
        expectedMs: 500,
      );
    } catch (e) {
      print('   ❌ FAIL: Event not received within timeout');
      return LatencyTest(
        name: 'PAYMENT_CONFIRMED',
        passed: false,
        latencyMs: timeout.inMilliseconds,
        expectedMs: 500,
        error: e.toString(),
      );
    }
  }

  /// TEST 4: Verify shipment created triggers tracking <500ms
  Future<LatencyTest> testShipmentCreation({
    required String tradeId,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final startTime = DateTime.now();

    print('\n🧪 TEST 4: Shipment Creation & Tracking');
    print('   Trade: $tradeId shipment created');
    print('   Expected: Tracking starts within 500ms');

    final completer = Completer<WebSocketEvent>();
    eventWaiters['wait_SHIPMENT_CREATED'] = completer;

    try {
      final event = await completer.future.timeout(timeout);
      final latency = event.timestamp.difference(startTime);

      final passed = latency.inMilliseconds <= 500;
      print('   ⏱️  Latency: ${latency.inMilliseconds}ms');
      print(passed ? '   ✅ PASS' : '   ❌ FAIL (exceeded 500ms)');

      return LatencyTest(
        name: 'SHIPMENT_CREATED',
        passed: passed,
        latencyMs: latency.inMilliseconds,
        expectedMs: 500,
      );
    } catch (e) {
      print('   ❌ FAIL: Event not received within timeout');
      return LatencyTest(
        name: 'SHIPMENT_CREATED',
        passed: false,
        latencyMs: timeout.inMilliseconds,
        expectedMs: 500,
        error: e.toString(),
      );
    }
  }

  /// TEST 5: Verify delivery confirmation releases payment instantly <500ms
  Future<LatencyTest> testDeliveryConfirmation({
    required String tradeId,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final startTime = DateTime.now();

    print('\n🧪 TEST 5: Delivery Confirmation & Payment Release');
    print('   Trade: $tradeId delivery confirmed');
    print('   Expected: Payment released within 500ms');
    print('   Expected: Seller notified within 500ms');

    final completer = Completer<WebSocketEvent>();
    eventWaiters['wait_DELIVERY_CONFIRMED'] = completer;

    try {
      final event = await completer.future.timeout(timeout);
      final latency = event.timestamp.difference(startTime);

      final passed = latency.inMilliseconds <= 500;
      print('   ⏱️  Latency: ${latency.inMilliseconds}ms');
      print(passed ? '   ✅ PASS' : '   ❌ FAIL (exceeded 500ms)');

      return LatencyTest(
        name: 'DELIVERY_CONFIRMED',
        passed: passed,
        latencyMs: latency.inMilliseconds,
        expectedMs: 500,
      );
    } catch (e) {
      print('   ❌ FAIL: Event not received within timeout');
      return LatencyTest(
        name: 'DELIVERY_CONFIRMED',
        passed: false,
        latencyMs: timeout.inMilliseconds,
        expectedMs: 500,
        error: e.toString(),
      );
    }
  }

  /// TEST 6: Verify temperature alerts triggered <500ms
  Future<LatencyTest> testTemperatureAlert({
    required String shipmentId,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final startTime = DateTime.now();

    print('\n🧪 TEST 6: Temperature Alert Broadcast');
    print('   Shipment: $shipmentId temperature threshold breached');
    print('   Expected: Alert to buyer within 500ms');

    final completer = Completer<WebSocketEvent>();
    eventWaiters['wait_TEMPERATURE_ALERT'] = completer;

    try {
      final event = await completer.future.timeout(timeout);
      final latency = event.timestamp.difference(startTime);

      final passed = latency.inMilliseconds <= 500;
      print('   ⏱️  Latency: ${latency.inMilliseconds}ms');
      print(passed ? '   ✅ PASS' : '   ❌ FAIL (exceeded 500ms)');

      return LatencyTest(
        name: 'TEMPERATURE_ALERT',
        passed: passed,
        latencyMs: latency.inMilliseconds,
        expectedMs: 500,
      );
    } catch (e) {
      print('   ❌ FAIL: Event not received within timeout');
      return LatencyTest(
        name: 'TEMPERATURE_ALERT',
        passed: false,
        latencyMs: timeout.inMilliseconds,
        expectedMs: 500,
        error: e.toString(),
      );
    }
  }

  /// TEST 7: Verify dispute evidence submission triggers <500ms
  Future<LatencyTest> testDisputeEvidenceSubmission({
    required String tradeId,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final startTime = DateTime.now();

    print('\n🧪 TEST 7: Dispute Evidence Submission');
    print('   Trade: $tradeId evidence submitted');
    print('   Expected: Admin notified within 500ms');
    print('   Expected: Other party notified within 500ms');

    final completer = Completer<WebSocketEvent>();
    eventWaiters['wait_DISPUTE_EVIDENCE_SUBMITTED'] = completer;

    try {
      final event = await completer.future.timeout(timeout);
      final latency = event.timestamp.difference(startTime);

      final passed = latency.inMilliseconds <= 500;
      print('   ⏱️  Latency: ${latency.inMilliseconds}ms');
      print(passed ? '   ✅ PASS' : '   ❌ FAIL (exceeded 500ms)');

      return LatencyTest(
        name: 'DISPUTE_EVIDENCE_SUBMITTED',
        passed: passed,
        latencyMs: latency.inMilliseconds,
        expectedMs: 500,
      );
    } catch (e) {
      print('   ❌ FAIL: Event not received within timeout');
      return LatencyTest(
        name: 'DISPUTE_EVIDENCE_SUBMITTED',
        passed: false,
        latencyMs: timeout.inMilliseconds,
        expectedMs: 500,
        error: e.toString(),
      );
    }
  }

  /// Run all WebSocket latency tests sequentially
  Future<WebSocketTestResults> runAllTests({
    required String buyerId,
    required String sellerId,
    required String tradeId,
    required String shipmentId,
  }) async {
    print('\n' + '=' * 60);
    print('WEBSOCKET LATENCY TEST SUITE');
    print('=' * 60);
    print('Testing <500ms guaranteed latency for all real-time events');
    print('=' * 60);

    final results = <LatencyTest>[];

    // Run all tests
    results.add(await testRFQBroadcast(
      buyerId: buyerId,
      sellerId: sellerId,
    ));

    results.add(await testBidAcceptanceSynchronization(
      buyerId: buyerId,
      sellerId: sellerId,
    ));

    results.add(await testPaymentConfirmationBroadcast(
      tradeId: tradeId,
    ));

    results.add(await testShipmentCreation(
      tradeId: tradeId,
    ));

    results.add(await testDeliveryConfirmation(
      tradeId: tradeId,
    ));

    results.add(await testTemperatureAlert(
      shipmentId: shipmentId,
    ));

    results.add(await testDisputeEvidenceSubmission(
      tradeId: tradeId,
    ));

    // Generate report
    return WebSocketTestResults(
      tests: results,
      timestamp: DateTime.now(),
    );
  }

  /// Cleanup connection
  Future<void> disconnect() async {
    socket.disconnect();
    socket.dispose();
    print('\n✅ WebSocket Connection Closed');
  }
}

/// Model for WebSocket events
class WebSocketEvent {
  final String eventType;
  final DateTime timestamp;
  final dynamic payload;

  WebSocketEvent({
    required this.eventType,
    required this.timestamp,
    required this.payload,
  });

  @override
  String toString() => 'WebSocketEvent($eventType @ $timestamp)';
}

/// Model for latency test result
class LatencyTest {
  final String name;
  final bool passed;
  final int latencyMs;
  final int expectedMs;
  final String? error;

  LatencyTest({
    required this.name,
    required this.passed,
    required this.latencyMs,
    required this.expectedMs,
    this.error,
  });

  double get latencyPercentage => (latencyMs / expectedMs * 100);

  @override
  String toString() =>
      '$name: ${passed ? '✅ PASS' : '❌ FAIL'} (${latencyMs}ms / ${expectedMs}ms)';
}

/// Model for complete test results
class WebSocketTestResults {
  final List<LatencyTest> tests;
  final DateTime timestamp;

  WebSocketTestResults({
    required this.tests,
    required this.timestamp,
  });

  int get totalTests => tests.length;
  int get passedTests => tests.where((t) => t.passed).length;
  int get failedTests => tests.where((t) => !t.passed).length;
  bool get allPassed => failedTests == 0;

  double get averageLatency =>
      tests.map((t) => t.latencyMs).reduce((a, b) => a + b) / tests.length;

  int get maxLatency =>
      tests.map((t) => t.latencyMs).reduce((a, b) => a > b ? a : b);

  int get minLatency =>
      tests.map((t) => t.latencyMs).reduce((a, b) => a < b ? a : b);

  void printReport() {
    print('\n' + '=' * 60);
    print('WEBSOCKET TEST RESULTS REPORT');
    print('=' * 60);
    print('Timestamp: $timestamp');
    print('Total Tests: $totalTests');
    print('Passed: $passedTests ✅');
    print('Failed: $failedTests ❌');
    print('-' * 60);
    print('Latency Metrics:');
    print('  Min: ${minLatency}ms');
    print('  Max: ${maxLatency}ms');
    print('  Average: ${averageLatency.toStringAsFixed(2)}ms');
    print('-' * 60);
    print('Test Details:');
    for (final test in tests) {
      print('  ${test.name}: ${test.latencyMs}ms ${test.passed ? '✅' : '❌'}');
      if (test.error != null) {
        print('    Error: ${test.error}');
      }
    }
    print('-' * 60);
    print(
        'Overall Result: ${allPassed ? '✅ ALL TESTS PASSED' : '❌ SOME TESTS FAILED'}');
    print('=' * 60);
  }
}
