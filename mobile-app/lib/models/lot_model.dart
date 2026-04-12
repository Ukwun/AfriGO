class LotModel {
  final String id;
  final String sellerId;
  final String? sellerName;
  final double? sellerRating;
  final String productName;
  final double quantity;
  final String quantityUnit;
  final double pricePerUnit;
  final String description;
  final List<String> images;
  final String pickupLocation;
  final double latitude;
  final double longitude;
  final String? qrCode;
  final String status; // draft, active, sold, expired
  final String verifyStatus; // pending, verified, rejected
  final List<String> certifications;
  final String? category;
  final int viewCount;
  final double averageRating;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  LotModel({
    required this.id,
    required this.sellerId,
    this.sellerName,
    this.sellerRating,
    required this.productName,
    required this.quantity,
    required this.quantityUnit,
    required this.pricePerUnit,
    required this.description,
    required this.images,
    required this.pickupLocation,
    required this.latitude,
    required this.longitude,
    this.qrCode,
    required this.status,
    required this.verifyStatus,
    required this.certifications,
    this.category,
    required this.viewCount,
    required this.averageRating,
    required this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON (API response)
  factory LotModel.fromJson(Map<String, dynamic> json) {
    return LotModel(
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String?,
      sellerRating: json['sellerRating'] != null
          ? double.parse(json['sellerRating'].toString())
          : null,
      productName: json['productName'] as String,
      quantity: double.parse(json['quantity'].toString()),
      quantityUnit: json['quantityUnit'] as String,
      pricePerUnit: double.parse(json['pricePerUnit'].toString()),
      description: json['description'] as String,
      images: List<String>.from(json['images'] as List? ?? []),
      pickupLocation: json['pickupLocation'] as String,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      qrCode: json['qrCode'] as String?,
      status: json['status'] as String,
      verifyStatus: json['verifyStatus'] as String,
      certifications: List<String>.from(json['certifications'] as List? ?? []),
      category: json['category'] as String?,
      viewCount: json['viewCount'] as int? ?? 0,
      averageRating: double.parse((json['averageRating'] ?? 0).toString()),
      ratingCount: json['ratingCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerRating': sellerRating,
      'productName': productName,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'pricePerUnit': pricePerUnit,
      'description': description,
      'images': images,
      'pickupLocation': pickupLocation,
      'latitude': latitude,
      'longitude': longitude,
      'qrCode': qrCode,
      'status': status,
      'verifyStatus': verifyStatus,
      'certifications': certifications,
      'category': category,
      'viewCount': viewCount,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Copy constructor for immutability
  LotModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    double? sellerRating,
    String? productName,
    double? quantity,
    String? quantityUnit,
    double? pricePerUnit,
    String? description,
    List<String>? images,
    String? pickupLocation,
    double? latitude,
    double? longitude,
    String? qrCode,
    String? status,
    String? verifyStatus,
    List<String>? certifications,
    String? category,
    int? viewCount,
    double? averageRating,
    int? ratingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LotModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerRating: sellerRating ?? this.sellerRating,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      description: description ?? this.description,
      images: images ?? this.images,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      verifyStatus: verifyStatus ?? this.verifyStatus,
      certifications: certifications ?? this.certifications,
      category: category ?? this.category,
      viewCount: viewCount ?? this.viewCount,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'LotModel(id: $id, product: $productName, price: \$$pricePerUnit)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LotModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
