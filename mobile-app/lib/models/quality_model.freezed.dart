// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quality_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QualityInspectionModel _$QualityInspectionModelFromJson(
    Map<String, dynamic> json) {
  return _QualityInspectionModel.fromJson(json);
}

/// @nodoc
mixin _$QualityInspectionModel {
  String get id => throw _privateConstructorUsedError;
  String get lotId => throw _privateConstructorUsedError;
  String get inspectionType => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get visualGrade => throw _privateConstructorUsedError;
  int? get visualDefectPercentage => throw _privateConstructorUsedError;
  List<String>? get visualDefectsFound => throw _privateConstructorUsedError;
  List<String> get inspectionPhotos => throw _privateConstructorUsedError;
  double? get moistureContent => throw _privateConstructorUsedError;
  double? get afflatoxinLevel => throw _privateConstructorUsedError;
  double? get foreignMatterPercentage => throw _privateConstructorUsedError;
  double? get insectFragmentCount => throw _privateConstructorUsedError;
  double? get pH => throw _privateConstructorUsedError;
  String? get bacterialCount => throw _privateConstructorUsedError;
  String? get aiPredictedGrade => throw _privateConstructorUsedError;
  double? get aiConfidenceScore => throw _privateConstructorUsedError;
  String? get finalGrade => throw _privateConstructorUsedError;
  bool get isApproved => throw _privateConstructorUsedError;
  String? get approvalNotes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  String? get labName => throw _privateConstructorUsedError;
  String? get inspectorName => throw _privateConstructorUsedError;

  /// Serializes this QualityInspectionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QualityInspectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QualityInspectionModelCopyWith<QualityInspectionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QualityInspectionModelCopyWith<$Res> {
  factory $QualityInspectionModelCopyWith(QualityInspectionModel value,
          $Res Function(QualityInspectionModel) then) =
      _$QualityInspectionModelCopyWithImpl<$Res, QualityInspectionModel>;
  @useResult
  $Res call(
      {String id,
      String lotId,
      String inspectionType,
      String status,
      String? visualGrade,
      int? visualDefectPercentage,
      List<String>? visualDefectsFound,
      List<String> inspectionPhotos,
      double? moistureContent,
      double? afflatoxinLevel,
      double? foreignMatterPercentage,
      double? insectFragmentCount,
      double? pH,
      String? bacterialCount,
      String? aiPredictedGrade,
      double? aiConfidenceScore,
      String? finalGrade,
      bool isApproved,
      String? approvalNotes,
      DateTime createdAt,
      DateTime? completedAt,
      String? labName,
      String? inspectorName});
}

/// @nodoc
class _$QualityInspectionModelCopyWithImpl<$Res,
        $Val extends QualityInspectionModel>
    implements $QualityInspectionModelCopyWith<$Res> {
  _$QualityInspectionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QualityInspectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lotId = null,
    Object? inspectionType = null,
    Object? status = null,
    Object? visualGrade = freezed,
    Object? visualDefectPercentage = freezed,
    Object? visualDefectsFound = freezed,
    Object? inspectionPhotos = null,
    Object? moistureContent = freezed,
    Object? afflatoxinLevel = freezed,
    Object? foreignMatterPercentage = freezed,
    Object? insectFragmentCount = freezed,
    Object? pH = freezed,
    Object? bacterialCount = freezed,
    Object? aiPredictedGrade = freezed,
    Object? aiConfidenceScore = freezed,
    Object? finalGrade = freezed,
    Object? isApproved = null,
    Object? approvalNotes = freezed,
    Object? createdAt = null,
    Object? completedAt = freezed,
    Object? labName = freezed,
    Object? inspectorName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lotId: null == lotId
          ? _value.lotId
          : lotId // ignore: cast_nullable_to_non_nullable
              as String,
      inspectionType: null == inspectionType
          ? _value.inspectionType
          : inspectionType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      visualGrade: freezed == visualGrade
          ? _value.visualGrade
          : visualGrade // ignore: cast_nullable_to_non_nullable
              as String?,
      visualDefectPercentage: freezed == visualDefectPercentage
          ? _value.visualDefectPercentage
          : visualDefectPercentage // ignore: cast_nullable_to_non_nullable
              as int?,
      visualDefectsFound: freezed == visualDefectsFound
          ? _value.visualDefectsFound
          : visualDefectsFound // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      inspectionPhotos: null == inspectionPhotos
          ? _value.inspectionPhotos
          : inspectionPhotos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      moistureContent: freezed == moistureContent
          ? _value.moistureContent
          : moistureContent // ignore: cast_nullable_to_non_nullable
              as double?,
      afflatoxinLevel: freezed == afflatoxinLevel
          ? _value.afflatoxinLevel
          : afflatoxinLevel // ignore: cast_nullable_to_non_nullable
              as double?,
      foreignMatterPercentage: freezed == foreignMatterPercentage
          ? _value.foreignMatterPercentage
          : foreignMatterPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      insectFragmentCount: freezed == insectFragmentCount
          ? _value.insectFragmentCount
          : insectFragmentCount // ignore: cast_nullable_to_non_nullable
              as double?,
      pH: freezed == pH
          ? _value.pH
          : pH // ignore: cast_nullable_to_non_nullable
              as double?,
      bacterialCount: freezed == bacterialCount
          ? _value.bacterialCount
          : bacterialCount // ignore: cast_nullable_to_non_nullable
              as String?,
      aiPredictedGrade: freezed == aiPredictedGrade
          ? _value.aiPredictedGrade
          : aiPredictedGrade // ignore: cast_nullable_to_non_nullable
              as String?,
      aiConfidenceScore: freezed == aiConfidenceScore
          ? _value.aiConfidenceScore
          : aiConfidenceScore // ignore: cast_nullable_to_non_nullable
              as double?,
      finalGrade: freezed == finalGrade
          ? _value.finalGrade
          : finalGrade // ignore: cast_nullable_to_non_nullable
              as String?,
      isApproved: null == isApproved
          ? _value.isApproved
          : isApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      approvalNotes: freezed == approvalNotes
          ? _value.approvalNotes
          : approvalNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      labName: freezed == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String?,
      inspectorName: freezed == inspectorName
          ? _value.inspectorName
          : inspectorName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QualityInspectionModelImplCopyWith<$Res>
    implements $QualityInspectionModelCopyWith<$Res> {
  factory _$$QualityInspectionModelImplCopyWith(
          _$QualityInspectionModelImpl value,
          $Res Function(_$QualityInspectionModelImpl) then) =
      __$$QualityInspectionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String lotId,
      String inspectionType,
      String status,
      String? visualGrade,
      int? visualDefectPercentage,
      List<String>? visualDefectsFound,
      List<String> inspectionPhotos,
      double? moistureContent,
      double? afflatoxinLevel,
      double? foreignMatterPercentage,
      double? insectFragmentCount,
      double? pH,
      String? bacterialCount,
      String? aiPredictedGrade,
      double? aiConfidenceScore,
      String? finalGrade,
      bool isApproved,
      String? approvalNotes,
      DateTime createdAt,
      DateTime? completedAt,
      String? labName,
      String? inspectorName});
}

