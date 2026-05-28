import 'package:freezed_annotation/freezed_annotation.dart';

part 'shipment_model.freezed.dart';
part 'shipment_model.g.dart';

// ======================== SHIPMENT MODELS ========================

@freezed
class ShipmentModel with _$ShipmentModel {
  const factory ShipmentModel({
    required String id,
    required String shipmentReference,
    required String status,
    required String transportMode,
    required String pickupLocationName,
    required String deliveryLocationName,
    required DateTime pickupDate,
    required DateTime expectedDeliveryDate,
    DateTime? actualDeliveryDate,
    int? daysInTransit,
    bool? isDelayed,
    DriverModel? driver,
    String? vehicleRegistration,
    String? trackingUrl,
    int? deliveryProofCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ShipmentModel;

  factory ShipmentModel.fromJson(Map<String, dynamic> json) =>
      _$ShipmentModelFromJson(json);
}

@freezed
class ShipmentDetailsModel with _$ShipmentDetailsModel {
  const factory ShipmentDetailsModel({
    required String id,
    required String shipmentReference,
    required String status,
    required String transportMode,
    required String pickupLocationName,
    required String deliveryLocationName,
    required DateTime pickupDate,
    required DateTime expectedDeliveryDate,
    DateTime? actualDeliveryDate,
    int? daysInTransit,
    bool? isDelayed,
    DriverModel? driver,
    String? vehicleRegistration,
    String? trackingUrl,
    int? deliveryProofCount,
    required ContractRefModel contract,
    required List<TrackingEventModel> trackingHistory,
    required List<DeliveryProofModel> deliveryProofs,
    String? recipientName,
    String? recipientPhone,
    bool? requiresSignature,
    String? specialHandlingInstructions,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ShipmentDetailsModel;

  factory ShipmentDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$ShipmentDetailsModelFromJson(json);
}

@freezed
class ShipmentListModel with _$ShipmentListModel {
  const factory ShipmentListModel({
    required List<ShipmentModel> data,
    required PaginationModel pagination,
  }) = _ShipmentListModel;

  factory ShipmentListModel.fromJson(Map<String, dynamic> json) =>
      _$ShipmentListModelFromJson(json);
}

@freezed
class ContractRefModel with _$ContractRefModel {
  const factory ContractRefModel({
    required String id,
    required double totalValue,
    required String currency,
    required PartyModel buyer,
    required PartyModel seller,
  }) = _ContractRefModel;

  factory ContractRefModel.fromJson(Map<String, dynamic> json) =>
      _$ContractRefModelFromJson(json);
}

@freezed
class PartyModel with _$PartyModel {
  const factory PartyModel({
    required String id,
    required String name,
  }) = _PartyModel;

  factory PartyModel.fromJson(Map<String, dynamic> json) =>
      _$PartyModelFromJson(json);
}

@freezed
class DriverModel with _$DriverModel {
  const factory DriverModel({
    required String id,
    required String name,
    required String phone,
  }) = _DriverModel;

  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);
}

@freezed
class TrackingEventModel with _$TrackingEventModel {
  const factory TrackingEventModel({
    required String id,
    required String eventType,
    required String message,
    String? latitude,
    String? longitude,
    String? locationName,
    dynamic metadata,
    required DateTime createdAt,
  }) = _TrackingEventModel;

  factory TrackingEventModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingEventModelFromJson(json);
}

@freezed
class DeliveryProofModel with _$DeliveryProofModel {
  const factory DeliveryProofModel({
    required String id,
    required String proofType,
    required String description,
    String? dataBlobUrl,
    String? recipientName,
    String? recipientIdNumber,
    dynamic conditionAssessment,
    String? latitude,
    String? longitude,
    required bool isVerified,
    required DateTime createdAt,
    required DriverModel capturedBy,
  }) = _DeliveryProofModel;

  factory DeliveryProofModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryProofModelFromJson(json);
}

@freezed
class ShipmentSummaryModel with _$ShipmentSummaryModel {
  const factory ShipmentSummaryModel({
    required int totalShipments,
    required int inTransit,
    required int delivered,
    required int failed,
    required double avgDeliveryDays,
    required double onTimeDeliveryRate,
  }) = _ShipmentSummaryModel;

  factory ShipmentSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ShipmentSummaryModelFromJson(json);
}

@freezed
class PaginationModel with _$PaginationModel {
  const factory PaginationModel({
    required int limit,
    required int offset,
    required int total,
    required bool hasMore,
  }) = _PaginationModel;

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      _$PaginationModelFromJson(json);
}

// ======================== REQUEST DTOS ========================

@freezed
class CreateShipmentRequest with _$CreateShipmentRequest {
  const factory CreateShipmentRequest({
    required String contractId,
    required String transportMode,
    required String pickupLocationName,
    required String pickupLatitude,
    required String pickupLongitude,
    required DateTime pickupDate,
    required String deliveryLocationName,
    required String deliveryLatitude,
    required String deliveryLongitude,
    required DateTime expectedDeliveryDate,
    String? vehicleRegistration,
    String? description,
    double? totalWeight,
    String? recipientName,
    String? recipientPhone,
    String? specialHandlingInstructions,
    bool? insured,
  }) = _CreateShipmentRequest;

  factory CreateShipmentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateShipmentRequestFromJson(json);
}

@freezed
class UpdateShipmentStatusRequest with _$UpdateShipmentStatusRequest {
  const factory UpdateShipmentStatusRequest({
    required String status,
    String? notes,
    String? deliveryFailureReason,
  }) = _UpdateShipmentStatusRequest;

  factory UpdateShipmentStatusRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateShipmentStatusRequestFromJson(json);
}

@freezed
class AddTrackingEventRequest with _$AddTrackingEventRequest {
  const factory AddTrackingEventRequest({
    required String eventType,
    required String message,
    String? latitude,
    String? longitude,
    String? locationName,
    dynamic metadata,
    String? notes,
  }) = _AddTrackingEventRequest;

  factory AddTrackingEventRequest.fromJson(Map<String, dynamic> json) =>
      _$AddTrackingEventRequestFromJson(json);
}

@freezed
class CaptureDeliveryProofRequest with _$CaptureDeliveryProofRequest {
  const factory CaptureDeliveryProofRequest({
    required String proofType,
    required String description,
    String? dataBlobUrl,
    dynamic signatureCanvas,
    String? recipientName,
    String? recipientIdType,
    String? recipientIdNumber,
    String? recipientPhone,
    dynamic conditionAssessment,
    String? latitude,
    String? longitude,
    String? notes,
  }) = _CaptureDeliveryProofRequest;

  factory CaptureDeliveryProofRequest.fromJson(Map<String, dynamic> json) =>
      _$CaptureDeliveryProofRequestFromJson(json);
}

@freezed
class RescheduleDeliveryRequest with _$RescheduleDeliveryRequest {
  const factory RescheduleDeliveryRequest({
    required DateTime newDeliveryDate,
    required String reason,
    String? notes,
  }) = _RescheduleDeliveryRequest;

  factory RescheduleDeliveryRequest.fromJson(Map<String, dynamic> json) =>
      _$RescheduleDeliveryRequestFromJson(json);
}
