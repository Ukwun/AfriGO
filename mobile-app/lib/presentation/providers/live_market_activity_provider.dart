import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LiveActorRole { buyer, supplier, exporter }

enum LiveEventType {
  rfqPosted,
  quoteSubmitted,
  lotReady,
  shipmentBooked,
  customsCleared,
  paymentReleased,
}

class LiveRoleStats {
  const LiveRoleStats({
    required this.openRfqs,
    required this.activeQuotes,
    required this.readyLots,
    required this.bookedShipments,
    required this.inCustoms,
    required this.deliveredToday,
  });

  final int openRfqs;
  final int activeQuotes;
  final int readyLots;
  final int bookedShipments;
  final int inCustoms;
  final int deliveredToday;

  LiveRoleStats copyWith({
    int? openRfqs,
    int? activeQuotes,
    int? readyLots,
    int? bookedShipments,
    int? inCustoms,
    int? deliveredToday,
  }) {
    return LiveRoleStats(
      openRfqs: openRfqs ?? this.openRfqs,
      activeQuotes: activeQuotes ?? this.activeQuotes,
      readyLots: readyLots ?? this.readyLots,
      bookedShipments: bookedShipments ?? this.bookedShipments,
      inCustoms: inCustoms ?? this.inCustoms,
      deliveredToday: deliveredToday ?? this.deliveredToday,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openRfqs': openRfqs,
      'activeQuotes': activeQuotes,
      'readyLots': readyLots,
      'bookedShipments': bookedShipments,
      'inCustoms': inCustoms,
      'deliveredToday': deliveredToday,
    };
  }

  factory LiveRoleStats.fromJson(Map<dynamic, dynamic> json) {
    int readInt(String key, int fallback) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return fallback;
    }

    return LiveRoleStats(
      openRfqs: readInt('openRfqs', 5),
      activeQuotes: readInt('activeQuotes', 14),
      readyLots: readInt('readyLots', 6),
      bookedShipments: readInt('bookedShipments', 4),
      inCustoms: readInt('inCustoms', 2),
      deliveredToday: readInt('deliveredToday', 3),
    );
  }
}