/// @nodoc
class __$$QualityInspectionModelImplCopyWithImpl<$Res>
    extends _$QualityInspectionModelCopyWithImpl<$Res,
        _$QualityInspectionModelImpl>
    implements _$$QualityInspectionModelImplCopyWith<$Res> {
  __$$QualityInspectionModelImplCopyWithImpl(
      _$QualityInspectionModelImpl _value,
      $Res Function(_$QualityInspectionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of QualityInspectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? lotId = null,
    Object? inspectionType = null,
    Object? status = null,
    Object? visualGrade = freezed,
    Object? visualDefectPercentage = freezed,
    Object? visualDefectsFound = freezed,
    Object? inspectionPhotos = null,
    Object? moistureContent = freezed,
    Object? afflatoxinLevel = freezed,
    Object? foreignMatterPercentage = freezed,
    Object? insectFragmentCount = freezed,
    Object? pH = freezed,
    Object? bacterialCount = freezed,
    Object? aiPredictedGrade = freezed,
    Object? aiConfidenceScore = freezed,
    Object? finalGrade = freezed,
    Object? isApproved = null,
    Object? approvalNotes = freezed,
    Object? createdAt = null,
    Object? completedAt = freezed,
    Object? labName = freezed,
    Object? inspectorName = freezed,
  }) {
    return _then(_$QualityInspectionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      lotId: null == lotId
          ? _value.lotId
          : lotId // ignore: cast_nullable_to_non_nullable
              as String,
      inspectionType: null == inspectionType
          ? _value.inspectionType
          : inspectionType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      visualGrade: freezed == visualGrade
          ? _value.visualGrade
          : visualGrade // ignore: cast_nullable_to_non_nullable
              as String?,
      visualDefectPercentage: freezed == visualDefectPercentage
          ? _value.visualDefectPercentage
          : visualDefectPercentage // ignore: cast_nullable_to_non_nullable
              as int?,
      visualDefectsFound: freezed == visualDefectsFound
          ? _value._visualDefectsFound
          : visualDefectsFound // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      inspectionPhotos: null == inspectionPhotos
          ? _value._inspectionPhotos
          : inspectionPhotos // ignore: cast_nullable_to_non_nullable
              as List<String>,
      moistureContent: freezed == moistureContent
          ? _value.moistureContent
          : moistureContent // ignore: cast_nullable_to_non_nullable
              as double?,
      afflatoxinLevel: freezed == afflatoxinLevel
          ? _value.afflatoxinLevel
          : afflatoxinLevel // ignore: cast_nullable_to_non_nullable
              as double?,
      foreignMatterPercentage: freezed == foreignMatterPercentage
          ? _value.foreignMatterPercentage
          : foreignMatterPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      insectFragmentCount: freezed == insectFragmentCount
          ? _value.insectFragmentCount
          : insectFragmentCount // ignore: cast_nullable_to_non_nullable
              as double?,
      pH: freezed == pH
          ? _value.pH
          : pH // ignore: cast_nullable_to_non_nullable
              as double?,
      bacterialCount: freezed == bacterialCount
          ? _value.bacterialCount
          : bacterialCount // ignore: cast_nullable_to_non_nullable
              as String?,
      aiPredictedGrade: freezed == aiPredictedGrade
          ? _value.aiPredictedGrade
          : aiPredictedGrade // ignore: cast_nullable_to_non_nullable
              as String?,
      aiConfidenceScore: freezed == aiConfidenceScore
          ? _value.aiConfidenceScore
          : aiConfidenceScore // ignore: cast_nullable_to_non_nullable
              as double?,
      finalGrade: freezed == finalGrade
          ? _value.finalGrade
          : finalGrade // ignore: cast_nullable_to_non_nullable
              as String?,
      isApproved: null == isApproved
          ? _value.isApproved
          : isApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      approvalNotes: freezed == approvalNotes
          ? _value.approvalNotes
          : approvalNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      labName: freezed == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String?,
      inspectorName: freezed == inspectorName
          ? _value.inspectorName
          : inspectorName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QualityInspectionModelImpl implements _QualityInspectionModel {
  const _$QualityInspectionModelImpl(
      {required this.id,
      required this.lotId,
      required this.inspectionType,
      required this.status,
      this.visualGrade,
      this.visualDefectPercentage,
      final List<String>? visualDefectsFound,
      required final List<String> inspectionPhotos,
      this.moistureContent,
      this.afflatoxinLevel,
      this.foreignMatterPercentage,
      this.insectFragmentCount,
      this.pH,
      this.bacterialCount,
      this.aiPredictedGrade,
      this.aiConfidenceScore,
      this.finalGrade,
      required this.isApproved,
      this.approvalNotes,
      required this.createdAt,
      this.completedAt,
      this.labName,
      this.inspectorName})
      : _visualDefectsFound = visualDefectsFound,
        _inspectionPhotos = inspectionPhotos;

  factory _$QualityInspectionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$QualityInspectionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String lotId;
  @override
  final String inspectionType;
  @override
  final String status;
  @override
  final String? visualGrade;
  @override
  final int? visualDefectPercentage;
  final List<String>? _visualDefectsFound;
  @override
  List<String>? get visualDefectsFound {
    final value = _visualDefectsFound;
    if (value == null) return null;
    if (_visualDefectsFound is EqualUnmodifiableListView)
      return _visualDefectsFound;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String> _inspectionPhotos;
  @override
  List<String> get inspectionPhotos {
    if (_inspectionPhotos is EqualUnmodifiableListView)
      return _inspectionPhotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_inspectionPhotos);
  }

  @override
  final double? moistureContent;
  @override
  final double? afflatoxinLevel;
  @override
  final double? foreignMatterPercentage;
  @override
  final double? insectFragmentCount;
  @override
  final double? pH;
  @override
  final String? bacterialCount;
  @override
  final String? aiPredictedGrade;
  @override
  final double? aiConfidenceScore;
  @override
  final String? finalGrade;
  @override
  final bool isApproved;
  @override
  final String? approvalNotes;
  @override
  final DateTime createdAt;
  @override
  final DateTime? completedAt;
  @override
  final String? labName;
  @override
  final String? inspectorName;

  @override
  String toString() {
    return 'QualityInspectionModel(id: $id, lotId: $lotId, inspectionType: $inspectionType, status: $status, visualGrade: $visualGrade, visualDefectPercentage: $visualDefectPercentage, visualDefectsFound: $visualDefectsFound, inspectionPhotos: $inspectionPhotos, moistureContent: $moistureContent, afflatoxinLevel: $afflatoxinLevel, foreignMatterPercentage: $foreignMatterPercentage, insectFragmentCount: $insectFragmentCount, pH: $pH, bacterialCount: $bacterialCount, aiPredictedGrade: $aiPredictedGrade, aiConfidenceScore: $aiConfidenceScore, finalGrade: $finalGrade, isApproved: $isApproved, approvalNotes: $approvalNotes, createdAt: $createdAt, completedAt: $completedAt, labName: $labName, inspectorName: $inspectorName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QualityInspectionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.lotId, lotId) || other.lotId == lotId) &&
            (identical(other.inspectionType, inspectionType) ||
                other.inspectionType == inspectionType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.visualGrade, visualGrade) ||
                other.visualGrade == visualGrade) &&
            (identical(other.visualDefectPercentage, visualDefectPercentage) ||
                other.visualDefectPercentage == visualDefectPercentage) &&
            const DeepCollectionEquality()
                .equals(other._visualDefectsFound, _visualDefectsFound) &&
            const DeepCollectionEquality()
                .equals(other._inspectionPhotos, _inspectionPhotos) &&
            (identical(other.moistureContent, moistureContent) ||
                other.moistureContent == moistureContent) &&
            (identical(other.afflatoxinLevel, afflatoxinLevel) ||
                other.afflatoxinLevel == afflatoxinLevel) &&
            (identical(
                    other.foreignMatterPercentage, foreignMatterPercentage) ||
                other.foreignMatterPercentage == foreignMatterPercentage) &&
            (identical(other.insectFragmentCount, insectFragmentCount) ||
                other.insectFragmentCount == insectFragmentCount) &&
            (identical(other.pH, pH) || other.pH == pH) &&
            (identical(other.bacterialCount, bacterialCount) ||
                other.bacterialCount == bacterialCount) &&
            (identical(other.aiPredictedGrade, aiPredictedGrade) ||
                other.aiPredictedGrade == aiPredictedGrade) &&
            (identical(other.aiConfidenceScore, aiConfidenceScore) ||
                other.aiConfidenceScore == aiConfidenceScore) &&
            (identical(other.finalGrade, finalGrade) ||
                other.finalGrade == finalGrade) &&
            (identical(other.isApproved, isApproved) ||
                other.isApproved == isApproved) &&
            (identical(other.approvalNotes, approvalNotes) ||
                other.approvalNotes == approvalNotes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.labName, labName) || other.labName == labName) &&
            (identical(other.inspectorName, inspectorName) ||
                other.inspectorName == inspectorName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        lotId,
        inspectionType,
        status,
        visualGrade,
        visualDefectPercentage,
        const DeepCollectionEquality().hash(_visualDefectsFound),
        const DeepCollectionEquality().hash(_inspectionPhotos),
        moistureContent,
        afflatoxinLevel,
        foreignMatterPercentage,
        insectFragmentCount,
        pH,
        bacterialCount,
        aiPredictedGrade,
        aiConfidenceScore,
        finalGrade,
        isApproved,
        approvalNotes,
        createdAt,
        completedAt,
        labName,
        inspectorName
      ]);

  /// Create a copy of QualityInspectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QualityInspectionModelImplCopyWith<_$QualityInspectionModelImpl>
      get copyWith => __$$QualityInspectionModelImplCopyWithImpl<
          _$QualityInspectionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QualityInspectionModelImplToJson(
      this,
    );
  }
}

abstract class _QualityInspectionModel implements QualityInspectionModel {
  const factory _QualityInspectionModel(
      {required final String id,
      required final String lotId,
      required final String inspectionType,
      required final String status,
      final String? visualGrade,
      final int? visualDefectPercentage,
      final List<String>? visualDefectsFound,
      required final List<String> inspectionPhotos,
      final double? moistureContent,
      final double? afflatoxinLevel,
      final double? foreignMatterPercentage,
      final double? insectFragmentCount,
      final double? pH,
      final String? bacterialCount,
      final String? aiPredictedGrade,
      final double? aiConfidenceScore,
      final String? finalGrade,
      required final bool isApproved,
      final String? approvalNotes,
      required final DateTime createdAt,
      final DateTime? completedAt,
      final String? labName,
      final String? inspectorName}) = _$QualityInspectionModelImpl;

