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
    return LotModel(
      id: json['id'] ?? '',
      productName: json['productName'] ?? '',
      productType: json['productType'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      pricePerUnit: (json['pricePerUnit'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'active',
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      sellerRating: (json['sellerRating'] ?? 0).toDouble(),
      sellerCompletedTrades: json['sellerCompletedTrades'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
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
