import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/contract_model.dart';
import '../auth/auth_provider.dart';

final contractServiceProvider = Provider((ref) {
  final authToken = ref.watch(authTokenProvider);
  return ContractService(http.Client(), authToken);
});

// List all contracts for current user
final contractsProvider = FutureProvider.family<
    ({List<ContractListModel> data, int total}),
    ({
      String? status,
      String? type,
      int limit,
      int offset
    })>((ref, params) async {
  final service = ref.watch(contractServiceProvider);
  return service.listContracts(
    status: params.status,
    contractType: params.type,
    limit: params.limit,
    offset: params.offset,
  );
});

// Get single contract details
final contractProvider = FutureProvider.family<
    ContractModel,
    String // contractId
    >((ref, contractId) async {
  final service = ref.watch(contractServiceProvider);
  return service.getContractById(contractId);
});

// Get amendments for a contract
final contractAmendmentsProvider = FutureProvider.family<
    List<ContractAmendmentModel>,
    String // contractId
    >((ref, contractId) async {
  final service = ref.watch(contractServiceProvider);
  return service.getContractAmendments(contractId);
});

// Get contract summary as text
final contractSummaryProvider = FutureProvider.family<
    ContractSummaryModel,
    String // contractId
    >((ref, contractId) async {
  final service = ref.watch(contractServiceProvider);
  return service.getContractSummary(contractId);
});

// Track pending signature deadline
final contractSignatureDaysLeftProvider = FutureProvider.family<
    int, // days remaining
    String // contractId
    >((ref, contractId) async {
  final contract = await ref.watch(contractProvider(contractId).future);
  final daysLeft = contract.signatureDeadline.difference(DateTime.now()).inDays;
  return daysLeft;
});

class ContractService {
  final http.Client _httpClient;
  final String? _authToken;
  final String _baseUrl = 'http://localhost:3000';

  ContractService(this._httpClient, this._authToken);

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken',
      };

  // ============================================================
  // CONTRACT CRUD OPERATIONS
  // ============================================================

  Future<ContractModel> getContractById(String contractId) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/api/contracts/$contractId'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch contract: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return ContractModel.fromJson(json['data']);
  }

  Future<({List<ContractListModel> data, int total})> listContracts({
    String? status,
    String? contractType,
    int limit = 20,
    int offset = 0,
  }) async {
    var url = Uri.parse('$_baseUrl/api/contracts?limit=$limit&offset=$offset');

    if (status != null) {
      url = url
          .replace(queryParameters: {...url.queryParameters, 'status': status});
    }
    if (contractType != null) {
      url = url.replace(queryParameters: {
        ...url.queryParameters,
        'contractType': contractType
      });
    }

    final response = await _httpClient.get(url, headers: _headers());

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch contracts: ${response.body}');
    }

    final json = jsonDecode(response.body);
    final data = (json['data'] as List)
        .map((c) => ContractListModel.fromJson(c))
        .toList();
    final total = json['pagination']['total'] as int;

    return (data: data, total: total);
  }

  Future<ContractModel> createContract(CreateContractRequest request) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/contracts'),
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create contract: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return ContractModel.fromJson(json['data']);
  }

  Future<ContractModel> autoGenerateFromRFQ({
    required String rfqId,
    required String winnerId,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/contracts/auto-generate'),
      headers: _headers(),
      body: jsonEncode({
        'rfqId': rfqId,
        'winnerId': winnerId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to auto-generate contract: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return ContractModel.fromJson(json['data']);
  }

  // ============================================================
  // SIGNATURE OPERATIONS
  // ============================================================

  Future<ContractModel> signContract(SignContractRequest request) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/contracts/${request.contractId}/sign'),
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sign contract: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return ContractModel.fromJson(json['data']);
  }

  // ============================================================
  // AMENDMENT OPERATIONS
  // ============================================================

  Future<ContractAmendmentModel> submitAmendment(
      AmendContractRequest request) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/contracts/${request.contractId}/amend'),
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to submit amendment: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return ContractAmendmentModel.fromJson(json['data']);
  }

  Future<List<ContractAmendmentModel>> getContractAmendments(
      String contractId) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/api/contracts/$contractId/amendments'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch amendments: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return (json['data'] as List)
        .map((a) => ContractAmendmentModel.fromJson(a))
        .toList();
  }

  Future<ContractAmendmentModel> approveAmendment(
      ApproveAmendmentRequest request) async {
    final response = await _httpClient.post(
      Uri.parse(
          '$_baseUrl/api/contracts/amendments/${request.amendmentId}/approve'),
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to approve amendment: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return ContractAmendmentModel.fromJson(json['data']);
  }

  // ============================================================
  // DISPUTE OPERATIONS
  // ============================================================

  Future<ContractModel> initiateDispute(InitiateDisputeRequest request) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/api/contracts/${request.contractId}/dispute'),
      headers: _headers(),
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to initiate dispute: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return ContractModel.fromJson(json['data']);
  }

  // ============================================================
  // UTILITY OPERATIONS
  // ============================================================

  Future<ContractSummaryModel> getContractSummary(String contractId) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/api/contracts/$contractId/summary'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch contract summary: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return ContractSummaryModel(
      text: json['data'] as String,
      generatedAt: DateTime.now(),
    );
  }

  Future<ContractModel> terminateContract({
    required String contractId,
    required String reason,
  }) async {
    final response = await _httpClient.delete(
      Uri.parse('$_baseUrl/api/contracts/$contractId?reason=$reason'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to terminate contract: ${response.body}');
    }

    final json = jsonDecode(response.body);
    return ContractModel.fromJson(json['data']);
  }
}