  factory _QualityInspectionModel.fromJson(Map<String, dynamic> json) =
      _$QualityInspectionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get lotId;
  @override
  String get inspectionType;
  @override
  String get status;
  @override
  String? get visualGrade;
  @override
  int? get visualDefectPercentage;
  @override
  List<String>? get visualDefectsFound;
  @override
  List<String> get inspectionPhotos;
  @override
  double? get moistureContent;
  @override
  double? get afflatoxinLevel;
  @override
  double? get foreignMatterPercentage;
  @override
  double? get insectFragmentCount;
  @override
  double? get pH;
  @override
  String? get bacterialCount;
  @override
  String? get aiPredictedGrade;
  @override
  double? get aiConfidenceScore;
  @override
  String? get finalGrade;
  @override
  bool get isApproved;
  @override
  String? get approvalNotes;
  @override
  DateTime get createdAt;
  @override
  DateTime? get completedAt;
  @override
  String? get labName;
  @override
  String? get inspectorName;

  /// Create a copy of QualityInspectionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QualityInspectionModelImplCopyWith<_$QualityInspectionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

LabCertificationModel _$LabCertificationModelFromJson(
    Map<String, dynamic> json) {
  return _LabCertificationModel.fromJson(json);
}

/// @nodoc
mixin _$LabCertificationModel {
  String get id => throw _privateConstructorUsedError;
  String get labName => throw _privateConstructorUsedError;
  String get labCode => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  String get certificationNumber => throw _privateConstructorUsedError;
  DateTime get issuedDate => throw _privateConstructorUsedError;
  DateTime get expiryDate => throw _privateConstructorUsedError;
  String get accreditation => throw _privateConstructorUsedError;
  List<String> get testingCertifications => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get contactEmail => throw _privateConstructorUsedError;
  String get contactPhone => throw _privateConstructorUsedError;
  double? get costPerTest => throw _privateConstructorUsedError;
  int get testsCompleted => throw _privateConstructorUsedError;
  double get averageAccuracy => throw _privateConstructorUsedError;

  /// Serializes this LabCertificationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LabCertificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LabCertificationModelCopyWith<LabCertificationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LabCertificationModelCopyWith<$Res> {
  factory $LabCertificationModelCopyWith(LabCertificationModel value,
          $Res Function(LabCertificationModel) then) =
      _$LabCertificationModelCopyWithImpl<$Res, LabCertificationModel>;
  @useResult
  $Res call(
      {String id,
      String labName,
      String labCode,
      String country,
      String certificationNumber,
      DateTime issuedDate,
      DateTime expiryDate,
      String accreditation,
      List<String> testingCertifications,
      String status,
      String contactEmail,
      String contactPhone,
      double? costPerTest,
      int testsCompleted,
      double averageAccuracy});
}

/// @nodoc
class _$LabCertificationModelCopyWithImpl<$Res,
        $Val extends LabCertificationModel>
    implements $LabCertificationModelCopyWith<$Res> {
  _$LabCertificationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LabCertificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? labName = null,
    Object? labCode = null,
    Object? country = null,
    Object? certificationNumber = null,
    Object? issuedDate = null,
    Object? expiryDate = null,
    Object? accreditation = null,
    Object? testingCertifications = null,
    Object? status = null,
    Object? contactEmail = null,
    Object? contactPhone = null,
    Object? costPerTest = freezed,
    Object? testsCompleted = null,
    Object? averageAccuracy = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      labName: null == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String,
      labCode: null == labCode
          ? _value.labCode
          : labCode // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      certificationNumber: null == certificationNumber
          ? _value.certificationNumber
          : certificationNumber // ignore: cast_nullable_to_non_nullable
              as String,
      issuedDate: null == issuedDate
          ? _value.issuedDate
          : issuedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiryDate: null == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      accreditation: null == accreditation
          ? _value.accreditation
          : accreditation // ignore: cast_nullable_to_non_nullable
              as String,
      testingCertifications: null == testingCertifications
          ? _value.testingCertifications
          : testingCertifications // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      contactEmail: null == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String,
      contactPhone: null == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      costPerTest: freezed == costPerTest
          ? _value.costPerTest
          : costPerTest // ignore: cast_nullable_to_non_nullable
              as double?,
      testsCompleted: null == testsCompleted
          ? _value.testsCompleted
          : testsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LabCertificationModelImplCopyWith<$Res>
    implements $LabCertificationModelCopyWith<$Res> {
  factory _$$LabCertificationModelImplCopyWith(
          _$LabCertificationModelImpl value,
          $Res Function(_$LabCertificationModelImpl) then) =
      __$$LabCertificationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String labName,
      String labCode,
      String country,
      String certificationNumber,
      DateTime issuedDate,
      DateTime expiryDate,
      String accreditation,
      List<String> testingCertifications,
      String status,
      String contactEmail,
      String contactPhone,
      double? costPerTest,
      int testsCompleted,
      double averageAccuracy});
}

/// @nodoc
class __$$LabCertificationModelImplCopyWithImpl<$Res>
    extends _$LabCertificationModelCopyWithImpl<$Res,
        _$LabCertificationModelImpl>
    implements _$$LabCertificationModelImplCopyWith<$Res> {
  __$$LabCertificationModelImplCopyWithImpl(_$LabCertificationModelImpl _value,
      $Res Function(_$LabCertificationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LabCertificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? labName = null,
    Object? labCode = null,
    Object? country = null,
    Object? certificationNumber = null,
    Object? issuedDate = null,
    Object? expiryDate = null,
    Object? accreditation = null,
    Object? testingCertifications = null,
    Object? status = null,
    Object? contactEmail = null,
    Object? contactPhone = null,
    Object? costPerTest = freezed,
    Object? testsCompleted = null,
    Object? averageAccuracy = null,
  }) {
    return _then(_$LabCertificationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      labName: null == labName
          ? _value.labName
          : labName // ignore: cast_nullable_to_non_nullable
              as String,
      labCode: null == labCode
          ? _value.labCode
          : labCode // ignore: cast_nullable_to_non_nullable
              as String,
      country: null == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String,
      certificationNumber: null == certificationNumber
          ? _value.certificationNumber
          : certificationNumber // ignore: cast_nullable_to_non_nullable
              as String,
      issuedDate: null == issuedDate
          ? _value.issuedDate
          : issuedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiryDate: null == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      accreditation: null == accreditation
          ? _value.accreditation
          : accreditation // ignore: cast_nullable_to_non_nullable
              as String,
      testingCertifications: null == testingCertifications
          ? _value._testingCertifications
          : testingCertifications // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      contactEmail: null == contactEmail
          ? _value.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String,
      contactPhone: null == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      costPerTest: freezed == costPerTest
          ? _value.costPerTest
          : costPerTest // ignore: cast_nullable_to_non_nullable
              as double?,
      testsCompleted: null == testsCompleted
          ? _value.testsCompleted
          : testsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      averageAccuracy: null == averageAccuracy
          ? _value.averageAccuracy
          : averageAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LabCertificationModelImpl implements _LabCertificationModel {
  const _$LabCertificationModelImpl(
      {required this.id,
      required this.labName,
      required this.labCode,
      required this.country,
      required this.certificationNumber,
      required this.issuedDate,
      required this.expiryDate,
      required this.accreditation,
      required final List<String> testingCertifications,
      required this.status,
      required this.contactEmail,
      required this.contactPhone,
      this.costPerTest,
      required this.testsCompleted,
      required this.averageAccuracy})
      : _testingCertifications = testingCertifications;

  factory _$LabCertificationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LabCertificationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String labName;
  @override
  final String labCode;
  @override
  final String country;
  @override
  final String certificationNumber;
  @override
  final DateTime issuedDate;
  @override
  final DateTime expiryDate;
  @override
  final String accreditation;
  final List<String> _testingCertifications;
  @override
  List<String> get testingCertifications {
    if (_testingCertifications is EqualUnmodifiableListView)
      return _testingCertifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_testingCertifications);
  }

  @override
  final String status;
  @override
  final String contactEmail;
  @override
  final String contactPhone;
  @override
  final double? costPerTest;
  @override
  final int testsCompleted;
  @override
  final double averageAccuracy;

  @override
  String toString() {
    return 'LabCertificationModel(id: $id, labName: $labName, labCode: $labCode, country: $country, certificationNumber: $certificationNumber, issuedDate: $issuedDate, expiryDate: $expiryDate, accreditation: $accreditation, testingCertifications: $testingCertifications, status: $status, contactEmail: $contactEmail, contactPhone: $contactPhone, costPerTest: $costPerTest, testsCompleted: $testsCompleted, averageAccuracy: $averageAccuracy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LabCertificationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.labName, labName) || other.labName == labName) &&
            (identical(other.labCode, labCode) || other.labCode == labCode) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.certificationNumber, certificationNumber) ||
                other.certificationNumber == certificationNumber) &&
            (identical(other.issuedDate, issuedDate) ||
                other.issuedDate == issuedDate) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.accreditation, accreditation) ||
                other.accreditation == accreditation) &&
            const DeepCollectionEquality()
                .equals(other._testingCertifications, _testingCertifications) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.costPerTest, costPerTest) ||
                other.costPerTest == costPerTest) &&
            (identical(other.testsCompleted, testsCompleted) ||
                other.testsCompleted == testsCompleted) &&
            (identical(other.averageAccuracy, averageAccuracy) ||
                other.averageAccuracy == averageAccuracy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      labName,
      labCode,
      country,
      certificationNumber,
      issuedDate,
      expiryDate,
      accreditation,
      const DeepCollectionEquality().hash(_testingCertifications),
      status,
      contactEmail,
      contactPhone,
      costPerTest,
      testsCompleted,
      averageAccuracy);

  /// Create a copy of LabCertificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LabCertificationModelImplCopyWith<_$LabCertificationModelImpl>
      get copyWith => __$$LabCertificationModelImplCopyWithImpl<
          _$LabCertificationModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LabCertificationModelImplToJson(
      this,
    );
  }
}

