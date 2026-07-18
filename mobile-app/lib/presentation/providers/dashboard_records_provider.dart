import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final dashboardRecordsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, resource) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const [];
  final query = FirebaseFirestore.instance
      .collection(resource)
      .where('participantIds', arrayContains: user.uid)
      .limit(50);
  QuerySnapshot<Map<String, dynamic>> snapshot;
  try {
    snapshot = await query
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 5));
  } catch (_) {
    snapshot = await query.get(const GetOptions(source: Source.cache));
  }
  final records = snapshot.docs
      .map((document) => {'id': document.id, ...document.data()})
      .toList(growable: false);
  records.sort((left, right) {
    int milliseconds(dynamic value) =>
        value is Timestamp ? value.millisecondsSinceEpoch : 0;
    return milliseconds(right['createdAt'])
        .compareTo(milliseconds(left['createdAt']));
  });
  return records;
});
