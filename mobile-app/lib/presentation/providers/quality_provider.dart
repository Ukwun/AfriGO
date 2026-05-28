import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/quality_model.dart';
import 'auth_provider.dart';

final qualityServiceProvider = Provider((ref) {
  final authService = ref.watch(authServiceProvider);
  return QualityService(authToken: authService.token);
});

final qualityInspectionsProvider =
    FutureProvider.family<List<QualityInspectionModel>, Map<String, dynamic>>(
        (ref, filters) async {
  final service = ref.watch(qualityServiceProvider);
  return service.listInspections(filters);
});

final qualityInspectionProvider =
    FutureProvider.family<QualityInspectionModel, String>(
        (ref, inspectionId) async {
  final service = ref.watch(qualityServiceProvider);
  return service.getInspectionDetails(inspectionId);
});

final lotInspectionsProvider =
    FutureProvider.family<List<QualityInspectionModel>, String>(
        (ref, lotId) async {
  final service = ref.watch(qualityServiceProvider);
  return service.getLotInspections(lotId);
});

final availableLabsProvider =
    FutureProvider.family<List<LabCertificationModel>, String?>(
        (ref, country) async {
  final service = ref.watch(qualityServiceProvider);
  return service.listLabs(country);
});

final qualityStatsProvider = FutureProvider<QualityStatsModel>((ref) async {
  final service = ref.watch(qualityServiceProvider);
  return service.getQualityStats();
});

class QualityService {
  final String? authToken;
  static const String _baseUrl = 'http://localhost:3000';

  QualityService({required this.authToken});

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  /// Create quality inspection
  Future<QualityInspectionModel> createInspection(
      CreateQualityInspectionRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/quality/inspections'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return QualityInspectionModel.fromJson(
            json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create inspection: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating inspection: $e');
    }
  }

  /// Submit visual inspection results
  Future<QualityInspectionModel> submitVisualInspection(
      SubmitVisualInspectionRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/api/quality/inspections/${request.inspectionId}/visual'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return QualityInspectionModel.fromJson(
            json['data'] as Map<String, dynamic>);
      } else {
        throw Exception(
            'Failed to submit visual inspection: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting visual inspection: $e');
    }
  }

  /// Submit lab test results
  Future<QualityInspectionModel> submitLabTest(
      SubmitLabTestRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/api/quality/inspections/${request.inspectionId}/lab-test'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return QualityInspectionModel.fromJson(
            json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to submit lab test: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting lab test: $e');
    }
  }

  /// Approve/reject inspection
  Future<QualityInspectionModel> approveInspection(
      ApproveQualityInspectionRequest request) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$_baseUrl/api/quality/inspections/${request.inspectionId}/approve'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return QualityInspectionModel.fromJson(
            json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to approve inspection: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error approving inspection: $e');
    }
  }

  /// Get inspection details
  Future<QualityInspectionModel> getInspectionDetails(
      String inspectionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/quality/inspections/$inspectionId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return QualityInspectionModel.fromJson(
            json['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Inspection not found');
      } else {
        throw Exception('Failed to load inspection: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading inspection: $e');
    }
  }

  /// Get all inspections for lot
  Future<List<QualityInspectionModel>> getLotInspections(String lotId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/quality/lots/$lotId/inspections'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (json['data'] as List)
            .map((item) =>
                QualityInspectionModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return list;
      } else {
        throw Exception('Failed to load inspections: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading inspections: $e');
    }
  }

  /// List inspections with filtering
  Future<List<QualityInspectionModel>> listInspections(
      Map<String, dynamic> filters) async {
    try {
      final queryParams = _buildQueryString(filters);
      final response = await http.get(
        Uri.parse('$_baseUrl/api/quality/inspections?$queryParams'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (json['data'] as List)
            .map((item) =>
                QualityInspectionModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return list;
      } else {
        throw Exception('Failed to list inspections: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error listing inspections: $e');
    }
  }

  /// List available labs
  Future<List<LabCertificationModel>> listLabs(String? country) async {
    try {
      String url = '$_baseUrl/api/quality/labs';
      if (country != null && country.isNotEmpty) {
        url += '?country=$country';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (json['data'] as List)
            .map((item) =>
                LabCertificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return list;
      } else {
        throw Exception('Failed to list labs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error listing labs: $e');
    }
  }

  /// AI quality analysis
  Future<AIAnalysisResultModel> analyzeWithAI(
      String inspectionId, List<String> imageUrls) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/quality/inspections/$inspectionId/analyze'),
        headers: _headers,
        body: jsonEncode({'imageUrls': imageUrls}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AIAnalysisResultModel.fromJson(
            json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to analyze quality: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing quality: $e');
    }
  }

  /// Get quality report URL
  Future<String> getQualityReport(String inspectionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/quality/inspections/$inspectionId/report'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return json['data']['reportUrl'] as String;
      } else {
        throw Exception('Failed to get report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting report: $e');
    }
  }

  /// Get quality statistics
  Future<QualityStatsModel> getQualityStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/quality/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return QualityStatsModel.fromJson(json['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to get stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting stats: $e');
    }
  }

  String _buildQueryString(Map<String, dynamic> params) {
    final queryParams = params.entries
        .where((e) => e.value != null)
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    return queryParams;
  }
}
