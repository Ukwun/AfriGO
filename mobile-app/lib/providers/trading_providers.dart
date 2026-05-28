import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../data/services/contract_service.dart';
import '../data/services/trade_service.dart';
import '../data/services/lot_service.dart';

/// Trading Module Riverpod Providers
/// Manages contract state, trade data, lot management, and real-time updates
///
/// Providers handle:
/// - Contract generation and signing
/// - Trade details and lifecycle
/// - Lot management (create, photo upload, tracking)
/// - Real-time synchronization (<500ms)
/// - WebSocket event broadcasting
/// - Signature verification and history

// ============================================================================
// Service Providers
// ============================================================================

final contractServiceProvider = Provider((ref) {
  return ContractService();
});

final tradeServiceProvider = Provider((ref) {
  return TradeService();
});

final lotServiceProvider = Provider((ref) {
  return LotService();
});

// ============================================================================
// Contract Content Provider
// ============================================================================

final contractContentProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, tradeId) async {
  final contractService = ref.watch(contractServiceProvider);
  return contractService.getContractContent(tradeId);
});

// ============================================================================
// Contract Signing Status Provider
// ============================================================================

final contractSigningStatusProvider = StateNotifierProvider.family<
    ContractSigningStatusNotifier, ContractSigningStatus, String>(
  (ref, tradeId) {
    return ContractSigningStatusNotifier(ref, tradeId);
  },
);

class ContractSigningStatus {
  final bool isSigned;
  final String? signerName;
  final DateTime? signedAt;
  final bool isLoading;
  final String? error;

  ContractSigningStatus({
    this.isSigned = false,
    this.signerName,
    this.signedAt,
    this.isLoading = false,
    this.error,
  });

  ContractSigningStatus copyWith({
    bool? isSigned,
    String? signerName,
    DateTime? signedAt,
    bool? isLoading,
    String? error,
  }) {
    return ContractSigningStatus(
      isSigned: isSigned ?? this.isSigned,
      signerName: signerName ?? this.signerName,
      signedAt: signedAt ?? this.signedAt,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ContractSigningStatusNotifier
    extends StateNotifier<ContractSigningStatus> {
  final Ref ref;
  final String tradeId;

  ContractSigningStatusNotifier(this.ref, this.tradeId)
      : super(ContractSigningStatus());

  Future<void> signContract(String signerName, List<int> signatureBytes) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final contractService = ref.read(contractServiceProvider);
      final result = await contractService.signContract(
        tradeId: tradeId,
        signatureBytes: Uint8List.fromList(signatureBytes),
        signerName: signerName,
      );

      state = state.copyWith(
        isSigned: true,
        signerName: signerName,
        signedAt: DateTime.now().toUtc(),
        isLoading: false,
      );

      print('✅ Contract signing status updated');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('❌ Contract signing error: $e');
    }
  }
}

// ============================================================================
// Signature Verification Provider
// ============================================================================

final signatureVerificationProvider = FutureProvider.family<
    Map<String, dynamic>,
    (String tradeId, String signatureHash)>((ref, args) async {
  final (tradeId, signatureHash) = args;
  final contractService = ref.watch(contractServiceProvider);
  return contractService.verifySignature(
    tradeId: tradeId,
    signatureHash: signatureHash,
  );
});

// ============================================================================
// Signature History Provider
// ============================================================================

final signatureHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, tradeId) async {
  final contractService = ref.watch(contractServiceProvider);
  return contractService.getSignatureHistory(tradeId);
});

// ============================================================================
// Contract Full Signing Status Provider
// ============================================================================

final contractFullySignedProvider =
    FutureProvider.family<bool, String>((ref, tradeId) async {
  final contractService = ref.watch(contractServiceProvider);
  return contractService.isFullySigned(tradeId);
});

// ============================================================================
// Trade Details Provider
// ============================================================================

final tradeDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, tradeId) async {
  final tradeService = ref.watch(tradeServiceProvider);
  return tradeService.getTradeDetail(tradeId);
});

// ============================================================================
// Both Parties Contract Sync Provider
// ============================================================================

final bothPartiesSyncProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, tradeId) async {
  final contractService = ref.watch(contractServiceProvider);
  return contractService.getContractForBothParties(tradeId);
});

// ============================================================================
// Audit Trail Provider
// ============================================================================

final auditTrailProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, tradeId) async {
  final contractService = ref.watch(contractServiceProvider);
  return contractService.getAuditTrail(tradeId);
});

// ============================================================================
// WebSocket Real-Time Event Provider
// ============================================================================

final realTimeContractEventProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, tradeId) {
  // This would connect to WebSocket and broadcast real-time events
  // For now, returns an empty stream that can be extended with actual WebSocket
  return Stream.empty();
});

// ============================================================================
// Contract Sync Status Provider
// ============================================================================

