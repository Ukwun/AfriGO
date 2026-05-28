import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'rfq_model.freezed.dart';
part 'rfq_model.g.dart';

@freezed
class RFQModel with _$RFQModel {
  const factory RFQModel({
    required String id,
    required String buyerId,
    required String buyerEmail,
    required String buyerCompanyName,
    required String productCategory,
    required String productDescription,
    required double quantity,
    required String quantityUnit,
    required String? originCountryPreference,
    required String? gradePreference,
    required String? deliveryLocation,
    required DateTime deliveryDeadline,
    required String paymentTerms,
    required int maxBidsExpected,
    required List<RFQBidModel> submittedBids,
    required String status, // open, evaluating, awarded, closed
    required String? selectedSupplierId,
    required String? selectedSupplierBidId,
    required DateTime createdAt,
    required DateTime expiresAt,
    required String description,
  }) = _RFQModel;

  factory RFQModel.fromJson(Map<String, dynamic> json) =>
      _$RFQModelFromJson(json);
}

@freezed
class RFQBidModel with _$RFQBidModel {
  const factory RFQBidModel({
    required String id,
    required String rfqId,
    required String supplierId,
    required String supplierEmail,
    required String supplierCompanyName,
    required double pricePerUnit,
    required double totalPrice,
    required String? originCountry,
    required String? gradeLevel,
    required DateTime estimatedDelivery,
    required String paymentMethod,
    required String? specialTerms,
    required String status, // pending, accepted, rejected, awarded
    required DateTime submittedAt,
    required int documentCount,
    required List<String>? certificationsIncluded,
  }) = _RFQBidModel;

  factory RFQBidModel.fromJson(Map<String, dynamic> json) =>
      _$RFQBidModelFromJson(json);
}

@freezed
class CreateRFQRequest with _$CreateRFQRequest {
  const factory CreateRFQRequest({
    required String productCategory,
    required String productDescription,
    required double quantity,
    required String quantityUnit,
    required String? originCountryPreference,
    required String? gradePreference,
    required String? deliveryLocation,
    required DateTime deliveryDeadline,
    required String paymentTerms,
    required int maxBidsExpected,
    required String description,
  }) = _CreateRFQRequest;

  factory CreateRFQRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRFQRequestFromJson(json);
}

@freezed
class SubmitBidRequest with _$SubmitBidRequest {
  const factory SubmitBidRequest({
    required String rfqId,
    required double pricePerUnit,
    required String originCountry,
    required String gradeLevel,
    required DateTime estimatedDelivery,
    required String paymentMethod,
    required String? specialTerms,
    required List<String>? certificationsIncluded,
  }) = _SubmitBidRequest;

  factory SubmitBidRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitBidRequestFromJson(json);
}

@freezed
class RFQFilterModel with _$RFQFilterModel {
  const factory RFQFilterModel({
    required String? status,
    required String? category,
    required String? searchTerm,
    required int page,
    required int limit,
  }) = _RFQFilterModel;

  factory RFQFilterModel.fromJson(Map<String, dynamic> json) =>
      _$RFQFilterModelFromJson(json);
}
