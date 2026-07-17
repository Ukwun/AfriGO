class LotModel {
  final String id;
  final String productName;
  final String category;
  final double quantity;
  final double quantityReserved;
  final double quantitySold;
  final String quantityUnit;
  final double pricePerUnit;
  final double totalValue;
  final String batchNumber;
  final String qrCode;
  final String originCountry;
  final String? originRegion;
  final String? originLocation;
  final String pickupLocation;
  final double latitude;
  final double longitude;
  final DateTime? harvestDate;
  final DateTime? productionDate;
  final DateTime? expiryDate;
  final String gradeLevel;
  final String status;
  final String verifyStatus;
  final SellerModel seller;
  final List<String> images;
  final List<String> certifications;
  final bool certifiedOrganic;
  final bool fairTradeCertified;
  final DateTime createdAt;
  final DateTime updatedAt;

  LotModel({
    required this.id,
    required this.productName,
    required this.category,
    required this.quantity,
    required this.quantityReserved,
    required this.quantitySold,
    required this.quantityUnit,
    required this.pricePerUnit,
    required this.totalValue,
    required this.batchNumber,
    required this.qrCode,
    required this.originCountry,
    this.originRegion,
    this.originLocation,
    required this.pickupLocation,
    required this.latitude,
    required this.longitude,
    this.harvestDate,
    this.productionDate,
    this.expiryDate,
    required this.gradeLevel,
    required this.status,
    required this.verifyStatus,
    required this.seller,
    required this.images,
    required this.certifications,
    required this.certifiedOrganic,
    required this.fairTradeCertified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LotModel.fromJson(Map<String, dynamic> json) {
    return LotModel(
      id: json['id'] as String,
      productName: json['productName'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      quantityReserved: (json['quantityReserved'] as num).toDouble(),
      quantitySold: (json['quantitySold'] as num).toDouble(),
      quantityUnit: json['quantityUnit'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      totalValue: (json['totalValue'] as num).toDouble(),
      batchNumber: json['batchNumber'] as String,
      qrCode: json['qrCode'] as String,
      originCountry: json['originCountry'] as String,
      originRegion: json['originRegion'] as String?,
      originLocation: json['originLocation'] as String?,
      pickupLocation: json['pickupLocation'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      harvestDate: json['harvestDate'] != null
          ? DateTime.parse(json['harvestDate'] as String)
          : null,
      productionDate: json['productionDate'] != null
          ? DateTime.parse(json['productionDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      gradeLevel: json['gradeLevel'] as String,
      status: json['status'] as String,
      verifyStatus: json['verifyStatus'] as String,
      seller: SellerModel.fromJson(json['seller'] as Map<String, dynamic>),
      images: List<String>.from(json['images'] as List),
      certifications: List<String>.from(json['certifications'] as List),
      certifiedOrganic: json['certifiedOrganic'] as bool,
      fairTradeCertified: json['fairTradeCertified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'category': category,
      'quantity': quantity,
      'quantityReserved': quantityReserved,
      'quantitySold': quantitySold,
      'quantityUnit': quantityUnit,
      'pricePerUnit': pricePerUnit,
      'totalValue': totalValue,
      'batchNumber': batchNumber,
      'qrCode': qrCode,
      'originCountry': originCountry,
      'originRegion': originRegion,
      'originLocation': originLocation,
      'pickupLocation': pickupLocation,
      'latitude': latitude,
      'longitude': longitude,
      'harvestDate': harvestDate?.toIso8601String(),
      'productionDate': productionDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'gradeLevel': gradeLevel,
      'status': status,
      'verifyStatus': verifyStatus,
      'seller': seller.toJson(),
      'images': images,
      'certifications': certifications,
      'certifiedOrganic': certifiedOrganic,
      'fairTradeCertified': fairTradeCertified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class SellerModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;

  SellerModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}

class LotTraceabilityModel {
  final String id;
  final String lotId;
  final String eventType;
  final String? description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;

  LotTraceabilityModel({
    required this.id,
    required this.lotId,
    required this.eventType,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    required this.timestamp,
  });

  factory LotTraceabilityModel.fromJson(Map<String, dynamic> json) {
    return LotTraceabilityModel(
      id: json['id'] as String,
      lotId: json['lotId'] as String,
      eventType: json['eventType'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lotId': lotId,
      'eventType': eventType,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class CreateLotRequest {
  final String productName;
  final String category;
  final double quantity;
  final String quantityUnit;
  final double pricePerUnit;
  final String description;
  final List<String> images;
  final String originCountry;
  final String? originRegion;
  final String? originLocation;
  final String pickupLocation;
  final double latitude;
  final double longitude;
  final DateTime? harvestDate;
  final DateTime? productionDate;
  final DateTime? expiryDate;
  final String? gradeLevel;
  final double? moistureContent;
  final double? afflatoxinLevel;
  final double? foreignMatterPercentage;
  final List<String>? certifications;
  final bool? certifiedOrganic;
  final bool? fairTradeCertified;

  CreateLotRequest({
    required this.productName,
    required this.category,
    required this.quantity,
    required this.quantityUnit,
    required this.pricePerUnit,
    required this.description,
    required this.images,
    required this.originCountry,
    this.originRegion,
    this.originLocation,
    required this.pickupLocation,
    required this.latitude,
    required this.longitude,
    this.harvestDate,
    this.productionDate,
    this.expiryDate,
    this.gradeLevel,
    this.moistureContent,
    this.afflatoxinLevel,
    this.foreignMatterPercentage,
    this.certifications,
    this.certifiedOrganic,
    this.fairTradeCertified,
  });

  factory CreateLotRequest.fromJson(Map<String, dynamic> json) {
    return CreateLotRequest(
      productName: json['productName'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      quantityUnit: json['quantityUnit'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      description: json['description'] as String,
      images: List<String>.from(json['images'] as List),
      originCountry: json['originCountry'] as String,
      originRegion: json['originRegion'] as String?,
      originLocation: json['originLocation'] as String?,
      pickupLocation: json['pickupLocation'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      harvestDate: json['harvestDate'] != null
          ? DateTime.parse(json['harvestDate'] as String)
          : null,
      productionDate: json['productionDate'] != null
          ? DateTime.parse(json['productionDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      gradeLevel: json['gradeLevel'] as String?,
      moistureContent: (json['moistureContent'] as num?)?.toDouble(),
      afflatoxinLevel: (json['afflatoxinLevel'] as num?)?.toDouble(),
      foreignMatterPercentage:
          (json['foreignMatterPercentage'] as num?)?.toDouble(),
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'] as List)
          : null,
      certifiedOrganic: json['certifiedOrganic'] as bool?,
      fairTradeCertified: json['fairTradeCertified'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'category': category,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'pricePerUnit': pricePerUnit,
      'description': description,
      'images': images,
      'originCountry': originCountry,
      'originRegion': originRegion,
      'originLocation': originLocation,
      'pickupLocation': pickupLocation,
      'latitude': latitude,
      'longitude': longitude,
      'harvestDate': harvestDate?.toIso8601String(),
      'productionDate': productionDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'gradeLevel': gradeLevel,
      'moistureContent': moistureContent,
      'afflatoxinLevel': afflatoxinLevel,
      'foreignMatterPercentage': foreignMatterPercentage,
      'certifications': certifications,
      'certifiedOrganic': certifiedOrganic,
      'fairTradeCertified': fairTradeCertified,
    };
  }
}