class LiveActivityEvent {
  const LiveActivityEvent({
    required this.id,
    required this.type,
    required this.actor,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  final String id;
  final LiveEventType type;
  final LiveActorRole actor;
  final String title;
  final String subtitle;
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'actor': actor.name,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LiveActivityEvent.fromJson(Map<String, dynamic> json) {
    final typeRaw = (json['type'] as String?) ?? LiveEventType.rfqPosted.name;
    final actorRaw = (json['actor'] as String?) ?? LiveActorRole.buyer.name;

    return LiveActivityEvent(
      id: (json['id'] as String?) ??
          'evt-${DateTime.now().microsecondsSinceEpoch}',
      type: LiveEventType.values.firstWhere(
        (value) => value.name == typeRaw,
        orElse: () => LiveEventType.rfqPosted,
      ),
      actor: LiveActorRole.values.firstWhere(
        (value) => value.name == actorRaw,
        orElse: () => LiveActorRole.buyer,
      ),
      title: (json['title'] as String?) ?? 'Market update',
      subtitle: (json['subtitle'] as String?) ?? 'New activity detected.',
      timestamp: DateTime.tryParse((json['timestamp'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}

class LiveMarketActivityState {
  const LiveMarketActivityState({
    required this.stats,
    required this.events,
  });

  final LiveRoleStats stats;
  final List<LiveActivityEvent> events;

  LiveMarketActivityState copyWith({
    LiveRoleStats? stats,
    List<LiveActivityEvent>? events,
  }) {
    return LiveMarketActivityState(
      stats: stats ?? this.stats,
      events: events ?? this.events,
    );
  }
}

class LiveMarketActivityNotifier
    extends StateNotifier<LiveMarketActivityState> {
  LiveMarketActivityNotifier()
      : _database = FirebaseDatabase.instance,
        super(
          LiveMarketActivityState(
            stats: const LiveRoleStats(
              openRfqs: 5,
              activeQuotes: 14,
              readyLots: 6,
              bookedShipments: 4,
              inCustoms: 2,
              deliveredToday: 3,
            ),
            events: [
              LiveActivityEvent(
                id: 'evt-boot-1',
                type: LiveEventType.shipmentBooked,
                actor: LiveActorRole.exporter,
                title: 'Shipment slot booked',
                subtitle: 'Exporter locked vessel space for June 2 route.',
                timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
              ),
              LiveActivityEvent(
                id: 'evt-boot-2',
                type: LiveEventType.quoteSubmitted,
                actor: LiveActorRole.supplier,
                title: 'Quote submitted',
                subtitle: 'Supplier responded to Cocoa RFQ in real time.',
                timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
              ),
            ],
          ),
        ) {
    _rootRef = _database.ref('live_market_activity/v1');
    _statsRef = _rootRef.child('stats');
    _eventsRef = _rootRef.child('events');
    unawaited(_initializeSync());
  }

  final FirebaseDatabase _database;
  late final DatabaseReference _rootRef;
  late final DatabaseReference _statsRef;
  late final DatabaseReference _eventsRef;
  StreamSubscription<DatabaseEvent>? _rootSubscription;

  Future<void> _initializeSync() async {
    try {
      final statsSnapshot = await _statsRef.get();
      if (!statsSnapshot.exists) {
        await _statsRef.set(state.stats.toJson());
      }

      _rootSubscription = _rootRef.onValue.listen((event) {
        final raw = event.snapshot.value;
        if (raw is! Map<dynamic, dynamic>) {
          return;
        }

        final statsRaw = raw['stats'];
        final eventsRaw = raw['events'];

        final resolvedStats = statsRaw is Map<dynamic, dynamic>
            ? LiveRoleStats.fromJson(statsRaw)
            : state.stats;

        final resolvedEvents = _decodeEvents(eventsRaw);
        state = state.copyWith(
          stats: resolvedStats,
          events: resolvedEvents.isEmpty ? state.events : resolvedEvents,
        );
      });
    } catch (_) {
      // Keep local-only mode if realtime sync is unavailable.
    }
  }

  List<LiveActivityEvent> _decodeEvents(dynamic eventsRaw) {
    if (eventsRaw is! Map<dynamic, dynamic>) {
      return const [];
    }

    final parsed = eventsRaw.values
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (entry) => LiveActivityEvent.fromJson(
            entry.map((key, value) => MapEntry('$key', value)),
          ),
        )
        .toList(growable: false)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return parsed.take(20).toList(growable: false);
  }

  void buyerPostRfq() {
    _publishEvent(
      type: LiveEventType.rfqPosted,
      actor: LiveActorRole.buyer,
      title: 'Buyer posted RFQ',
      subtitle: 'Suppliers can now submit quotes immediately.',
    );
  }

  void supplierSubmitQuote() {
    _publishEvent(
      type: LiveEventType.quoteSubmitted,
      actor: LiveActorRole.supplier,
      title: 'Supplier submitted quote',
      subtitle: 'Buyer received a new counter-ready quote.',
    );
  }

  void supplierMarkLotReady() {
    _publishEvent(
      type: LiveEventType.lotReady,
      actor: LiveActorRole.supplier,
      title: 'Lot marked ready',
      subtitle: 'Exporter can now book shipment and customs prep.',
    );
  }

  void exporterBookShipment() {
    _publishEvent(
      type: LiveEventType.shipmentBooked,
      actor: LiveActorRole.exporter,
      title: 'Exporter booked shipment',
      subtitle: 'Route locked and buyer ETA updated in real time.',
    );
  }

  void exporterClearCustoms() {
    _publishEvent(
      type: LiveEventType.customsCleared,
      actor: LiveActorRole.exporter,
      title: 'Customs milestone cleared',
      subtitle: 'Shipment advanced to final-mile release.',
    );
  }

  void buyerReleasePayment() {
    _publishEvent(
      type: LiveEventType.paymentReleased,
      actor: LiveActorRole.buyer,
      title: 'Buyer released escrow payment',
      subtitle: 'Supplier payout confirmed and transaction closed.',
    );
  }

  void _publishEvent({
    required LiveEventType type,
    required LiveActorRole actor,
    required String title,
    required String subtitle,
  }) {
    final nextStats = _applyStatMutation(type, state.stats);
    _pushLocal(
      type: type,
      actor: actor,
      title: title,
      subtitle: subtitle,
      stats: nextStats,
    );
    unawaited(_writeRemote(type, actor, title, subtitle));
  }

  LiveRoleStats _applyStatMutation(LiveEventType type, LiveRoleStats current) {
    switch (type) {
      case LiveEventType.rfqPosted:
        return current.copyWith(openRfqs: current.openRfqs + 1);
      case LiveEventType.quoteSubmitted:
        return current.copyWith(
          activeQuotes: current.activeQuotes + 1,
          openRfqs: current.openRfqs > 0 ? current.openRfqs - 1 : 0,
        );
      case LiveEventType.lotReady:
        return current.copyWith(readyLots: current.readyLots + 1);
      case LiveEventType.shipmentBooked:
        return current.copyWith(
          readyLots: current.readyLots > 0 ? current.readyLots - 1 : 0,
          bookedShipments: current.bookedShipments + 1,
        );
      case LiveEventType.customsCleared:
        return current.copyWith(
          bookedShipments:
              current.bookedShipments > 0 ? current.bookedShipments - 1 : 0,
          inCustoms: current.inCustoms + 1,
        );
      case LiveEventType.paymentReleased:
        return current.copyWith(
          inCustoms: current.inCustoms > 0 ? current.inCustoms - 1 : 0,
          deliveredToday: current.deliveredToday + 1,
        );
    }
  }

  Future<void> _writeRemote(
    LiveEventType type,
    LiveActorRole actor,
    String title,
    String subtitle,
  ) async {
    try {
      await _statsRef.runTransaction((value) {
        final currentRaw = value as Map<dynamic, dynamic>?;
        final current = currentRaw == null
            ? state.stats
            : LiveRoleStats.fromJson(currentRaw);
        final next = _applyStatMutation(type, current);
        return Transaction.success(next.toJson());
      });

      final entry = LiveActivityEvent(
        id: 'evt-${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        actor: actor,
        title: title,
        subtitle: subtitle,
        timestamp: DateTime.now(),
      );

      await _eventsRef.push().set(entry.toJson());
    } catch (_) {
      // Local state already updated optimistically.
    }
  }

  void _pushLocal({
    required LiveEventType type,
    required LiveActorRole actor,
    required String title,
    required String subtitle,
    required LiveRoleStats stats,
  }) {
    final entry = LiveActivityEvent(
      id: 'evt-${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      actor: actor,
      title: title,
      subtitle: subtitle,
      timestamp: DateTime.now(),
    );

    final updated = [entry, ...state.events].take(20).toList(growable: false);
    state = state.copyWith(stats: stats, events: updated);
  }

  @override
  void dispose() {
    _rootSubscription?.cancel();
    super.dispose();
  }
}

final liveMarketActivityProvider =
    StateNotifierProvider<LiveMarketActivityNotifier, LiveMarketActivityState>(
  (ref) => LiveMarketActivityNotifier(),
);
