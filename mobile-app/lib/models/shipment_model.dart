class ShipmentModel {
  final String id;
  final String shipmentReference;
  final String status;
  final String transportMode;
  final String pickupLocationName;
  final String deliveryLocationName;
  final DateTime pickupDate;
  final DateTime expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final int? daysInTransit;
  final bool? isDelayed;
  final DriverModel? driver;
  final String? vehicleRegistration;
  final String? trackingUrl;
  final int? deliveryProofCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShipmentModel({
    required this.id,
    required this.shipmentReference,
    required this.status,
    required this.transportMode,
    required this.pickupLocationName,
    required this.deliveryLocationName,
    required this.pickupDate,
    required this.expectedDeliveryDate,
    this.actualDeliveryDate,
    this.daysInTransit,
    this.isDelayed,
    this.driver,
    this.vehicleRegistration,
    this.trackingUrl,
    this.deliveryProofCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] as String,
      shipmentReference: json['shipmentReference'] as String,
      status: json['status'] as String,
      transportMode: json['transportMode'] as String,
      pickupLocationName: json['pickupLocationName'] as String,
      deliveryLocationName: json['deliveryLocationName'] as String,
      pickupDate: DateTime.parse(json['pickupDate'] as String),
      expectedDeliveryDate:
          DateTime.parse(json['expectedDeliveryDate'] as String),
      actualDeliveryDate: json['actualDeliveryDate'] == null
          ? null
          : DateTime.parse(json['actualDeliveryDate'] as String),
      daysInTransit: json['daysInTransit'] as int?,
      isDelayed: json['isDelayed'] as bool?,
      driver: json['driver'] == null
          ? null
          : DriverModel.fromJson(json['driver'] as Map<String, dynamic>),
      vehicleRegistration: json['vehicleRegistration'] as String?,
      trackingUrl: json['trackingUrl'] as String?,
      deliveryProofCount: json['deliveryProofCount'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shipmentReference': shipmentReference,
      'status': status,
      'transportMode': transportMode,
      'pickupLocationName': pickupLocationName,
      'deliveryLocationName': deliveryLocationName,
      'pickupDate': pickupDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'daysInTransit': daysInTransit,
      'isDelayed': isDelayed,
      'driver': driver?.toJson(),
      'vehicleRegistration': vehicleRegistration,
      'trackingUrl': trackingUrl,
      'deliveryProofCount': deliveryProofCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ShipmentDetailsModel {
  final String id;
  final String shipmentReference;
  final String status;
  final String transportMode;
  final String pickupLocationName;
  final String deliveryLocationName;
  final DateTime pickupDate;
  final DateTime expectedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final int? daysInTransit;
  final bool? isDelayed;
  final DriverModel? driver;
  final String? vehicleRegistration;
  final String? trackingUrl;
  final int? deliveryProofCount;
  final ContractRefModel contract;
  final List<TrackingEventModel> trackingHistory;
  final List<DeliveryProofModel> deliveryProofs;
  final String? recipientName;
  final String? recipientPhone;
  final bool? requiresSignature;
  final String? specialHandlingInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShipmentDetailsModel({
    required this.id,
    required this.shipmentReference,
    required this.status,
    required this.transportMode,
    required this.pickupLocationName,
    required this.deliveryLocationName,
    required this.pickupDate,
    required this.expectedDeliveryDate,
    this.actualDeliveryDate,
    this.daysInTransit,
    this.isDelayed,
    this.driver,
    this.vehicleRegistration,
    this.trackingUrl,
    this.deliveryProofCount,
    required this.contract,
    required this.trackingHistory,
    required this.deliveryProofs,
    this.recipientName,
    this.recipientPhone,
    this.requiresSignature,
    this.specialHandlingInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShipmentDetailsModel.fromJson(Map<String, dynamic> json) {
    return ShipmentDetailsModel(
      id: json['id'] as String,
      shipmentReference: json['shipmentReference'] as String,
      status: json['status'] as String,
      transportMode: json['transportMode'] as String,
      pickupLocationName: json['pickupLocationName'] as String,
      deliveryLocationName: json['deliveryLocationName'] as String,
      pickupDate: DateTime.parse(json['pickupDate'] as String),
      expectedDeliveryDate:
          DateTime.parse(json['expectedDeliveryDate'] as String),
      actualDeliveryDate: json['actualDeliveryDate'] == null
          ? null
          : DateTime.parse(json['actualDeliveryDate'] as String),
      daysInTransit: json['daysInTransit'] as int?,
      isDelayed: json['isDelayed'] as bool?,
      driver: json['driver'] == null
          ? null
          : DriverModel.fromJson(json['driver'] as Map<String, dynamic>),
      vehicleRegistration: json['vehicleRegistration'] as String?,
      trackingUrl: json['trackingUrl'] as String?,
      deliveryProofCount: json['deliveryProofCount'] as int?,
      contract:
          ContractRefModel.fromJson(json['contract'] as Map<String, dynamic>),
      trackingHistory: (json['trackingHistory'] as List<dynamic>)
          .map((item) =>
              TrackingEventModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      deliveryProofs: (json['deliveryProofs'] as List<dynamic>)
          .map((item) =>
              DeliveryProofModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      recipientName: json['recipientName'] as String?,
      recipientPhone: json['recipientPhone'] as String?,
      requiresSignature: json['requiresSignature'] as bool?,
      specialHandlingInstructions:
          json['specialHandlingInstructions'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shipmentReference': shipmentReference,
      'status': status,
      'transportMode': transportMode,
      'pickupLocationName': pickupLocationName,
      'deliveryLocationName': deliveryLocationName,
      'pickupDate': pickupDate.toIso8601String(),
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
      'actualDeliveryDate': actualDeliveryDate?.toIso8601String(),
      'daysInTransit': daysInTransit,
      'isDelayed': isDelayed,
      'driver': driver?.toJson(),
      'vehicleRegistration': vehicleRegistration,
      'trackingUrl': trackingUrl,
      'deliveryProofCount': deliveryProofCount,
      'contract': contract.toJson(),
      'trackingHistory': trackingHistory.map((e) => e.toJson()).toList(),
      'deliveryProofs': deliveryProofs.map((e) => e.toJson()).toList(),
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'requiresSignature': requiresSignature,
      'specialHandlingInstructions': specialHandlingInstructions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ShipmentListModel {
  final List<ShipmentModel> data;
  final PaginationModel pagination;

  ShipmentListModel({
    required this.data,
    required this.pagination,
  });

  factory ShipmentListModel.fromJson(Map<String, dynamic> json) {
    return ShipmentListModel(
      data: (json['data'] as List<dynamic>)
          .map((item) => ShipmentModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination:
          PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class ContractRefModel {
  final String id;
  final double totalValue;
  final String currency;
  final PartyModel buyer;
  final PartyModel seller;

  ContractRefModel({
    required this.id,
    required this.totalValue,
    required this.currency,
    required this.buyer,
    required this.seller,
  });

  factory ContractRefModel.fromJson(Map<String, dynamic> json) {
    return ContractRefModel(
      id: json['id'] as String,
      totalValue: (json['totalValue'] as num).toDouble(),
      currency: json['currency'] as String,
      buyer: PartyModel.fromJson(json['buyer'] as Map<String, dynamic>),
      seller: PartyModel.fromJson(json['seller'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalValue': totalValue,
      'currency': currency,
      'buyer': buyer.toJson(),
      'seller': seller.toJson(),
    };
  }
}

class PartyModel {
  final String id;
  final String name;

  PartyModel({
    required this.id,
    required this.name,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    return PartyModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class DriverModel {
  final String id;
  final String name;
  final String phone;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
    };
  }
}

class TrackingEventModel {
  final String id;
  final String eventType;
  final String message;
  final String? latitude;
  final String? longitude;
  final String? locationName;
  final dynamic metadata;
  final DateTime createdAt;

  TrackingEventModel({
    required this.id,
    required this.eventType,
    required this.message,
    this.latitude,
    this.longitude,
    this.locationName,
    this.metadata,
    required this.createdAt,
  });

  factory TrackingEventModel.fromJson(Map<String, dynamic> json) {
    return TrackingEventModel(
      id: json['id'] as String,
      eventType: json['eventType'] as String,
      message: json['message'] as String,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      locationName: json['locationName'] as String?,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class DeliveryProofModel {
  final String id;
  final String proofType;
  final String description;
  final String? dataBlobUrl;
  final String? recipientName;
  final String? recipientIdNumber;
  final dynamic conditionAssessment;
  final String? latitude;
  final String? longitude;
  final bool isVerified;
  final DateTime createdAt;
  final DriverModel capturedBy;

  DeliveryProofModel({
    required this.id,
    required this.proofType,
    required this.description,
    this.dataBlobUrl,
    this.recipientName,
    this.recipientIdNumber,
    this.conditionAssessment,
    this.latitude,
    this.longitude,
    required this.isVerified,
    required this.createdAt,
    required this.capturedBy,
  });

  factory DeliveryProofModel.fromJson(Map<String, dynamic> json) {
    return DeliveryProofModel(
      id: json['id'] as String,
      proofType: json['proofType'] as String,
      description: json['description'] as String,
      dataBlobUrl: json['dataBlobUrl'] as String?,
      recipientName: json['recipientName'] as String?,
      recipientIdNumber: json['recipientIdNumber'] as String?,
      conditionAssessment: json['conditionAssessment'],
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      isVerified: json['isVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      capturedBy:
          DriverModel.fromJson(json['capturedBy'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proofType': proofType,
      'description': description,
      'dataBlobUrl': dataBlobUrl,
      'recipientName': recipientName,
      'recipientIdNumber': recipientIdNumber,
      'conditionAssessment': conditionAssessment,
      'latitude': latitude,
      'longitude': longitude,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'capturedBy': capturedBy.toJson(),
    };
  }
}

class ShipmentSummaryModel {
  final int totalShipments;
  final int inTransit;
  final int delivered;
  final int failed;
  final double avgDeliveryDays;
  final double onTimeDeliveryRate;

  ShipmentSummaryModel({
    required this.totalShipments,
    required this.inTransit,
    required this.delivered,
    required this.failed,
    required this.avgDeliveryDays,
    required this.onTimeDeliveryRate,
  });

  factory ShipmentSummaryModel.fromJson(Map<String, dynamic> json) {
    return ShipmentSummaryModel(
      totalShipments: json['totalShipments'] as int,
      inTransit: json['inTransit'] as int,
      delivered: json['delivered'] as int,
      failed: json['failed'] as int,
      avgDeliveryDays: (json['avgDeliveryDays'] as num).toDouble(),
      onTimeDeliveryRate: (json['onTimeDeliveryRate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalShipments': totalShipments,
      'inTransit': inTransit,
      'delivered': delivered,
      'failed': failed,
      'avgDeliveryDays': avgDeliveryDays,
      'onTimeDeliveryRate': onTimeDeliveryRate,
    };
  }
}

class PaginationModel {
  final int limit;
  final int offset;
  final int total;
  final bool hasMore;

  PaginationModel({
    required this.limit,
    required this.offset,
    required this.total,
    required this.hasMore,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      total: json['total'] as int,
      hasMore: json['hasMore'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'limit': limit,
      'offset': offset,
      'total': total,
      'hasMore': hasMore,
    };
  }
}

class CreateShipmentRequest {
  final String contractId;
  final String transportMode;
  final String pickupLocationName;
  final String pickupLatitude;
  final String pickupLongitude;
  final DateTime pickupDate;
  final String deliveryLocationName;
  final String deliveryLatitude;
  final String deliveryLongitude;
  final DateTime expectedDeliveryDate;
  final String? vehicleRegistration;
  final String? description;
  final double? totalWeight;
  final String? recipientName;
  final String? recipientPhone;
  final String? specialHandlingInstructions;
  final bool? insured;

  CreateShipmentRequest({
    required this.contractId,
    required this.transportMode,
    required this.pickupLocationName,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupDate,
    required this.deliveryLocationName,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.expectedDeliveryDate,
    this.vehicleRegistration,
    this.description,
    this.totalWeight,
    this.recipientName,
    this.recipientPhone,
    this.specialHandlingInstructions,
    this.insured,
  });

  Map<String, dynamic> toJson() {
    return {
      'contractId': contractId,
      'transportMode': transportMode,
      'pickupLocationName': pickupLocationName,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'pickupDate': pickupDate.toIso8601String(),
      'deliveryLocationName': deliveryLocationName,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
      'vehicleRegistration': vehicleRegistration,
      'description': description,
      'totalWeight': totalWeight,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'specialHandlingInstructions': specialHandlingInstructions,
      'insured': insured,
    };
  }
}

class UpdateShipmentStatusRequest {
  final String status;
  final String? notes;
  final String? deliveryFailureReason;

  UpdateShipmentStatusRequest({
    required this.status,
    this.notes,
    this.deliveryFailureReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'notes': notes,
      'deliveryFailureReason': deliveryFailureReason,
    };
  }
}

class AddTrackingEventRequest {
  final String eventType;
  final String message;
  final String? latitude;
  final String? longitude;
  final String? locationName;
  final dynamic metadata;

  AddTrackingEventRequest({
    required this.eventType,
    required this.message,
    this.latitude,
    this.longitude,
    this.locationName,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'message': message,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'metadata': metadata,
    };
  }
}

class CaptureDeliveryProofRequest {
  final String proofType;
  final String description;
  final String? dataBlobUrl;
  final String? recipientName;
  final String? recipientIdNumber;
  final dynamic conditionAssessment;
  final String? latitude;
  final String? longitude;
  final bool isVerified;
  final String capturedById;

  CaptureDeliveryProofRequest({
    required this.proofType,
    required this.description,
    this.dataBlobUrl,
    this.recipientName,
    this.recipientIdNumber,
    this.conditionAssessment,
    this.latitude,
    this.longitude,
    required this.isVerified,
    required this.capturedById,
  });

  Map<String, dynamic> toJson() {
    return {
      'proofType': proofType,
      'description': description,
      'dataBlobUrl': dataBlobUrl,
      'recipientName': recipientName,
      'recipientIdNumber': recipientIdNumber,
      'conditionAssessment': conditionAssessment,
      'latitude': latitude,
      'longitude': longitude,
      'isVerified': isVerified,
      'capturedById': capturedById,
    };
  }
}

class RescheduleDeliveryRequest {
  final DateTime expectedDeliveryDate;
  final String? notes;

  RescheduleDeliveryRequest({
    required this.expectedDeliveryDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'expectedDeliveryDate': expectedDeliveryDate.toIso8601String(),
      'notes': notes,
    };
  }
}
