import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/dashboard_role.dart';
import 'live_market_activity_provider.dart';

class NotificationReadState {
  const NotificationReadState({
    required this.readByRole,
    this.hydrated = false,
  });

  final Map<DashboardRole, Set<String>> readByRole;
  final bool hydrated;

  Set<String> readIdsFor(DashboardRole role) {
    return readByRole[role] ?? <String>{};
  }

  NotificationReadState copyWith({
    Map<DashboardRole, Set<String>>? readByRole,
    bool? hydrated,
  }) {
    return NotificationReadState(
      readByRole: readByRole ?? this.readByRole,
      hydrated: hydrated ?? this.hydrated,
    );
  }

  static NotificationReadState initial() {
    return const NotificationReadState(
      readByRole: {
        DashboardRole.buyer: <String>{},
        DashboardRole.supplier: <String>{},
        DashboardRole.exporter: <String>{},
      },
      hydrated: false,
    );
  }
}

class NotificationReadNotifier extends StateNotifier<NotificationReadState> {
  NotificationReadNotifier() : super(NotificationReadState.initial()) {
    _load();
  }

  static const String _storageKey = 'notif_read_state_v1';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) {
        state = state.copyWith(hydrated: true);
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        state = state.copyWith(hydrated: true);
        return;
      }

      final readByRole = <DashboardRole, Set<String>>{
        DashboardRole.buyer: _decodeRoleIds(decoded, DashboardRole.buyer),
        DashboardRole.supplier: _decodeRoleIds(decoded, DashboardRole.supplier),
        DashboardRole.exporter: _decodeRoleIds(decoded, DashboardRole.exporter),
      };

      state = state.copyWith(readByRole: readByRole, hydrated: true);
    } catch (_) {
      state = state.copyWith(hydrated: true);
    }
  }

  Set<String> _decodeRoleIds(Map<String, dynamic> json, DashboardRole role) {
    final rawList = json[role.name];
    if (rawList is! List) {
      return <String>{};
    }

    return rawList.whereType<String>().take(300).toSet();
  }

  Future<void> markRead(DashboardRole role, String eventId) async {
    final next = Map<DashboardRole, Set<String>>.from(state.readByRole);
    final existing = Set<String>.from(next[role] ?? <String>{});
    existing.add(eventId);
    next[role] = _trimToRecent(existing);

    state = state.copyWith(readByRole: next);
    await _save();
  }

  Future<void> markAllRead(
    DashboardRole role,
    Iterable<LiveActivityEvent> events,
  ) async {
    final next = Map<DashboardRole, Set<String>>.from(state.readByRole);
    final existing = Set<String>.from(next[role] ?? <String>{});
    for (final event in events) {
      existing.add(event.id);
    }
    next[role] = _trimToRecent(existing);

    state = state.copyWith(readByRole: next);
    await _save();
  }

  Future<void> markManyRead(
    DashboardRole role,
    Iterable<String> eventIds,
  ) async {
    final next = Map<DashboardRole, Set<String>>.from(state.readByRole);
    final existing = Set<String>.from(next[role] ?? <String>{});
    existing.addAll(eventIds);
    next[role] = _trimToRecent(existing);

    state = state.copyWith(readByRole: next);
    await _save();
  }

  Set<String> _trimToRecent(Set<String> input) {
    if (input.length <= 300) {
      return input;
    }

    final items = input.toList();
    return items.sublist(items.length - 300).toSet();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = <String, dynamic>{
        DashboardRole.buyer.name:
            state.readIdsFor(DashboardRole.buyer).toList(growable: false),
        DashboardRole.supplier.name:
            state.readIdsFor(DashboardRole.supplier).toList(growable: false),
        DashboardRole.exporter.name:
            state.readIdsFor(DashboardRole.exporter).toList(growable: false),
      };
      await prefs.setString(_storageKey, jsonEncode(payload));
    } catch (_) {
      // Keep local memory state even when persistence is unavailable.
    }
  }
}

final notificationReadProvider =
    StateNotifierProvider<NotificationReadNotifier, NotificationReadState>(
  (ref) => NotificationReadNotifier(),
);

final roleUnreadNotificationCountProvider =
    Provider.family<int, DashboardRole>((ref, role) {
  final live = ref.watch(liveMarketActivityProvider);
  final readState = ref.watch(notificationReadProvider);
  final seenIds = readState.readIdsFor(role);

  return live.events.where((event) => !seenIds.contains(event.id)).length;
});

final roleUnreadEventIdsProvider =
    Provider.family<Set<String>, DashboardRole>((ref, role) {
  final live = ref.watch(liveMarketActivityProvider);
  final readState = ref.watch(notificationReadProvider);
  final seenIds = readState.readIdsFor(role);

  return live.events
      .where((event) => !seenIds.contains(event.id))
      .map((event) => event.id)
      .toSet();
});