abstract class _LabCertificationModel implements LabCertificationModel {
  const factory _LabCertificationModel(
      {required final String id,
      required final String labName,
      required final String labCode,
      required final String country,
      required final String certificationNumber,
      required final DateTime issuedDate,
      required final DateTime expiryDate,
      required final String accreditation,
      required final List<String> testingCertifications,
      required final String status,
      required final String contactEmail,
      required final String contactPhone,
      final double? costPerTest,
      required final int testsCompleted,
      required final double averageAccuracy}) = _$LabCertificationModelImpl;

  factory _LabCertificationModel.fromJson(Map<String, dynamic> json) =
      _$LabCertificationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get labName;
  @override
  String get labCode;
  @override
  String get country;
  @override
  String get certificationNumber;
  @override
  DateTime get issuedDate;
  @override
  DateTime get expiryDate;
  @override
  String get accreditation;
  @override
  List<String> get testingCertifications;
  @override
  String get status;
  @override
  String get contactEmail;
  @override
  String get contactPhone;
  @override
  double? get costPerTest;
  @override
  int get testsCompleted;
  @override
  double get averageAccuracy;

  /// Create a copy of LabCertificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LabCertificationModelImplCopyWith<_$LabCertificationModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CreateQualityInspectionRequest _$CreateQualityInspectionRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateQualityInspectionRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateQualityInspectionRequest {
  String get lotId => throw _privateConstructorUsedError;
  String get inspectionType => throw _privateConstructorUsedError;
  String? get labCertificationId => throw _privateConstructorUsedError;
  String? get inspectorId => throw _privateConstructorUsedError;

  /// Serializes this CreateQualityInspectionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateQualityInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateQualityInspectionRequestCopyWith<CreateQualityInspectionRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateQualityInspectionRequestCopyWith<$Res> {
  factory $CreateQualityInspectionRequestCopyWith(
          CreateQualityInspectionRequest value,
          $Res Function(CreateQualityInspectionRequest) then) =
      _$CreateQualityInspectionRequestCopyWithImpl<$Res,
          CreateQualityInspectionRequest>;
  @useResult
  $Res call(
      {String lotId,
      String inspectionType,
      String? labCertificationId,
      String? inspectorId});
}

