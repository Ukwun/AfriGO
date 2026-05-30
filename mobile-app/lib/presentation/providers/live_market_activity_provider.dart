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
      : super(
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
        );

  void buyerPostRfq() {
    final nextStats = state.stats.copyWith(openRfqs: state.stats.openRfqs + 1);
    _pushEvent(
      type: LiveEventType.rfqPosted,
      actor: LiveActorRole.buyer,
      title: 'Buyer posted RFQ',
      subtitle: 'Suppliers can now submit quotes immediately.',
      stats: nextStats,
    );
  }

  void supplierSubmitQuote() {
    final nextStats = state.stats.copyWith(
      activeQuotes: state.stats.activeQuotes + 1,
      openRfqs: state.stats.openRfqs > 0 ? state.stats.openRfqs - 1 : 0,
    );
    _pushEvent(
      type: LiveEventType.quoteSubmitted,
      actor: LiveActorRole.supplier,
      title: 'Supplier submitted quote',
      subtitle: 'Buyer received a new counter-ready quote.',
      stats: nextStats,
    );
  }

  void supplierMarkLotReady() {
    final nextStats =
        state.stats.copyWith(readyLots: state.stats.readyLots + 1);
    _pushEvent(
      type: LiveEventType.lotReady,
      actor: LiveActorRole.supplier,
      title: 'Lot marked ready',
      subtitle: 'Exporter can now book shipment and customs prep.',
      stats: nextStats,
    );
  }

  void exporterBookShipment() {
    final nextStats = state.stats.copyWith(
      readyLots: state.stats.readyLots > 0 ? state.stats.readyLots - 1 : 0,
      bookedShipments: state.stats.bookedShipments + 1,
    );
    _pushEvent(
      type: LiveEventType.shipmentBooked,
      actor: LiveActorRole.exporter,
      title: 'Exporter booked shipment',
      subtitle: 'Route locked and buyer ETA updated in real time.',
      stats: nextStats,
    );
  }

  void exporterClearCustoms() {
    final nextStats = state.stats.copyWith(
      bookedShipments:
          state.stats.bookedShipments > 0 ? state.stats.bookedShipments - 1 : 0,
      inCustoms: state.stats.inCustoms + 1,
    );
    _pushEvent(
      type: LiveEventType.customsCleared,
      actor: LiveActorRole.exporter,
      title: 'Customs milestone cleared',
      subtitle: 'Shipment advanced to final-mile release.',
      stats: nextStats,
    );
  }

  void buyerReleasePayment() {
    final nextStats = state.stats.copyWith(
      inCustoms: state.stats.inCustoms > 0 ? state.stats.inCustoms - 1 : 0,
      deliveredToday: state.stats.deliveredToday + 1,
    );
    _pushEvent(
      type: LiveEventType.paymentReleased,
      actor: LiveActorRole.buyer,
      title: 'Buyer released escrow payment',
      subtitle: 'Supplier payout confirmed and transaction closed.',
      stats: nextStats,
    );
  }

  void _pushEvent({
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
}

final liveMarketActivityProvider =
    StateNotifierProvider<LiveMarketActivityNotifier, LiveMarketActivityState>(
  (ref) => LiveMarketActivityNotifier(),
);
