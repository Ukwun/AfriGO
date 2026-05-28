import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/lot.dart';
import '../services/lot_service.dart';

/// Seller Lots Provider
/// Gets seller's lots filtered by status (or all if null)
final sellerLotsProvider = FutureProvider.family<List<Lot>, String?>((
  ref,
  status,
) async {
  final lotService = ref.watch(lotServiceProvider);

  // REAL backend call to get seller's lots
  // Includes:
  // - Real trust score impacts
  // - Real bid counts
  // - Real activity logs
  // - Real QR codes (cryptographic)
  return await lotService.getSellerLots(status: status);
});

/// Lot Detail Provider
/// Gets complete lot information
final lotDetailProvider = FutureProvider.family<Lot, String>((
  ref,
  lotId,
) async {
  final lotService = ref.watch(lotServiceProvider);

  // REAL backend call to get lot detail
  // Includes:
  // - All photos
  // - QR code (cryptographic)
  // - Real-time bids (via WebSocket)
  // - Activity log (immutable)
  // - Trust score impact
  return await lotService.getLotDetail(lotId);
});