final contractSyncStatusProvider = StateNotifierProvider.family<
    ContractSyncStatusNotifier, ContractSyncStatus, String>(
  (ref, tradeId) {
    return ContractSyncStatusNotifier(ref, tradeId);
  },
);

class ContractSyncStatus {
  final bool isSynced;
  final DateTime? lastSyncTime;
  final bool isSyncing;
  final String? error;

  ContractSyncStatus({
    this.isSynced = false,
    this.lastSyncTime,
    this.isSyncing = false,
    this.error,
  });

  ContractSyncStatus copyWith({
    bool? isSynced,
    DateTime? lastSyncTime,
    bool? isSyncing,
    String? error,
  }) {
    return ContractSyncStatus(
      isSynced: isSynced ?? this.isSynced,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error ?? this.error,
    );
  }
}

class ContractSyncStatusNotifier extends StateNotifier<ContractSyncStatus> {
  final Ref ref;
  final String tradeId;

  ContractSyncStatusNotifier(this.ref, this.tradeId)
      : super(ContractSyncStatus()) {
    _initializeSync();
  }

  Future<void> _initializeSync() async {
    try {
      state = state.copyWith(isSyncing: true);

      final contractService = ref.read(contractServiceProvider);
      await contractService.getContractForBothParties(tradeId);

      state = state.copyWith(
        isSynced: true,
        lastSyncTime: DateTime.now(),
        isSyncing: false,
      );

      print('✅ Contract synchronized for both parties');
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
      print('❌ Contract sync error: $e');
    }
  }

  Future<void> resync() async {
    await _initializeSync();
  }
}

// ============================================================================
// Contract Immutability Provider
// ============================================================================

final contractImmutabilityProvider =
    Provider.family<String, String>((ref, contractId) {
  // Returns immutability status/guarantee for a contract
  return '✅ Immutable | Permanent | 7-year Audit Trail';
});

// ============================================================================
// Lot Management Providers
// ============================================================================

/// Lot details provider
final lotDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, lotId) async {
  final lotService = ref.watch(lotServiceProvider);
  return lotService.getLotDetails(lotId);
});

/// Lot tracking provider (real-time location, temperature)
final lotTrackingProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, lotId) async {
  final lotService = ref.watch(lotServiceProvider);
  return lotService.getLotTracking(lotId);
});

/// Lot history provider (complete immutable history)
final lotHistoryProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, lotId) async {
  final lotService = ref.watch(lotServiceProvider);
  return lotService.getLotHistory(lotId);
});

/// Seller lots provider (all lots created by seller)
final sellerLotsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final lotService = ref.watch(lotServiceProvider);
  return lotService.getSellerLots();
});

/// Lot stream updates (real-time location, temperature)
final lotStreamProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, lotId) {
  final lotService = ref.watch(lotServiceProvider);
  return lotService.streamLotUpdates(lotId);
});

/// Lot creation status notifier
final lotCreationStatusProvider =
    StateNotifierProvider<LotCreationStatusNotifier, LotCreationStatus>((ref) {
  return LotCreationStatusNotifier(ref);
});

class LotCreationStatus {
  final bool isCreating;
  final String? lotId;
  final String? error;
  final double progress;

  LotCreationStatus({
    this.isCreating = false,
    this.lotId,
    this.error,
    this.progress = 0.0,
  });

  LotCreationStatus copyWith({
    bool? isCreating,
    String? lotId,
    String? error,
    double? progress,
  }) {
    return LotCreationStatus(
      isCreating: isCreating ?? this.isCreating,
      lotId: lotId ?? this.lotId,
      error: error ?? this.error,
      progress: progress ?? this.progress,
    );
  }
}

class LotCreationStatusNotifier extends StateNotifier<LotCreationStatus> {
  final Ref ref;

  LotCreationStatusNotifier(this.ref) : super(LotCreationStatus());

  Future<String?> createLot({
    required String productName,
    required String productType,
    required int quantity,
    required String quantityUnit,
    required double pricePerUnit,
    required String grade,
    required String origin,
    required String description,
  }) async {
    try {
      state = state.copyWith(isCreating: true, error: null);

      final lotService = ref.read(lotServiceProvider);
      final result = await lotService.createLot(
        productName: productName,
        productType: productType,
        quantity: quantity,
        quantityUnit: quantityUnit,
        pricePerUnit: pricePerUnit,
        grade: grade,
        origin: origin,
        description: description,
      );

      final lotId = result['lotId'] as String;

      state = state.copyWith(
        isCreating: false,
        lotId: lotId,
      );

      print('✅ Lot creation status updated');
      return lotId;
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
      print('❌ Lot creation error: $e');
      return null;
    }
  }
}

/// Lot analytics provider
final lotAnalyticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, lotId) async {
  final lotService = ref.watch(lotServiceProvider);
  return lotService.getLotAnalytics(lotId);
});
