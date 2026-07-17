// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QualityInspectionModelImpl _$$QualityInspectionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$QualityInspectionModelImpl(
      id: json['id'] as String,
      lotId: json['lotId'] as String,
      inspectionType: json['inspectionType'] as String,
      status: json['status'] as String,
      visualGrade: json['visualGrade'] as String?,
      visualDefectPercentage: (json['visualDefectPercentage'] as num?)?.toInt(),
      visualDefectsFound: (json['visualDefectsFound'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      inspectionPhotos: (json['inspectionPhotos'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      moistureContent: (json['moistureContent'] as num?)?.toDouble(),
      afflatoxinLevel: (json['afflatoxinLevel'] as num?)?.toDouble(),
      foreignMatterPercentage:
          (json['foreignMatterPercentage'] as num?)?.toDouble(),
      insectFragmentCount: (json['insectFragmentCount'] as num?)?.toDouble(),
      pH: (json['pH'] as num?)?.toDouble(),
      bacterialCount: json['bacterialCount'] as String?,
      aiPredictedGrade: json['aiPredictedGrade'] as String?,
      aiConfidenceScore: (json['aiConfidenceScore'] as num?)?.toDouble(),
      finalGrade: json['finalGrade'] as String?,
      isApproved: json['isApproved'] as bool,
      approvalNotes: json['approvalNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      labName: json['labName'] as String?,
      inspectorName: json['inspectorName'] as String?,
    );

Map<String, dynamic> _$$QualityInspectionModelImplToJson(
        _$QualityInspectionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lotId': instance.lotId,
      'inspectionType': instance.inspectionType,
      'status': instance.status,
      'visualGrade': instance.visualGrade,
      'visualDefectPercentage': instance.visualDefectPercentage,
      'visualDefectsFound': instance.visualDefectsFound,
      'inspectionPhotos': instance.inspectionPhotos,
      'moistureContent': instance.moistureContent,
      'afflatoxinLevel': instance.afflatoxinLevel,
      'foreignMatterPercentage': instance.foreignMatterPercentage,
      'insectFragmentCount': instance.insectFragmentCount,
      'pH': instance.pH,
      'bacterialCount': instance.bacterialCount,
      'aiPredictedGrade': instance.aiPredictedGrade,
      'aiConfidenceScore': instance.aiConfidenceScore,
      'finalGrade': instance.finalGrade,
      'isApproved': instance.isApproved,
      'approvalNotes': instance.approvalNotes,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'labName': instance.labName,
      'inspectorName': instance.inspectorName,
    };

_$LabCertificationModelImpl _$$LabCertificationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LabCertificationModelImpl(
      id: json['id'] as String,
      labName: json['labName'] as String,
      labCode: json['labCode'] as String,
      country: json['country'] as String,
      certificationNumber: json['certificationNumber'] as String,
      issuedDate: DateTime.parse(json['issuedDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      accreditation: json['accreditation'] as String,
      testingCertifications: (json['testingCertifications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String,
      contactEmail: json['contactEmail'] as String,
      contactPhone: json['contactPhone'] as String,
      costPerTest: (json['costPerTest'] as num?)?.toDouble(),
      testsCompleted: (json['testsCompleted'] as num).toInt(),
      averageAccuracy: (json['averageAccuracy'] as num).toDouble(),
    );

Map<String, dynamic> _$$LabCertificationModelImplToJson(
        _$LabCertificationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'labName': instance.labName,
      'labCode': instance.labCode,
      'country': instance.country,
      'certificationNumber': instance.certificationNumber,
      'issuedDate': instance.issuedDate.toIso8601String(),
      'expiryDate': instance.expiryDate.toIso8601String(),
      'accreditation': instance.accreditation,
      'testingCertifications': instance.testingCertifications,
      'status': instance.status,
      'contactEmail': instance.contactEmail,
      'contactPhone': instance.contactPhone,
      'costPerTest': instance.costPerTest,
      'testsCompleted': instance.testsCompleted,
      'averageAccuracy': instance.averageAccuracy,
    };

_$CreateQualityInspectionRequestImpl
    _$$CreateQualityInspectionRequestImplFromJson(Map<String, dynamic> json) =>
        _$CreateQualityInspectionRequestImpl(
          lotId: json['lotId'] as String,
          inspectionType: json['inspectionType'] as String,
          labCertificationId: json['labCertificationId'] as String?,
          inspectorId: json['inspectorId'] as String?,
        );

Map<String, dynamic> _$$CreateQualityInspectionRequestImplToJson(
        _$CreateQualityInspectionRequestImpl instance) =>
    <String, dynamic>{
      'lotId': instance.lotId,
      'inspectionType': instance.inspectionType,
      'labCertificationId': instance.labCertificationId,
      'inspectorId': instance.inspectorId,
    };

_$SubmitVisualInspectionRequestImpl
    _$$SubmitVisualInspectionRequestImplFromJson(Map<String, dynamic> json) =>
        _$SubmitVisualInspectionRequestImpl(
          inspectionId: json['inspectionId'] as String,
          visualGrade: json['visualGrade'] as String,
          visualDefectPercentage:
              (json['visualDefectPercentage'] as num).toInt(),
          visualDefectsFound: (json['visualDefectsFound'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
          inspectionPhotos: (json['inspectionPhotos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
        );

Map<String, dynamic> _$$SubmitVisualInspectionRequestImplToJson(
        _$SubmitVisualInspectionRequestImpl instance) =>
    <String, dynamic>{
      'inspectionId': instance.inspectionId,
      'visualGrade': instance.visualGrade,
      'visualDefectPercentage': instance.visualDefectPercentage,
      'visualDefectsFound': instance.visualDefectsFound,
      'inspectionPhotos': instance.inspectionPhotos,
    };

_$SubmitLabTestRequestImpl _$$SubmitLabTestRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$SubmitLabTestRequestImpl(
      inspectionId: json['inspectionId'] as String,
      moistureContent: (json['moistureContent'] as num?)?.toDouble(),
      afflatoxinLevel: (json['afflatoxinLevel'] as num?)?.toDouble(),
      foreignMatterPercentage:
          (json['foreignMatterPercentage'] as num?)?.toDouble(),
      insectFragmentCount: (json['insectFragmentCount'] as num?)?.toDouble(),
      pH: (json['pH'] as num?)?.toDouble(),
      bacterialCount: json['bacterialCount'] as String?,
      labCertificationId: json['labCertificationId'] as String?,
    );

Map<String, dynamic> _$$SubmitLabTestRequestImplToJson(
        _$SubmitLabTestRequestImpl instance) =>
    <String, dynamic>{
      'inspectionId': instance.inspectionId,
      'moistureContent': instance.moistureContent,
      'afflatoxinLevel': instance.afflatoxinLevel,
      'foreignMatterPercentage': instance.foreignMatterPercentage,
      'insectFragmentCount': instance.insectFragmentCount,
      'pH': instance.pH,
      'bacterialCount': instance.bacterialCount,
      'labCertificationId': instance.labCertificationId,
    };

_$ApproveQualityInspectionRequestImpl
    _$$ApproveQualityInspectionRequestImplFromJson(Map<String, dynamic> json) =>
        _$ApproveQualityInspectionRequestImpl(
          inspectionId: json['inspectionId'] as String,
          finalGrade: json['finalGrade'] as String,
          isApproved: json['isApproved'] as bool,
          approvalNotes: json['approvalNotes'] as String?,
        );

Map<String, dynamic> _$$ApproveQualityInspectionRequestImplToJson(
        _$ApproveQualityInspectionRequestImpl instance) =>
    <String, dynamic>{
      'inspectionId': instance.inspectionId,
      'finalGrade': instance.finalGrade,
      'isApproved': instance.isApproved,
      'approvalNotes': instance.approvalNotes,
    };

_$QualityStatsModelImpl _$$QualityStatsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$QualityStatsModelImpl(
      totalInspections: (json['totalInspections'] as num).toInt(),
      approvedCount: (json['approvedCount'] as num).toInt(),
      rejectedCount: (json['rejectedCount'] as num).toInt(),
      avgGradeA: (json['avgGradeA'] as num).toDouble(),
      avgGradeB: (json['avgGradeB'] as num).toDouble(),
      avgGradeC: (json['avgGradeC'] as num).toDouble(),
      avgGradeRejected: (json['avgGradeRejected'] as num).toDouble(),
    );

Map<String, dynamic> _$$QualityStatsModelImplToJson(
        _$QualityStatsModelImpl instance) =>
    <String, dynamic>{
      'totalInspections': instance.totalInspections,
      'approvedCount': instance.approvedCount,
      'rejectedCount': instance.rejectedCount,
      'avgGradeA': instance.avgGradeA,
      'avgGradeB': instance.avgGradeB,
      'avgGradeC': instance.avgGradeC,
      'avgGradeRejected': instance.avgGradeRejected,
    };

_$AIAnalysisResultModelImpl _$$AIAnalysisResultModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AIAnalysisResultModelImpl(
      predictedGrade: json['predictedGrade'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      defects:
          (json['defects'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$AIAnalysisResultModelImplToJson(
        _$AIAnalysisResultModelImpl instance) =>
    <String, dynamic>{
      'predictedGrade': instance.predictedGrade,
      'confidence': instance.confidence,
      'defects': instance.defects,
    };