/// @nodoc
class _$CreateQualityInspectionRequestCopyWithImpl<$Res,
        $Val extends CreateQualityInspectionRequest>
    implements $CreateQualityInspectionRequestCopyWith<$Res> {
  _$CreateQualityInspectionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateQualityInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lotId = null,
    Object? inspectionType = null,
    Object? labCertificationId = freezed,
    Object? inspectorId = freezed,
  }) {
    return _then(_value.copyWith(
      lotId: null == lotId
          ? _value.lotId
          : lotId // ignore: cast_nullable_to_non_nullable
              as String,
      inspectionType: null == inspectionType
          ? _value.inspectionType
          : inspectionType // ignore: cast_nullable_to_non_nullable
              as String,
      labCertificationId: freezed == labCertificationId
          ? _value.labCertificationId
          : labCertificationId // ignore: cast_nullable_to_non_nullable
              as String?,
      inspectorId: freezed == inspectorId
          ? _value.inspectorId
          : inspectorId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateQualityInspectionRequestImplCopyWith<$Res>
    implements $CreateQualityInspectionRequestCopyWith<$Res> {
  factory _$$CreateQualityInspectionRequestImplCopyWith(
          _$CreateQualityInspectionRequestImpl value,
          $Res Function(_$CreateQualityInspectionRequestImpl) then) =
      __$$CreateQualityInspectionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String lotId,
      String inspectionType,
      String? labCertificationId,
      String? inspectorId});
}

/// @nodoc
class __$$CreateQualityInspectionRequestImplCopyWithImpl<$Res>
    extends _$CreateQualityInspectionRequestCopyWithImpl<$Res,
        _$CreateQualityInspectionRequestImpl>
    implements _$$CreateQualityInspectionRequestImplCopyWith<$Res> {
  __$$CreateQualityInspectionRequestImplCopyWithImpl(
      _$CreateQualityInspectionRequestImpl _value,
      $Res Function(_$CreateQualityInspectionRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateQualityInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lotId = null,
    Object? inspectionType = null,
    Object? labCertificationId = freezed,
    Object? inspectorId = freezed,
  }) {
    return _then(_$CreateQualityInspectionRequestImpl(
      lotId: null == lotId
          ? _value.lotId
          : lotId // ignore: cast_nullable_to_non_nullable
              as String,
      inspectionType: null == inspectionType
          ? _value.inspectionType
          : inspectionType // ignore: cast_nullable_to_non_nullable
              as String,
      labCertificationId: freezed == labCertificationId
          ? _value.labCertificationId
          : labCertificationId // ignore: cast_nullable_to_non_nullable
              as String?,
      inspectorId: freezed == inspectorId
          ? _value.inspectorId
          : inspectorId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateQualityInspectionRequestImpl
    implements _CreateQualityInspectionRequest {
  const _$CreateQualityInspectionRequestImpl(
      {required this.lotId,
      required this.inspectionType,
      this.labCertificationId,
      this.inspectorId});

  factory _$CreateQualityInspectionRequestImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$CreateQualityInspectionRequestImplFromJson(json);

  @override
  final String lotId;
  @override
  final String inspectionType;
  @override
  final String? labCertificationId;
  @override
  final String? inspectorId;

  @override
  String toString() {
    return 'CreateQualityInspectionRequest(lotId: $lotId, inspectionType: $inspectionType, labCertificationId: $labCertificationId, inspectorId: $inspectorId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateQualityInspectionRequestImpl &&
            (identical(other.lotId, lotId) || other.lotId == lotId) &&
            (identical(other.inspectionType, inspectionType) ||
                other.inspectionType == inspectionType) &&
            (identical(other.labCertificationId, labCertificationId) ||
                other.labCertificationId == labCertificationId) &&
            (identical(other.inspectorId, inspectorId) ||
                other.inspectorId == inspectorId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, lotId, inspectionType, labCertificationId, inspectorId);

  /// Create a copy of CreateQualityInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateQualityInspectionRequestImplCopyWith<
          _$CreateQualityInspectionRequestImpl>
      get copyWith => __$$CreateQualityInspectionRequestImplCopyWithImpl<
          _$CreateQualityInspectionRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateQualityInspectionRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateQualityInspectionRequest
    implements CreateQualityInspectionRequest {
  const factory _CreateQualityInspectionRequest(
      {required final String lotId,
      required final String inspectionType,
      final String? labCertificationId,
      final String? inspectorId}) = _$CreateQualityInspectionRequestImpl;

  factory _CreateQualityInspectionRequest.fromJson(Map<String, dynamic> json) =
      _$CreateQualityInspectionRequestImpl.fromJson;

  @override
  String get lotId;
  @override
  String get inspectionType;
  @override
  String? get labCertificationId;
  @override
  String? get inspectorId;

  /// Create a copy of CreateQualityInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateQualityInspectionRequestImplCopyWith<
          _$CreateQualityInspectionRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SubmitVisualInspectionRequest _$SubmitVisualInspectionRequestFromJson(
    Map<String, dynamic> json) {
  return _SubmitVisualInspectionRequest.fromJson(json);
}

/// @nodoc
mixin _$SubmitVisualInspectionRequest {
  String get inspectionId => throw _privateConstructorUsedError;
  String get visualGrade => throw _privateConstructorUsedError;
  int get visualDefectPercentage => throw _privateConstructorUsedError;
  List<String>? get visualDefectsFound => throw _privateConstructorUsedError;
  List<String>? get inspectionPhotos => throw _privateConstructorUsedError;

  /// Serializes this SubmitVisualInspectionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubmitVisualInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmitVisualInspectionRequestCopyWith<SubmitVisualInspectionRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmitVisualInspectionRequestCopyWith<$Res> {
  factory $SubmitVisualInspectionRequestCopyWith(
          SubmitVisualInspectionRequest value,
          $Res Function(SubmitVisualInspectionRequest) then) =
      _$SubmitVisualInspectionRequestCopyWithImpl<$Res,
          SubmitVisualInspectionRequest>;
  @useResult
  $Res call(
      {String inspectionId,
      String visualGrade,
      int visualDefectPercentage,
      List<String>? visualDefectsFound,
      List<String>? inspectionPhotos});
}

/// @nodoc
class _$SubmitVisualInspectionRequestCopyWithImpl<$Res,
        $Val extends SubmitVisualInspectionRequest>
    implements $SubmitVisualInspectionRequestCopyWith<$Res> {
  _$SubmitVisualInspectionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubmitVisualInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inspectionId = null,
    Object? visualGrade = null,
    Object? visualDefectPercentage = null,
    Object? visualDefectsFound = freezed,
    Object? inspectionPhotos = freezed,
  }) {
    return _then(_value.copyWith(
      inspectionId: null == inspectionId
          ? _value.inspectionId
          : inspectionId // ignore: cast_nullable_to_non_nullable
              as String,
      visualGrade: null == visualGrade
          ? _value.visualGrade
          : visualGrade // ignore: cast_nullable_to_non_nullable
              as String,
      visualDefectPercentage: null == visualDefectPercentage
          ? _value.visualDefectPercentage
          : visualDefectPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      visualDefectsFound: freezed == visualDefectsFound
          ? _value.visualDefectsFound
          : visualDefectsFound // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      inspectionPhotos: freezed == inspectionPhotos
          ? _value.inspectionPhotos
          : inspectionPhotos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubmitVisualInspectionRequestImplCopyWith<$Res>
    implements $SubmitVisualInspectionRequestCopyWith<$Res> {
  factory _$$SubmitVisualInspectionRequestImplCopyWith(
          _$SubmitVisualInspectionRequestImpl value,
          $Res Function(_$SubmitVisualInspectionRequestImpl) then) =
      __$$SubmitVisualInspectionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String inspectionId,
      String visualGrade,
      int visualDefectPercentage,
      List<String>? visualDefectsFound,
      List<String>? inspectionPhotos});
}

/// @nodoc
class __$$SubmitVisualInspectionRequestImplCopyWithImpl<$Res>
    extends _$SubmitVisualInspectionRequestCopyWithImpl<$Res,
        _$SubmitVisualInspectionRequestImpl>
    implements _$$SubmitVisualInspectionRequestImplCopyWith<$Res> {
  __$$SubmitVisualInspectionRequestImplCopyWithImpl(
      _$SubmitVisualInspectionRequestImpl _value,
      $Res Function(_$SubmitVisualInspectionRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubmitVisualInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inspectionId = null,
    Object? visualGrade = null,
    Object? visualDefectPercentage = null,
    Object? visualDefectsFound = freezed,
    Object? inspectionPhotos = freezed,
  }) {
    return _then(_$SubmitVisualInspectionRequestImpl(
      inspectionId: null == inspectionId
          ? _value.inspectionId
          : inspectionId // ignore: cast_nullable_to_non_nullable
              as String,
      visualGrade: null == visualGrade
          ? _value.visualGrade
          : visualGrade // ignore: cast_nullable_to_non_nullable
              as String,
      visualDefectPercentage: null == visualDefectPercentage
          ? _value.visualDefectPercentage
          : visualDefectPercentage // ignore: cast_nullable_to_non_nullable
              as int,
      visualDefectsFound: freezed == visualDefectsFound
          ? _value._visualDefectsFound
          : visualDefectsFound // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      inspectionPhotos: freezed == inspectionPhotos
          ? _value._inspectionPhotos
          : inspectionPhotos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmitVisualInspectionRequestImpl
    implements _SubmitVisualInspectionRequest {
  const _$SubmitVisualInspectionRequestImpl(
      {required this.inspectionId,
      required this.visualGrade,
      required this.visualDefectPercentage,
      final List<String>? visualDefectsFound,
      final List<String>? inspectionPhotos})
      : _visualDefectsFound = visualDefectsFound,
        _inspectionPhotos = inspectionPhotos;

  factory _$SubmitVisualInspectionRequestImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$SubmitVisualInspectionRequestImplFromJson(json);

  @override
  final String inspectionId;
  @override
  final String visualGrade;
  @override
  final int visualDefectPercentage;
  final List<String>? _visualDefectsFound;
  @override
  List<String>? get visualDefectsFound {
    final value = _visualDefectsFound;
    if (value == null) return null;
    if (_visualDefectsFound is EqualUnmodifiableListView)
      return _visualDefectsFound;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _inspectionPhotos;
  @override
  List<String>? get inspectionPhotos {
    final value = _inspectionPhotos;
    if (value == null) return null;
    if (_inspectionPhotos is EqualUnmodifiableListView)
      return _inspectionPhotos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'SubmitVisualInspectionRequest(inspectionId: $inspectionId, visualGrade: $visualGrade, visualDefectPercentage: $visualDefectPercentage, visualDefectsFound: $visualDefectsFound, inspectionPhotos: $inspectionPhotos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitVisualInspectionRequestImpl &&
            (identical(other.inspectionId, inspectionId) ||
                other.inspectionId == inspectionId) &&
            (identical(other.visualGrade, visualGrade) ||
                other.visualGrade == visualGrade) &&
            (identical(other.visualDefectPercentage, visualDefectPercentage) ||
                other.visualDefectPercentage == visualDefectPercentage) &&
            const DeepCollectionEquality()
                .equals(other._visualDefectsFound, _visualDefectsFound) &&
            const DeepCollectionEquality()
                .equals(other._inspectionPhotos, _inspectionPhotos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      inspectionId,
      visualGrade,
      visualDefectPercentage,
      const DeepCollectionEquality().hash(_visualDefectsFound),
      const DeepCollectionEquality().hash(_inspectionPhotos));

  /// Create a copy of SubmitVisualInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitVisualInspectionRequestImplCopyWith<
          _$SubmitVisualInspectionRequestImpl>
      get copyWith => __$$SubmitVisualInspectionRequestImplCopyWithImpl<
          _$SubmitVisualInspectionRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmitVisualInspectionRequestImplToJson(
      this,
    );
  }
}

abstract class _SubmitVisualInspectionRequest
    implements SubmitVisualInspectionRequest {
  const factory _SubmitVisualInspectionRequest(
          {required final String inspectionId,
          required final String visualGrade,
          required final int visualDefectPercentage,
          final List<String>? visualDefectsFound,
          final List<String>? inspectionPhotos}) =
      _$SubmitVisualInspectionRequestImpl;

  factory _SubmitVisualInspectionRequest.fromJson(Map<String, dynamic> json) =
      _$SubmitVisualInspectionRequestImpl.fromJson;

  @override
  String get inspectionId;
  @override
  String get visualGrade;
  @override
  int get visualDefectPercentage;
  @override
  List<String>? get visualDefectsFound;
  @override
  List<String>? get inspectionPhotos;

  /// Create a copy of SubmitVisualInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmitVisualInspectionRequestImplCopyWith<
          _$SubmitVisualInspectionRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

SubmitLabTestRequest _$SubmitLabTestRequestFromJson(Map<String, dynamic> json) {
  return _SubmitLabTestRequest.fromJson(json);
}

/// @nodoc
mixin _$SubmitLabTestRequest {
  String get inspectionId => throw _privateConstructorUsedError;
  double? get moistureContent => throw _privateConstructorUsedError;
  double? get afflatoxinLevel => throw _privateConstructorUsedError;
  double? get foreignMatterPercentage => throw _privateConstructorUsedError;
  double? get insectFragmentCount => throw _privateConstructorUsedError;
  double? get pH => throw _privateConstructorUsedError;
  String? get bacterialCount => throw _privateConstructorUsedError;
  String? get labCertificationId => throw _privateConstructorUsedError;

  /// Serializes this SubmitLabTestRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubmitLabTestRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmitLabTestRequestCopyWith<SubmitLabTestRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmitLabTestRequestCopyWith<$Res> {
  factory $SubmitLabTestRequestCopyWith(SubmitLabTestRequest value,
          $Res Function(SubmitLabTestRequest) then) =
      _$SubmitLabTestRequestCopyWithImpl<$Res, SubmitLabTestRequest>;
  @useResult
  $Res call(
      {String inspectionId,
      double? moistureContent,
      double? afflatoxinLevel,
      double? foreignMatterPercentage,
      double? insectFragmentCount,
      double? pH,
      String? bacterialCount,
      String? labCertificationId});
}

/// @nodoc
class _$SubmitLabTestRequestCopyWithImpl<$Res,
        $Val extends SubmitLabTestRequest>
    implements $SubmitLabTestRequestCopyWith<$Res> {
  _$SubmitLabTestRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubmitLabTestRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inspectionId = null,
    Object? moistureContent = freezed,
    Object? afflatoxinLevel = freezed,
    Object? foreignMatterPercentage = freezed,
    Object? insectFragmentCount = freezed,
    Object? pH = freezed,
    Object? bacterialCount = freezed,
    Object? labCertificationId = freezed,
  }) {
    return _then(_value.copyWith(
      inspectionId: null == inspectionId
          ? _value.inspectionId
          : inspectionId // ignore: cast_nullable_to_non_nullable
              as String,
      moistureContent: freezed == moistureContent
          ? _value.moistureContent
          : moistureContent // ignore: cast_nullable_to_non_nullable
              as double?,
      afflatoxinLevel: freezed == afflatoxinLevel
          ? _value.afflatoxinLevel
          : afflatoxinLevel // ignore: cast_nullable_to_non_nullable
              as double?,
      foreignMatterPercentage: freezed == foreignMatterPercentage
          ? _value.foreignMatterPercentage
          : foreignMatterPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      insectFragmentCount: freezed == insectFragmentCount
          ? _value.insectFragmentCount
          : insectFragmentCount // ignore: cast_nullable_to_non_nullable
              as double?,
      pH: freezed == pH
          ? _value.pH
          : pH // ignore: cast_nullable_to_non_nullable
              as double?,
      bacterialCount: freezed == bacterialCount
          ? _value.bacterialCount
          : bacterialCount // ignore: cast_nullable_to_non_nullable
              as String?,
      labCertificationId: freezed == labCertificationId
          ? _value.labCertificationId
          : labCertificationId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubmitLabTestRequestImplCopyWith<$Res>
    implements $SubmitLabTestRequestCopyWith<$Res> {
  factory _$$SubmitLabTestRequestImplCopyWith(_$SubmitLabTestRequestImpl value,
          $Res Function(_$SubmitLabTestRequestImpl) then) =
      __$$SubmitLabTestRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String inspectionId,
      double? moistureContent,
      double? afflatoxinLevel,
      double? foreignMatterPercentage,
      double? insectFragmentCount,
      double? pH,
      String? bacterialCount,
      String? labCertificationId});
}

/// @nodoc
class __$$SubmitLabTestRequestImplCopyWithImpl<$Res>
    extends _$SubmitLabTestRequestCopyWithImpl<$Res, _$SubmitLabTestRequestImpl>
    implements _$$SubmitLabTestRequestImplCopyWith<$Res> {
  __$$SubmitLabTestRequestImplCopyWithImpl(_$SubmitLabTestRequestImpl _value,
      $Res Function(_$SubmitLabTestRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubmitLabTestRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inspectionId = null,
    Object? moistureContent = freezed,
    Object? afflatoxinLevel = freezed,
    Object? foreignMatterPercentage = freezed,
    Object? insectFragmentCount = freezed,
    Object? pH = freezed,
    Object? bacterialCount = freezed,
    Object? labCertificationId = freezed,
  }) {
    return _then(_$SubmitLabTestRequestImpl(
      inspectionId: null == inspectionId
          ? _value.inspectionId
          : inspectionId // ignore: cast_nullable_to_non_nullable
              as String,
      moistureContent: freezed == moistureContent
          ? _value.moistureContent
          : moistureContent // ignore: cast_nullable_to_non_nullable
              as double?,
      afflatoxinLevel: freezed == afflatoxinLevel
          ? _value.afflatoxinLevel
          : afflatoxinLevel // ignore: cast_nullable_to_non_nullable
              as double?,
      foreignMatterPercentage: freezed == foreignMatterPercentage
          ? _value.foreignMatterPercentage
          : foreignMatterPercentage // ignore: cast_nullable_to_non_nullable
              as double?,
      insectFragmentCount: freezed == insectFragmentCount
          ? _value.insectFragmentCount
          : insectFragmentCount // ignore: cast_nullable_to_non_nullable
              as double?,
      pH: freezed == pH
          ? _value.pH
          : pH // ignore: cast_nullable_to_non_nullable
              as double?,
      bacterialCount: freezed == bacterialCount
          ? _value.bacterialCount
          : bacterialCount // ignore: cast_nullable_to_non_nullable
              as String?,
      labCertificationId: freezed == labCertificationId
          ? _value.labCertificationId
          : labCertificationId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmitLabTestRequestImpl implements _SubmitLabTestRequest {
  const _$SubmitLabTestRequestImpl(
      {required this.inspectionId,
      this.moistureContent,
      this.afflatoxinLevel,
      this.foreignMatterPercentage,
      this.insectFragmentCount,
      this.pH,
      this.bacterialCount,
      this.labCertificationId});

  factory _$SubmitLabTestRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubmitLabTestRequestImplFromJson(json);

  @override
  final String inspectionId;
  @override
  final double? moistureContent;
  @override
  final double? afflatoxinLevel;
  @override
  final double? foreignMatterPercentage;
  @override
  final double? insectFragmentCount;
  @override
  final double? pH;
  @override
  final String? bacterialCount;
  @override
  final String? labCertificationId;

  @override
  String toString() {
    return 'SubmitLabTestRequest(inspectionId: $inspectionId, moistureContent: $moistureContent, afflatoxinLevel: $afflatoxinLevel, foreignMatterPercentage: $foreignMatterPercentage, insectFragmentCount: $insectFragmentCount, pH: $pH, bacterialCount: $bacterialCount, labCertificationId: $labCertificationId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmitLabTestRequestImpl &&
            (identical(other.inspectionId, inspectionId) ||
                other.inspectionId == inspectionId) &&
            (identical(other.moistureContent, moistureContent) ||
                other.moistureContent == moistureContent) &&
            (identical(other.afflatoxinLevel, afflatoxinLevel) ||
                other.afflatoxinLevel == afflatoxinLevel) &&
            (identical(
                    other.foreignMatterPercentage, foreignMatterPercentage) ||
                other.foreignMatterPercentage == foreignMatterPercentage) &&
            (identical(other.insectFragmentCount, insectFragmentCount) ||
                other.insectFragmentCount == insectFragmentCount) &&
            (identical(other.pH, pH) || other.pH == pH) &&
            (identical(other.bacterialCount, bacterialCount) ||
                other.bacterialCount == bacterialCount) &&
            (identical(other.labCertificationId, labCertificationId) ||
                other.labCertificationId == labCertificationId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      inspectionId,
      moistureContent,
      afflatoxinLevel,
      foreignMatterPercentage,
      insectFragmentCount,
      pH,
      bacterialCount,
      labCertificationId);

  /// Create a copy of SubmitLabTestRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmitLabTestRequestImplCopyWith<_$SubmitLabTestRequestImpl>
      get copyWith =>
          __$$SubmitLabTestRequestImplCopyWithImpl<_$SubmitLabTestRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmitLabTestRequestImplToJson(
      this,
    );
  }
}

abstract class _SubmitLabTestRequest implements SubmitLabTestRequest {
  const factory _SubmitLabTestRequest(
      {required final String inspectionId,
      final double? moistureContent,
      final double? afflatoxinLevel,
      final double? foreignMatterPercentage,
      final double? insectFragmentCount,
      final double? pH,
      final String? bacterialCount,
      final String? labCertificationId}) = _$SubmitLabTestRequestImpl;

  factory _SubmitLabTestRequest.fromJson(Map<String, dynamic> json) =
      _$SubmitLabTestRequestImpl.fromJson;

  @override
  String get inspectionId;
  @override
  double? get moistureContent;
  @override
  double? get afflatoxinLevel;
  @override
  double? get foreignMatterPercentage;
  @override
  double? get insectFragmentCount;
  @override
  double? get pH;
  @override
  String? get bacterialCount;
  @override
  String? get labCertificationId;

  /// Create a copy of SubmitLabTestRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmitLabTestRequestImplCopyWith<_$SubmitLabTestRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ApproveQualityInspectionRequest _$ApproveQualityInspectionRequestFromJson(
    Map<String, dynamic> json) {
  return _ApproveQualityInspectionRequest.fromJson(json);
}

/// @nodoc
mixin _$ApproveQualityInspectionRequest {
  String get inspectionId => throw _privateConstructorUsedError;
  String get finalGrade => throw _privateConstructorUsedError;
  bool get isApproved => throw _privateConstructorUsedError;
  String? get approvalNotes => throw _privateConstructorUsedError;

  /// Serializes this ApproveQualityInspectionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApproveQualityInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApproveQualityInspectionRequestCopyWith<ApproveQualityInspectionRequest>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApproveQualityInspectionRequestCopyWith<$Res> {
  factory $ApproveQualityInspectionRequestCopyWith(
          ApproveQualityInspectionRequest value,
          $Res Function(ApproveQualityInspectionRequest) then) =
      _$ApproveQualityInspectionRequestCopyWithImpl<$Res,
          ApproveQualityInspectionRequest>;
  @useResult
  $Res call(
      {String inspectionId,
      String finalGrade,
      bool isApproved,
      String? approvalNotes});
}

/// @nodoc
class _$ApproveQualityInspectionRequestCopyWithImpl<$Res,
        $Val extends ApproveQualityInspectionRequest>
    implements $ApproveQualityInspectionRequestCopyWith<$Res> {
  _$ApproveQualityInspectionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApproveQualityInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inspectionId = null,
    Object? finalGrade = null,
    Object? isApproved = null,
    Object? approvalNotes = freezed,
  }) {
    return _then(_value.copyWith(
      inspectionId: null == inspectionId
          ? _value.inspectionId
          : inspectionId // ignore: cast_nullable_to_non_nullable
              as String,
      finalGrade: null == finalGrade
          ? _value.finalGrade
          : finalGrade // ignore: cast_nullable_to_non_nullable
              as String,
      isApproved: null == isApproved
          ? _value.isApproved
          : isApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      approvalNotes: freezed == approvalNotes
          ? _value.approvalNotes
          : approvalNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ApproveQualityInspectionRequestImplCopyWith<$Res>
    implements $ApproveQualityInspectionRequestCopyWith<$Res> {
  factory _$$ApproveQualityInspectionRequestImplCopyWith(
          _$ApproveQualityInspectionRequestImpl value,
          $Res Function(_$ApproveQualityInspectionRequestImpl) then) =
      __$$ApproveQualityInspectionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String inspectionId,
      String finalGrade,
      bool isApproved,
      String? approvalNotes});
}

/// @nodoc
class __$$ApproveQualityInspectionRequestImplCopyWithImpl<$Res>
    extends _$ApproveQualityInspectionRequestCopyWithImpl<$Res,
        _$ApproveQualityInspectionRequestImpl>
    implements _$$ApproveQualityInspectionRequestImplCopyWith<$Res> {
  __$$ApproveQualityInspectionRequestImplCopyWithImpl(
      _$ApproveQualityInspectionRequestImpl _value,
      $Res Function(_$ApproveQualityInspectionRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ApproveQualityInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inspectionId = null,
    Object? finalGrade = null,
    Object? isApproved = null,
    Object? approvalNotes = freezed,
  }) {
    return _then(_$ApproveQualityInspectionRequestImpl(
      inspectionId: null == inspectionId
          ? _value.inspectionId
          : inspectionId // ignore: cast_nullable_to_non_nullable
              as String,
      finalGrade: null == finalGrade
          ? _value.finalGrade
          : finalGrade // ignore: cast_nullable_to_non_nullable
              as String,
      isApproved: null == isApproved
          ? _value.isApproved
          : isApproved // ignore: cast_nullable_to_non_nullable
              as bool,
      approvalNotes: freezed == approvalNotes
          ? _value.approvalNotes
          : approvalNotes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApproveQualityInspectionRequestImpl
    implements _ApproveQualityInspectionRequest {
  const _$ApproveQualityInspectionRequestImpl(
      {required this.inspectionId,
      required this.finalGrade,
      required this.isApproved,
      this.approvalNotes});

  factory _$ApproveQualityInspectionRequestImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ApproveQualityInspectionRequestImplFromJson(json);

  @override
  final String inspectionId;
  @override
  final String finalGrade;
  @override
  final bool isApproved;
  @override
  final String? approvalNotes;

  @override
  String toString() {
    return 'ApproveQualityInspectionRequest(inspectionId: $inspectionId, finalGrade: $finalGrade, isApproved: $isApproved, approvalNotes: $approvalNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApproveQualityInspectionRequestImpl &&
            (identical(other.inspectionId, inspectionId) ||
                other.inspectionId == inspectionId) &&
            (identical(other.finalGrade, finalGrade) ||
                other.finalGrade == finalGrade) &&
            (identical(other.isApproved, isApproved) ||
                other.isApproved == isApproved) &&
            (identical(other.approvalNotes, approvalNotes) ||
                other.approvalNotes == approvalNotes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, inspectionId, finalGrade, isApproved, approvalNotes);

  /// Create a copy of ApproveQualityInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApproveQualityInspectionRequestImplCopyWith<
          _$ApproveQualityInspectionRequestImpl>
      get copyWith => __$$ApproveQualityInspectionRequestImplCopyWithImpl<
          _$ApproveQualityInspectionRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApproveQualityInspectionRequestImplToJson(
      this,
    );
  }
}

abstract class _ApproveQualityInspectionRequest
    implements ApproveQualityInspectionRequest {
  const factory _ApproveQualityInspectionRequest(
      {required final String inspectionId,
      required final String finalGrade,
      required final bool isApproved,
      final String? approvalNotes}) = _$ApproveQualityInspectionRequestImpl;

  factory _ApproveQualityInspectionRequest.fromJson(Map<String, dynamic> json) =
      _$ApproveQualityInspectionRequestImpl.fromJson;

  @override
  String get inspectionId;
  @override
  String get finalGrade;
  @override
  bool get isApproved;
  @override
  String? get approvalNotes;

  /// Create a copy of ApproveQualityInspectionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApproveQualityInspectionRequestImplCopyWith<
          _$ApproveQualityInspectionRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

QualityStatsModel _$QualityStatsModelFromJson(Map<String, dynamic> json) {
  return _QualityStatsModel.fromJson(json);
}

/// @nodoc
mixin _$QualityStatsModel {
  int get totalInspections => throw _privateConstructorUsedError;
  int get approvedCount => throw _privateConstructorUsedError;
  int get rejectedCount => throw _privateConstructorUsedError;
  double get avgGradeA => throw _privateConstructorUsedError;
  double get avgGradeB => throw _privateConstructorUsedError;
  double get avgGradeC => throw _privateConstructorUsedError;
  double get avgGradeRejected => throw _privateConstructorUsedError;

  /// Serializes this QualityStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QualityStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QualityStatsModelCopyWith<QualityStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QualityStatsModelCopyWith<$Res> {
  factory $QualityStatsModelCopyWith(
          QualityStatsModel value, $Res Function(QualityStatsModel) then) =
      _$QualityStatsModelCopyWithImpl<$Res, QualityStatsModel>;
  @useResult
  $Res call(
      {int totalInspections,
      int approvedCount,
      int rejectedCount,
      double avgGradeA,
      double avgGradeB,
      double avgGradeC,
      double avgGradeRejected});
}

/// @nodoc
class _$QualityStatsModelCopyWithImpl<$Res, $Val extends QualityStatsModel>
    implements $QualityStatsModelCopyWith<$Res> {
  _$QualityStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QualityStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalInspections = null,
    Object? approvedCount = null,
    Object? rejectedCount = null,
    Object? avgGradeA = null,
    Object? avgGradeB = null,
    Object? avgGradeC = null,
    Object? avgGradeRejected = null,
  }) {
    return _then(_value.copyWith(
      totalInspections: null == totalInspections
          ? _value.totalInspections
          : totalInspections // ignore: cast_nullable_to_non_nullable
              as int,
      approvedCount: null == approvedCount
          ? _value.approvedCount
          : approvedCount // ignore: cast_nullable_to_non_nullable
              as int,
      rejectedCount: null == rejectedCount
          ? _value.rejectedCount
          : rejectedCount // ignore: cast_nullable_to_non_nullable
              as int,
      avgGradeA: null == avgGradeA
          ? _value.avgGradeA
          : avgGradeA // ignore: cast_nullable_to_non_nullable
              as double,
      avgGradeB: null == avgGradeB
          ? _value.avgGradeB
          : avgGradeB // ignore: cast_nullable_to_non_nullable
              as double,
      avgGradeC: null == avgGradeC
          ? _value.avgGradeC
          : avgGradeC // ignore: cast_nullable_to_non_nullable
              as double,
      avgGradeRejected: null == avgGradeRejected
          ? _value.avgGradeRejected
          : avgGradeRejected // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QualityStatsModelImplCopyWith<$Res>
    implements $QualityStatsModelCopyWith<$Res> {
  factory _$$QualityStatsModelImplCopyWith(_$QualityStatsModelImpl value,
          $Res Function(_$QualityStatsModelImpl) then) =
      __$$QualityStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalInspections,
      int approvedCount,
      int rejectedCount,
      double avgGradeA,
      double avgGradeB,
      double avgGradeC,
      double avgGradeRejected});
}

/// @nodoc
class __$$QualityStatsModelImplCopyWithImpl<$Res>
    extends _$QualityStatsModelCopyWithImpl<$Res, _$QualityStatsModelImpl>
    implements _$$QualityStatsModelImplCopyWith<$Res> {
  __$$QualityStatsModelImplCopyWithImpl(_$QualityStatsModelImpl _value,
      $Res Function(_$QualityStatsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of QualityStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalInspections = null,
    Object? approvedCount = null,
    Object? rejectedCount = null,
    Object? avgGradeA = null,
    Object? avgGradeB = null,
    Object? avgGradeC = null,
    Object? avgGradeRejected = null,
  }) {
    return _then(_$QualityStatsModelImpl(
      totalInspections: null == totalInspections
          ? _value.totalInspections
          : totalInspections // ignore: cast_nullable_to_non_nullable
              as int,
      approvedCount: null == approvedCount
          ? _value.approvedCount
          : approvedCount // ignore: cast_nullable_to_non_nullable
              as int,
      rejectedCount: null == rejectedCount
          ? _value.rejectedCount
          : rejectedCount // ignore: cast_nullable_to_non_nullable
              as int,
      avgGradeA: null == avgGradeA
          ? _value.avgGradeA
          : avgGradeA // ignore: cast_nullable_to_non_nullable
              as double,
      avgGradeB: null == avgGradeB
          ? _value.avgGradeB
          : avgGradeB // ignore: cast_nullable_to_non_nullable
              as double,
      avgGradeC: null == avgGradeC
          ? _value.avgGradeC
          : avgGradeC // ignore: cast_nullable_to_non_nullable
              as double,
      avgGradeRejected: null == avgGradeRejected
          ? _value.avgGradeRejected
          : avgGradeRejected // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QualityStatsModelImpl implements _QualityStatsModel {
  const _$QualityStatsModelImpl(
      {required this.totalInspections,
      required this.approvedCount,
      required this.rejectedCount,
      required this.avgGradeA,
      required this.avgGradeB,
      required this.avgGradeC,
      required this.avgGradeRejected});

  factory _$QualityStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$QualityStatsModelImplFromJson(json);

  @override
  final int totalInspections;
  @override
  final int approvedCount;
  @override
  final int rejectedCount;
  @override
  final double avgGradeA;
  @override
  final double avgGradeB;
  @override
  final double avgGradeC;
  @override
  final double avgGradeRejected;

  @override
  String toString() {
    return 'QualityStatsModel(totalInspections: $totalInspections, approvedCount: $approvedCount, rejectedCount: $rejectedCount, avgGradeA: $avgGradeA, avgGradeB: $avgGradeB, avgGradeC: $avgGradeC, avgGradeRejected: $avgGradeRejected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QualityStatsModelImpl &&
            (identical(other.totalInspections, totalInspections) ||
                other.totalInspections == totalInspections) &&
            (identical(other.approvedCount, approvedCount) ||
                other.approvedCount == approvedCount) &&
            (identical(other.rejectedCount, rejectedCount) ||
                other.rejectedCount == rejectedCount) &&
            (identical(other.avgGradeA, avgGradeA) ||
                other.avgGradeA == avgGradeA) &&
            (identical(other.avgGradeB, avgGradeB) ||
                other.avgGradeB == avgGradeB) &&
            (identical(other.avgGradeC, avgGradeC) ||
                other.avgGradeC == avgGradeC) &&
            (identical(other.avgGradeRejected, avgGradeRejected) ||
                other.avgGradeRejected == avgGradeRejected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalInspections, approvedCount,
      rejectedCount, avgGradeA, avgGradeB, avgGradeC, avgGradeRejected);

  /// Create a copy of QualityStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QualityStatsModelImplCopyWith<_$QualityStatsModelImpl> get copyWith =>
      __$$QualityStatsModelImplCopyWithImpl<_$QualityStatsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QualityStatsModelImplToJson(
      this,
    );
  }
}

abstract class _QualityStatsModel implements QualityStatsModel {
  const factory _QualityStatsModel(
      {required final int totalInspections,
      required final int approvedCount,
      required final int rejectedCount,
      required final double avgGradeA,
      required final double avgGradeB,
      required final double avgGradeC,
      required final double avgGradeRejected}) = _$QualityStatsModelImpl;

  factory _QualityStatsModel.fromJson(Map<String, dynamic> json) =
      _$QualityStatsModelImpl.fromJson;

  @override
  int get totalInspections;
  @override
  int get approvedCount;
  @override
  int get rejectedCount;
  @override
  double get avgGradeA;
  @override
  double get avgGradeB;
  @override
  double get avgGradeC;
  @override
  double get avgGradeRejected;

  /// Create a copy of QualityStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QualityStatsModelImplCopyWith<_$QualityStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AIAnalysisResultModel _$AIAnalysisResultModelFromJson(
    Map<String, dynamic> json) {
  return _AIAnalysisResultModel.fromJson(json);
}

/// @nodoc
mixin _$AIAnalysisResultModel {
  String get predictedGrade => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;
  List<String> get defects => throw _privateConstructorUsedError;

  /// Serializes this AIAnalysisResultModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIAnalysisResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIAnalysisResultModelCopyWith<AIAnalysisResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIAnalysisResultModelCopyWith<$Res> {
  factory $AIAnalysisResultModelCopyWith(AIAnalysisResultModel value,
          $Res Function(AIAnalysisResultModel) then) =
      _$AIAnalysisResultModelCopyWithImpl<$Res, AIAnalysisResultModel>;
  @useResult
  $Res call({String predictedGrade, double confidence, List<String> defects});
}

/// @nodoc
class _$AIAnalysisResultModelCopyWithImpl<$Res,
        $Val extends AIAnalysisResultModel>
    implements $AIAnalysisResultModelCopyWith<$Res> {
  _$AIAnalysisResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIAnalysisResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? predictedGrade = null,
    Object? confidence = null,
    Object? defects = null,
  }) {
    return _then(_value.copyWith(
      predictedGrade: null == predictedGrade
          ? _value.predictedGrade
          : predictedGrade // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      defects: null == defects
          ? _value.defects
          : defects // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIAnalysisResultModelImplCopyWith<$Res>
    implements $AIAnalysisResultModelCopyWith<$Res> {
  factory _$$AIAnalysisResultModelImplCopyWith(
          _$AIAnalysisResultModelImpl value,
          $Res Function(_$AIAnalysisResultModelImpl) then) =
      __$$AIAnalysisResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String predictedGrade, double confidence, List<String> defects});
}

/// @nodoc
class __$$AIAnalysisResultModelImplCopyWithImpl<$Res>
    extends _$AIAnalysisResultModelCopyWithImpl<$Res,
        _$AIAnalysisResultModelImpl>
    implements _$$AIAnalysisResultModelImplCopyWith<$Res> {
  __$$AIAnalysisResultModelImplCopyWithImpl(_$AIAnalysisResultModelImpl _value,
      $Res Function(_$AIAnalysisResultModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIAnalysisResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? predictedGrade = null,
    Object? confidence = null,
    Object? defects = null,
  }) {
    return _then(_$AIAnalysisResultModelImpl(
      predictedGrade: null == predictedGrade
          ? _value.predictedGrade
          : predictedGrade // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      defects: null == defects
          ? _value._defects
          : defects // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIAnalysisResultModelImpl implements _AIAnalysisResultModel {
  const _$AIAnalysisResultModelImpl(
      {required this.predictedGrade,
      required this.confidence,
      required final List<String> defects})
      : _defects = defects;

  factory _$AIAnalysisResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIAnalysisResultModelImplFromJson(json);

  @override
  final String predictedGrade;
  @override
  final double confidence;
  final List<String> _defects;
  @override
  List<String> get defects {
    if (_defects is EqualUnmodifiableListView) return _defects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_defects);
  }

  @override
  String toString() {
    return 'AIAnalysisResultModel(predictedGrade: $predictedGrade, confidence: $confidence, defects: $defects)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIAnalysisResultModelImpl &&
            (identical(other.predictedGrade, predictedGrade) ||
                other.predictedGrade == predictedGrade) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            const DeepCollectionEquality().equals(other._defects, _defects));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, predictedGrade, confidence,
      const DeepCollectionEquality().hash(_defects));

  /// Create a copy of AIAnalysisResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIAnalysisResultModelImplCopyWith<_$AIAnalysisResultModelImpl>
      get copyWith => __$$AIAnalysisResultModelImplCopyWithImpl<
          _$AIAnalysisResultModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIAnalysisResultModelImplToJson(
      this,
    );
  }
}

abstract class _AIAnalysisResultModel implements AIAnalysisResultModel {
  const factory _AIAnalysisResultModel(
      {required final String predictedGrade,
      required final double confidence,
      required final List<String> defects}) = _$AIAnalysisResultModelImpl;

  factory _AIAnalysisResultModel.fromJson(Map<String, dynamic> json) =
      _$AIAnalysisResultModelImpl.fromJson;

  @override
  String get predictedGrade;
  @override
  double get confidence;
  @override
  List<String> get defects;

  /// Create a copy of AIAnalysisResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIAnalysisResultModelImplCopyWith<_$AIAnalysisResultModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
