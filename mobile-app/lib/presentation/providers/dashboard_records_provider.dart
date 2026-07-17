import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/api_client.dart';

final dashboardRecordsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, resource) async {
  final response = await ApiClient().get('/$resource');
  final raw = response['data'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .where(
          (item) => (item['id'] ?? item['_id'])?.toString().isNotEmpty == true)
      .toList(growable: false);
});
