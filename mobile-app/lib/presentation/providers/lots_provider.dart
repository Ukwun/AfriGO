import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/lot_model.dart';

Future<List<LotModel>> _marketplaceLots({String? category}) async {
  final query = FirebaseFirestore.instance
      .collection('lots')
      .where('status', isEqualTo: 'active')
      .limit(100);
  QuerySnapshot<Map<String, dynamic>> snapshot;
  try {
    snapshot = await query
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 5));
  } catch (_) {
    try {
      snapshot = await query.get(const GetOptions(source: Source.cache));
    } catch (_) {
      // A new account may have no local Firestore cache and a device may be
      // offline. The marketplace should render its empty/live-unavailable
      // state instead of failing the entire Explore route.
      return const <LotModel>[];
    }
  }
  return snapshot.docs
      .map((document) => LotModel.fromJson({
            'id': document.id,
            ...document.data(),
          }))
      .where((lot) =>
          category == null ||
          lot.productType.toLowerCase() == category.toLowerCase())
      .toList(growable: false);
}

final lotsProvider = FutureProvider<List<LotModel>>(
  (ref) => _marketplaceLots(),
);

final lotByCategoryProvider =
    FutureProvider.family<List<LotModel>, String>(
  (ref, category) => _marketplaceLots(category: category),
);

final lotDetailProvider =
    FutureProvider.family<LotModel, String>((ref, lotId) async {
  final snapshot =
      await FirebaseFirestore.instance.collection('lots').doc(lotId).get();
  if (!snapshot.exists) throw StateError('Lot not found');
  return LotModel.fromJson({'id': snapshot.id, ...snapshot.data()!});
});
