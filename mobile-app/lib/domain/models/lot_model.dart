class LotModel {
  final String id;
  final String productName;
  final String productType;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String currency;
  final String location;
  final String description;
  final String? imageUrl;
  final String status;
  final String sellerId;
  final String sellerName;
  final double sellerRating;
  final int sellerCompletedTrades;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LotModel({
    required this.id,
    required this.productName,
    required this.productType,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.currency,
    required this.location,
    required this.description,
    this.imageUrl,
    required this.status,
    required this.sellerId,
    required this.sellerName,
    required this.sellerRating,
    required this.sellerCompletedTrades,
    required this.createdAt,
    this.updatedAt,
  });

  factory LotModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String) return DateTime.tryParse(value);
      if (value is Map) {
        final seconds = value['_seconds'] ?? value['seconds'];
        if (seconds is num) {
          return DateTime.fromMillisecondsSinceEpoch(seconds.toInt() * 1000);
        }
      }
      return null;
    }
    return LotModel(
      id: json['id'] ?? '',
      productName: json['productName'] ?? '',
      productType: json['productType'] ?? json['category'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? json['quantityUnit'] ?? 'kg',
      pricePerUnit: (json['pricePerUnit'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      location: json['location'] ?? json['originLocation'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ??
          ((json['photoUrls'] is List && json['photoUrls'].isNotEmpty)
              ? json['photoUrls'].first
              : null),
      status: json['status'] ?? 'active',
      sellerId: json['sellerId'] ?? json['supplierId'] ?? json['ownerId'] ?? '',
      sellerName: json['sellerName'] ?? json['supplierName'] ?? '',
      sellerRating: (json['sellerRating'] ?? 0).toDouble(),
      sellerCompletedTrades: json['sellerCompletedTrades'] ?? 0,
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'productType': productType,
        'quantity': quantity,
        'unit': unit,
        'pricePerUnit': pricePerUnit,
        'currency': currency,
        'location': location,
        'description': description,
        'imageUrl': imageUrl,
        'status': status,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'sellerRating': sellerRating,
        'sellerCompletedTrades': sellerCompletedTrades,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
