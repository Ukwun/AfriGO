// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shipment_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ShipmentEventModel {
  String get id => throw _privateConstructorUsedError;
  String get shipmentId => throw _privateConstructorUsedError;
  String get eventType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Create a copy of ShipmentEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShipmentEventModelCopyWith<ShipmentEventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShipmentEventModelCopyWith<$Res> {
  factory $ShipmentEventModelCopyWith(
          ShipmentEventModel value, $Res Function(ShipmentEventModel) then) =
      _$ShipmentEventModelCopyWithImpl<$Res, ShipmentEventModel>;
  @useResult
  $Res call(
      {String id,
      String shipmentId,
      String eventType,
      String title,
      String description,
      DateTime timestamp,
      String location,
      String status});
}

/// @nodoc
class _$ShipmentEventModelCopyWithImpl<$Res, $Val extends ShipmentEventModel>
    implements $ShipmentEventModelCopyWith<$Res> {
  _$ShipmentEventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShipmentEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shipmentId = null,
    Object? eventType = null,
    Object? title = null,
    Object? description = null,
    Object? timestamp = null,
    Object? location = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shipmentId: null == shipmentId
          ? _value.shipmentId
          : shipmentId // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShipmentEventModelImplCopyWith<$Res>
    implements $ShipmentEventModelCopyWith<$Res> {
  factory _$$ShipmentEventModelImplCopyWith(_$ShipmentEventModelImpl value,
          $Res Function(_$ShipmentEventModelImpl) then) =
      __$$ShipmentEventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String shipmentId,
      String eventType,
      String title,
      String description,
      DateTime timestamp,
      String location,
      String status});
}

/// @nodoc
class __$$ShipmentEventModelImplCopyWithImpl<$Res>
    extends _$ShipmentEventModelCopyWithImpl<$Res, _$ShipmentEventModelImpl>
    implements _$$ShipmentEventModelImplCopyWith<$Res> {
  __$$ShipmentEventModelImplCopyWithImpl(_$ShipmentEventModelImpl _value,
      $Res Function(_$ShipmentEventModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShipmentEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shipmentId = null,
    Object? eventType = null,
    Object? title = null,
    Object? description = null,
    Object? timestamp = null,
    Object? location = null,
    Object? status = null,
  }) {
    return _then(_$ShipmentEventModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      shipmentId: null == shipmentId
          ? _value.shipmentId
          : shipmentId // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ShipmentEventModelImpl implements _ShipmentEventModel {
  const _$ShipmentEventModelImpl(
      {required this.id,
      required this.shipmentId,
      required this.eventType,
      required this.title,
      required this.description,
      required this.timestamp,
      required this.location,
      required this.status});

  @override
  final String id;
  @override
  final String shipmentId;
  @override
  final String eventType;
  @override
  final String title;
  @override
  final String description;
  @override
  final DateTime timestamp;
  @override
  final String location;
  @override
  final String status;

  @override
  String toString() {
    return 'ShipmentEventModel(id: $id, shipmentId: $shipmentId, eventType: $eventType, title: $title, description: $description, timestamp: $timestamp, location: $location, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShipmentEventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shipmentId, shipmentId) ||
                other.shipmentId == shipmentId) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, shipmentId, eventType, title,
      description, timestamp, location, status);

  /// Create a copy of ShipmentEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShipmentEventModelImplCopyWith<_$ShipmentEventModelImpl> get copyWith =>
      __$$ShipmentEventModelImplCopyWithImpl<_$ShipmentEventModelImpl>(
          this, _$identity);
}

abstract class _ShipmentEventModel implements ShipmentEventModel {
  const factory _ShipmentEventModel(
      {required final String id,
      required final String shipmentId,
      required final String eventType,
      required final String title,
      required final String description,
      required final DateTime timestamp,
      required final String location,
      required final String status}) = _$ShipmentEventModelImpl;

  @override
  String get id;
  @override
  String get shipmentId;
  @override
  String get eventType;
  @override
  String get title;
  @override
  String get description;
  @override
  DateTime get timestamp;
  @override
  String get location;
  @override
  String get status;

  /// Create a copy of ShipmentEventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShipmentEventModelImplCopyWith<_$ShipmentEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
