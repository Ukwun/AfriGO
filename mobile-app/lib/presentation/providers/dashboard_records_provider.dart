import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final dashboardRecordsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, resource) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value(const <Map<String, dynamic>>[]);
  }
  return _liveRecords(resource, user.uid);
});

/// Supports the unified mobile schema and ownership fields already used by the
/// web app, so a participant sees the same authorized activity everywhere.
Stream<List<Map<String, dynamic>>> _liveRecords(String resource, String uid) {
  final fields = switch (resource) {
    'rfqs' => const ['ownerId', 'buyerId'],
    'lots' => const ['ownerId', 'supplierId', 'sellerId'],
    'offers' => const ['ownerId', 'buyerId', 'supplierId', 'exporterId'],
    'contracts' || 'shipments' || 'orders' || 'payments' => const [
        'ownerId',
        'buyerId',
        'supplierId',
        'sellerId',
        'exporterId',
      ],
    _ => const ['ownerId'],
  };
  final collection = FirebaseFirestore.instance.collection(resource);
  final queries = <Query<Map<String, dynamic>>>[
    collection.where('participantIds', arrayContains: uid).limit(50),
    ...fields.map((field) => collection.where(field, isEqualTo: uid).limit(50)),
  ];

  late final StreamController<List<Map<String, dynamic>>> controller;
  final subscriptions =
      <StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>[];
  final snapshots = <int, List<Map<String, dynamic>>>{};
  final settled = <int>{};
  Object? lastError;
  StackTrace? lastStackTrace;

  void publish() {
    final merged = <String, Map<String, dynamic>>{};
    for (final records in snapshots.values) {
      for (final record in records) {
        merged[record['id']?.toString() ?? ''] = record;
      }
    }
    final records = merged.values.toList();
    int milliseconds(dynamic value) =>
        value is Timestamp ? value.millisecondsSinceEpoch : 0;
    records.sort((left, right) => milliseconds(right['createdAt'])
        .compareTo(milliseconds(left['createdAt'])));
    controller.add(records);
  }

  void settle(int index) {
    settled.add(index);
    if (settled.length != queries.length || snapshots.isNotEmpty) return;
    if (lastError != null) {
      controller.addError(lastError!, lastStackTrace);
    } else {
      controller.add(const <Map<String, dynamic>>[]);
    }
  }

  controller = StreamController<List<Map<String, dynamic>>>(
    onListen: () {
      for (var index = 0; index < queries.length; index++) {
        subscriptions.add(queries[index].snapshots().listen(
          (snapshot) {
            snapshots[index] = snapshot.docs
                .map((document) => {'id': document.id, ...document.data()})
                .toList(growable: false);
            settle(index);
            publish();
          },
          onError: (Object error, StackTrace stackTrace) {
            lastError = error;
            lastStackTrace = stackTrace;
            settle(index);
          },
        ));
      }
    },
    onCancel: () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    },
  );
  return controller.stream;
}
