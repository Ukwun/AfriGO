import 'package:freezed_annotation/freezed_annotation.dart';

part 'lot_model.freezed.dart';
part 'lot_model.g.dart';

@freezed
class LotModel with _$LotModel {
  const factory LotModel({
    required String id,
    required String productName,
    required String category,
    required double quantity,
    required double quantityReserved,
    required double quantitySold,
    required String quantityUnit,
    required double pricePerUnit,
    required double totalValue,
    required String batchNumber,
    required String qrCode,
    required String originCountry,
    required String? originRegion,
    required String? originLocation,
    required String pickupLocation,
    required double latitude,
    required double longitude,
    required DateTime? harvestDate,
    required DateTime? productionDate,
    required DateTime? expiryDate,
    required String gradeLevel,
    required String status,
    required String verifyStatus,
    required SellerModel seller,
    required List<String> images,
    required List<String> certifications,
    required bool certifiedOrganic,
    required bool fairTradeCertified,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _LotModel;

  factory LotModel.fromJson(Map<String, dynamic> json) =>
      _$LotModelFromJson(json);
}

@freezed
class SellerModel with _$SellerModel {
  const factory SellerModel({
    required String id,
    required String email,
    required String? firstName,
    required String? lastName,
  }) = _SellerModel;

  factory SellerModel.fromJson(Map<String, dynamic> json) =>
      _$SellerModelFromJson(json);
}

@freezed
class LotTraceabilityModel with _$LotTraceabilityModel {
  const factory LotTraceabilityModel({
    required String id,
    required String lotId,
    required String eventType,
    required String? description,
    required String? location,
    required double? latitude,
    required double? longitude,
    required DateTime timestamp,
  }) = _LotTraceabilityModel;

  factory LotTraceabilityModel.fromJson(Map<String, dynamic> json) =>
      _$LotTraceabilityModelFromJson(json);
}

@freezed
class CreateLotRequest with _$CreateLotRequest {
  const factory CreateLotRequest({
    required String productName,
    required String category,
    required double quantity,
    required String quantityUnit,
    required double pricePerUnit,
    required String description,
    required List<String> images,
    required String originCountry,
    required String? originRegion,
    required String? originLocation,
    required String pickupLocation,
    required double latitude,
    required double longitude,
    required DateTime? harvestDate,
    required DateTime? productionDate,
    required DateTime? expiryDate,
    required String? gradeLevel,
    required double? moistureContent,
    required double? afflatoxinLevel,
    required double? foreignMatterPercentage,
    required List<String>? certifications,
    required bool? certifiedOrganic,
    required bool? fairTradeCertified,
  }) = _CreateLotRequest;

  factory CreateLotRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateLotRequestFromJson(json);
}
