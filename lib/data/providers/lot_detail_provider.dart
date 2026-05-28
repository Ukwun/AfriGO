import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/lot.dart';
import '../services/lot_service.dart';

/// Lot Detail Provider
/// Gets complete lot information with real data
final lotDetailProvider = FutureProvider.family<Lot, String>((
  ref,
  lotId,
) async {
  final lotService = ref.watch(lotServiceProvider);

  // REAL backend call to get complete lot details
  // Includes:
  // - All photos from cloud storage
  // - QR code (cryptographic, unforgeable)
  // - Real-time bids (updated via WebSocket)
  // - Activity log (immutable, append-only)
  // - Trust score impact calculation
  // - Seller information
  // - Status tracking
  return await lotService.getLotDetail(lotId);
});
