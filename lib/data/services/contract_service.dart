import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/constants.dart';
import '../api_client.dart';

/// Contract Service Provider
final contractServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ContractService(apiClient: apiClient);
});

/// Contract Service
/// Handles digital contract generation, storage, and cryptographic signing
/// All signatures immutable and timestamped
class ContractService {
  final ApiClient apiClient;

  ContractService({required this.apiClient});

  /// Generate contract from trade terms
  /// Automatically creates legally binding contract document
  Future<Map<String, dynamic>> generateContract({
    required String tradeId,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/contracts/generate',
        data: {
          'tradeId': tradeId,
          'generatedAt': DateTime.now().toIso8601String(),
        },
      );

      return {
        'contractId': response['contractId'],
        'contractText': response['contractText'],
        'createdAt': response['createdAt'],
      };
    } catch (e) {
      throw Exception('Failed to generate contract: $e');
    }
  }

  /// Get contract details
  Future<Map<String, dynamic>> getContract(String contractId) async {
    try {
      final response = await apiClient.get('/api/contracts/$contractId');
      return response;
    } catch (e) {
      throw Exception('Failed to get contract: $e');
    }
  }

  /// Get contract by trade ID
  Future<Map<String, dynamic>> getContractByTrade(String tradeId) async {
    try {
      final response = await apiClient.get('/api/trades/$tradeId/contract');
      return response;
    } catch (e) {
      throw Exception('Failed to get trade contract: $e');
    }
  }

  /// Sign contract
  /// Buyer or Seller digitally signs contract
  /// Signature is cryptographically signed with UTC timestamp
  /// Immutable - cannot be modified after signing
  Future<Map<String, dynamic>> signContract({
    required String tradeId,
    String? signatureImage, // Base64 encoded signature image (if e-signature)
    required String signerRole, // 'BUYER' or 'SELLER'
  }) async {
    try {
      final response = await apiClient.post(
        '/api/contracts/$tradeId/sign',
        data: {
          'tradeId': tradeId,
          'signerRole': signerRole,
          'signatureImage': signatureImage,
          'signedAt': DateTime.now().toIso8601String(),
          'signingMethod': 'DIGITAL', // DIGITAL or E_SIGNATURE
        },
      );

      return {
        'contractId': response['contractId'],
        'signatureId': response['signatureId'],
        'cryptographicHash': response['cryptographicHash'],
        'utcTimestamp': response['utcTimestamp'],
        'bothPartiesSigned': response['bothPartiesSigned'],
      };
    } catch (e) {
      throw Exception('Failed to sign contract: $e');
    }
  }

  /// Verify signature authenticity
  /// Check if signature is genuine and hasn't been tampered with
  Future<bool> verifySignature({
    required String contractId,
    required String signatureId,
    required String cryptographicHash,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/contracts/$contractId/verify-signature',
        data: {
          'signatureId': signatureId,
          'cryptographicHash': cryptographicHash,
        },
      );

      return response['isValid'] == true;
    } catch (e) {
      throw Exception('Failed to verify signature: $e');
    }
  }

  /// Get all signatures for contract
  /// Returns immutable log of all signings with timestamps
  Future<List<Map<String, dynamic>>> getContractSignatures(
    String contractId,
  ) async {
    try {
      final response = await apiClient.get(
        '/api/contracts/$contractId/signatures',
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get contract signatures: $e');
    }
  }

  /// Export contract as PDF
  /// Download legally binding PDF copy
  Future<String> exportContractPDF(String contractId) async {
    try {
      final response = await apiClient.get(
        '/api/contracts/$contractId/export-pdf',
      );

      return response['pdfUrl']; // URL to download PDF
    } catch (e) {
      throw Exception('Failed to export PDF: $e');
    }
  }

  /// Get contract status
  /// Shows if contract is DRAFT, PENDING, SIGNED_BY_ONE, FULLY_SIGNED
  Future<String> getContractStatus(String contractId) async {
    try {
      final response = await apiClient.get('/api/contracts/$contractId/status');

      return response['status']; // DRAFT, PENDING, SIGNED_BY_ONE, FULLY_SIGNED
    } catch (e) {
      throw Exception('Failed to get contract status: $e');
    }
  }

  /// Amendment request
  /// If both parties agree, modify contract terms
  Future<void> requestAmendment({
    required String contractId,
    required String field,
    required String newValue,
    required String reason,
  }) async {
    try {
      await apiClient.post(
        '/api/contracts/$contractId/request-amendment',
        data: {
          'field': field,
          'newValue': newValue,
          'reason': reason,
          'requestedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to request amendment: $e');
    }
  }

  /// Approve amendment
  /// Other party approves the amendment
  Future<void> approveAmendment({
    required String contractId,
    required String amendmentId,
  }) async {
    try {
      await apiClient.post(
        '/api/contracts/$contractId/approve-amendment/$amendmentId',
        data: {'approvedAt': DateTime.now().toIso8601String()},
      );
    } catch (e) {
      throw Exception('Failed to approve amendment: $e');
    }
  }

  /// Get contract audit trail
  /// Immutable log of all contract changes, signatures, and amendments
  Future<List<Map<String, dynamic>>> getAuditTrail(String contractId) async {
    try {
      final response = await apiClient.get(
        '/api/contracts/$contractId/audit-trail',
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get audit trail: $e');
    }
  }
}
