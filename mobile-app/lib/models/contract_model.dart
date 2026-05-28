import 'package:freezed_annotation/freezed_annotation.dart';

part 'contract_model.freezed.dart';
part 'contract_model.g.dart';

@freezed
class ContractModel with _$ContractModel {
  const factory ContractModel({
    required String id,
    required String lotId,
    String? rfqId,
    required String buyerId,
    required String buyerName,
    required String sellerId,
    required String sellerName,
    required String contractType, // standard, bulk, premium, custom
    required String
        status, // draft, active, signed, executed, terminated, disputed
    required String templateName,
    required double totalValue,
    required double totalQuantity,
    required String unit, // MT, kg, etc.
    required String currency, // USD, GHS
    required double pricePerUnit,
    required String requiredGrade,
    String? qualitySpecifications,
    String? deliveryTerms,
    required String
        paymentMethod, // full_upfront, partial_deposit, on_delivery, installment, escrow
    required double depositPercentage,
    int? installmentCount,
    int? paymentDuesDays,
    required DateTime signatureDeadline,
    required DateTime deliveryStartDate,
    required DateTime deliveryEndDate,
    required DateTime expiryDate,
    required bool buyerSigned,
    DateTime? buyerSignedAt,
    required bool sellerSigned,
    DateTime? sellerSignedAt,
    required bool isDisputed,
    String? disputeReason,
    required int amendmentCount,
    required bool insuranceRequired,
    String? insurancePolicyNumber,
    required bool phytosanitaryCertificateRequired,
    required DateTime createdAt,
    DateTime? executedAt,
  }) = _ContractModel;

  factory ContractModel.fromJson(Map<String, dynamic> json) =>
      _$ContractModelFromJson(json);
}

@freezed
class ContractListModel with _$ContractListModel {
  const factory ContractListModel({
    required String id,
    required String contractType,
    required String status,
    required double totalValue,
    required String buyerName,
    required String sellerName,
    required DateTime signatureDeadline,
    required DateTime deliveryEndDate,
    required bool buyerSigned,
    required bool sellerSigned,
    required bool isDisputed,
    required DateTime createdAt,
  }) = _ContractListModel;

  factory ContractListModel.fromJson(Map<String, dynamic> json) =>
      _$ContractListModelFromJson(json);
}

@freezed
class ContractAmendmentModel with _$ContractAmendmentModel {
  const factory ContractAmendmentModel({
    required String id,
    required String contractId,
    required String reason,
    required String description,
    String? proposedChanges,
    required String status,
    required bool buyerApproved,
    required bool sellerApproved,
    String? rejectionReason,
    required String submittedByName,
    required DateTime createdAt,
    DateTime? approvedAt,
  }) = _ContractAmendmentModel;

  factory ContractAmendmentModel.fromJson(Map<String, dynamic> json) =>
      _$ContractAmendmentModelFromJson(json);
}

@freezed
class CreateContractRequest with _$CreateContractRequest {
  const factory CreateContractRequest({
    required String rfqId,
    required String lotId,
    required String buyerId,
    required String sellerId,
    required String contractType,
    required String templateName,
    required double totalValue,
    required double totalQuantity,
    required String unit,
    required String currency,
    required double pricePerUnit,
    required String requiredGrade,
    String? qualitySpecifications,
    String? deliveryTerms,
    required String paymentMethod,
    required double depositPercentage,
    int? installmentCount,
    int? paymentDuesDays,
    required DateTime signatureDeadline,
    required DateTime deliveryStartDate,
    required DateTime deliveryEndDate,
    required DateTime expiryDate,
    bool insuranceRequired = false,
    String? insuranceProvider,
    bool phytosanitaryCertificateRequired = false,
    String? additionalTerms,
  }) = _CreateContractRequest;

  factory CreateContractRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateContractRequestFromJson(json);
}

@freezed
class SignContractRequest with _$SignContractRequest {
  const factory SignContractRequest({
    required String contractId,
    required String signature, // Base64 image data
    required bool agreeToTerms,
    String? ipAddress,
    String? deviceInfo,
  }) = _SignContractRequest;

  factory SignContractRequest.fromJson(Map<String, dynamic> json) =>
      _$SignContractRequestFromJson(json);
}

@freezed
class AmendContractRequest with _$AmendContractRequest {
  const factory AmendContractRequest({
    required String contractId,
    required String reason,
    required String description,
    String? proposedChanges,
    double? newPrice,
    double? newQuantity,
    DateTime? newDeliveryDate,
    String? newQuality,
  }) = _AmendContractRequest;

  factory AmendContractRequest.fromJson(Map<String, dynamic> json) =>
      _$AmendContractRequestFromJson(json);
}

@freezed
class ApproveAmendmentRequest with _$ApproveAmendmentRequest {
  const factory ApproveAmendmentRequest({
    required String amendmentId,
    required bool approved,
    String? rejectionReason,
  }) = _ApproveAmendmentRequest;

  factory ApproveAmendmentRequest.fromJson(Map<String, dynamic> json) =>
      _$ApproveAmendmentRequestFromJson(json);
}

@freezed
class InitiateDisputeRequest with _$InitiateDisputeRequest {
  const factory InitiateDisputeRequest({
    required String contractId,
    required String disputeReason,
    required String evidence,
    String? preferredMediatorId,
  }) = _InitiateDisputeRequest;

  factory InitiateDisputeRequest.fromJson(Map<String, dynamic> json) =>
      _$InitiateDisputeRequestFromJson(json);
}

@freezed
class ContractSummaryModel with _$ContractSummaryModel {
  const factory ContractSummaryModel({
    required String text,
    required DateTime generatedAt,
  }) = _ContractSummaryModel;

  factory ContractSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ContractSummaryModelFromJson(json);
}
