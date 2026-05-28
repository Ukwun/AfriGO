import 'package:freezed_annotation/freezed_annotation.dart';

part 'quality_model.freezed.dart';
part 'quality_model.g.dart';

@freezed
class QualityInspectionModel with _$QualityInspectionModel {
  const factory QualityInspectionModel({
    required String id,
    required String lotId,
    required String inspectionType,
    required String status,
    String? visualGrade,
    int? visualDefectPercentage,
    List<String>? visualDefectsFound,
    required List<String> inspectionPhotos,
    double? moistureContent,
    double? afflatoxinLevel,
    double? foreignMatterPercentage,
    double? insectFragmentCount,
    double? pH,
    String? bacterialCount,
    String? aiPredictedGrade,
    double? aiConfidenceScore,
    String? finalGrade,
    required bool isApproved,
    String? approvalNotes,
    required DateTime createdAt,
    DateTime? completedAt,
    String? labName,
    String? inspectorName,
  }) = _QualityInspectionModel;

  factory QualityInspectionModel.fromJson(Map<String, dynamic> json) =>
      _$QualityInspectionModelFromJson(json);
}

@freezed
class LabCertificationModel with _$LabCertificationModel {
  const factory LabCertificationModel({
    required String id,
    required String labName,
    required String labCode,
    required String country,
    required String certificationNumber,
    required DateTime issuedDate,
    required DateTime expiryDate,
    required String accreditation,
    required List<String> testingCertifications,
    required String status,
    required String contactEmail,
    required String contactPhone,
    double? costPerTest,
    required int testsCompleted,
    required double averageAccuracy,
  }) = _LabCertificationModel;

  factory LabCertificationModel.fromJson(Map<String, dynamic> json) =>
      _$LabCertificationModelFromJson(json);
}

@freezed
class CreateQualityInspectionRequest with _$CreateQualityInspectionRequest {
  const factory CreateQualityInspectionRequest({
    required String lotId,
    required String inspectionType,
    String? labCertificationId,
    String? inspectorId,
  }) = _CreateQualityInspectionRequest;

  factory CreateQualityInspectionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateQualityInspectionRequestFromJson(json);
}

@freezed
class SubmitVisualInspectionRequest with _$SubmitVisualInspectionRequest {
  const factory SubmitVisualInspectionRequest({
    required String inspectionId,
    required String visualGrade,
    required int visualDefectPercentage,
    List<String>? visualDefectsFound,
    List<String>? inspectionPhotos,
  }) = _SubmitVisualInspectionRequest;

  factory SubmitVisualInspectionRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitVisualInspectionRequestFromJson(json);
}

@freezed
class SubmitLabTestRequest with _$SubmitLabTestRequest {
  const factory SubmitLabTestRequest({
    required String inspectionId,
    double? moistureContent,
    double? afflatoxinLevel,
    double? foreignMatterPercentage,
    double? insectFragmentCount,
    double? pH,
    String? bacterialCount,
    String? labCertificationId,
  }) = _SubmitLabTestRequest;

  factory SubmitLabTestRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitLabTestRequestFromJson(json);
}

@freezed
class ApproveQualityInspectionRequest with _$ApproveQualityInspectionRequest {
  const factory ApproveQualityInspectionRequest({
    required String inspectionId,
    required String finalGrade,
    required bool isApproved,
    String? approvalNotes,
  }) = _ApproveQualityInspectionRequest;

  factory ApproveQualityInspectionRequest.fromJson(Map<String, dynamic> json) =>
      _$ApproveQualityInspectionRequestFromJson(json);
}

@freezed
class QualityStatsModel with _$QualityStatsModel {
  const factory QualityStatsModel({
    required int totalInspections,
    required int approvedCount,
    required int rejectedCount,
    required double avgGradeA,
    required double avgGradeB,
    required double avgGradeC,
    required double avgGradeRejected,
  }) = _QualityStatsModel;

  factory QualityStatsModel.fromJson(Map<String, dynamic> json) =>
      _$QualityStatsModelFromJson(json);
}

@freezed
class AIAnalysisResultModel with _$AIAnalysisResultModel {
  const factory AIAnalysisResultModel({
    required String predictedGrade,
    required double confidence,
    required List<String> defects,
  }) = _AIAnalysisResultModel;

  factory AIAnalysisResultModel.fromJson(Map<String, dynamic> json) =>
      _$AIAnalysisResultModelFromJson(json);
}
