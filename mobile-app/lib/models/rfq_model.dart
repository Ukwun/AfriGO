class RFQModel {
  final String id;
  final String buyerId;
  final String buyerEmail;
  final String buyerCompanyName;
  final String productCategory;
  final String productDescription;
  final double quantity;
  final String quantityUnit;
  final String? originCountryPreference;
  final String? gradePreference;
  final String? deliveryLocation;
  final DateTime deliveryDeadline;
  final String paymentTerms;
  final int maxBidsExpected;
  final List<RFQBidModel> submittedBids;
  final String status;
  final String? selectedSupplierId;
  final String? selectedSupplierBidId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String description;

  RFQModel({
    required this.id,
    required this.buyerId,
    required this.buyerEmail,
    required this.buyerCompanyName,
    required this.productCategory,
    required this.productDescription,
    required this.quantity,
    required this.quantityUnit,
    this.originCountryPreference,
    this.gradePreference,
    this.deliveryLocation,
    required this.deliveryDeadline,
    required this.paymentTerms,
    required this.maxBidsExpected,
    required this.submittedBids,
    required this.status,
    this.selectedSupplierId,
    this.selectedSupplierBidId,
    required this.createdAt,
    required this.expiresAt,
    required this.description,
  });

  factory RFQModel.fromJson(Map<String, dynamic> json) {
    return RFQModel(
      id: json['id'] as String,
      buyerId: json['buyerId'] as String,
      buyerEmail: json['buyerEmail'] as String,
      buyerCompanyName: json['buyerCompanyName'] as String,
      productCategory: json['productCategory'] as String,
      productDescription: json['productDescription'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      quantityUnit: json['quantityUnit'] as String,
      originCountryPreference: json['originCountryPreference'] as String?,
      gradePreference: json['gradePreference'] as String?,
      deliveryLocation: json['deliveryLocation'] as String?,
      deliveryDeadline: DateTime.parse(json['deliveryDeadline'] as String),
      paymentTerms: json['paymentTerms'] as String,
      maxBidsExpected: json['maxBidsExpected'] as int,
      submittedBids: (json['submittedBids'] as List<dynamic>)
          .map((e) => RFQBidModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      selectedSupplierId: json['selectedSupplierId'] as String?,
      selectedSupplierBidId: json['selectedSupplierBidId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerEmail': buyerEmail,
      'buyerCompanyName': buyerCompanyName,
      'productCategory': productCategory,
      'productDescription': productDescription,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'originCountryPreference': originCountryPreference,
      'gradePreference': gradePreference,
      'deliveryLocation': deliveryLocation,
      'deliveryDeadline': deliveryDeadline.toIso8601String(),
      'paymentTerms': paymentTerms,
      'maxBidsExpected': maxBidsExpected,
      'submittedBids': submittedBids.map((e) => e.toJson()).toList(),
      'status': status,
      'selectedSupplierId': selectedSupplierId,
      'selectedSupplierBidId': selectedSupplierBidId,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'description': description,
    };
  }
}

class RFQBidModel {
  final String id;
  final String rfqId;
  final String supplierId;
  final String supplierEmail;
  final String supplierCompanyName;
  final double pricePerUnit;
  final double totalPrice;
  final String? originCountry;
  final String? gradeLevel;
  final DateTime estimatedDelivery;
  final String paymentMethod;
  final String? specialTerms;
  final String status;
  final DateTime submittedAt;
  final int documentCount;
  final List<String>? certificationsIncluded;

  RFQBidModel({
    required this.id,
    required this.rfqId,
    required this.supplierId,
    required this.supplierEmail,
    required this.supplierCompanyName,
    required this.pricePerUnit,
    required this.totalPrice,
    this.originCountry,
    this.gradeLevel,
    required this.estimatedDelivery,
    required this.paymentMethod,
    this.specialTerms,
    required this.status,
    required this.submittedAt,
    required this.documentCount,
    this.certificationsIncluded,
  });

  factory RFQBidModel.fromJson(Map<String, dynamic> json) {
    return RFQBidModel(
      id: json['id'] as String,
      rfqId: json['rfqId'] as String,
      supplierId: json['supplierId'] as String,
      supplierEmail: json['supplierEmail'] as String,
      supplierCompanyName: json['supplierCompanyName'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      originCountry: json['originCountry'] as String?,
      gradeLevel: json['gradeLevel'] as String?,
      estimatedDelivery: DateTime.parse(json['estimatedDelivery'] as String),
      paymentMethod: json['paymentMethod'] as String,
      specialTerms: json['specialTerms'] as String?,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      documentCount: json['documentCount'] as int,
      certificationsIncluded: (json['certificationsIncluded'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rfqId': rfqId,
      'supplierId': supplierId,
      'supplierEmail': supplierEmail,
      'supplierCompanyName': supplierCompanyName,
      'pricePerUnit': pricePerUnit,
      'totalPrice': totalPrice,
      'originCountry': originCountry,
      'gradeLevel': gradeLevel,
      'estimatedDelivery': estimatedDelivery.toIso8601String(),
      'paymentMethod': paymentMethod,
      'specialTerms': specialTerms,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
      'documentCount': documentCount,
      'certificationsIncluded': certificationsIncluded,
    };
  }
}

class CreateRFQRequest {
  final String productCategory;
  final String productDescription;
  final double quantity;
  final String quantityUnit;
  final String? originCountryPreference;
  final String? gradePreference;
  final String? deliveryLocation;
  final DateTime deliveryDeadline;
  final String paymentTerms;
  final int maxBidsExpected;
  final String description;

  CreateRFQRequest({
    required this.productCategory,
    required this.productDescription,
    required this.quantity,
    required this.quantityUnit,
    this.originCountryPreference,
    this.gradePreference,
    this.deliveryLocation,
    required this.deliveryDeadline,
    required this.paymentTerms,
    required this.maxBidsExpected,
    required this.description,
  });

  factory CreateRFQRequest.fromJson(Map<String, dynamic> json) {
    return CreateRFQRequest(
      productCategory: json['productCategory'] as String,
      productDescription: json['productDescription'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      quantityUnit: json['quantityUnit'] as String,
      originCountryPreference: json['originCountryPreference'] as String?,
      gradePreference: json['gradePreference'] as String?,
      deliveryLocation: json['deliveryLocation'] as String?,
      deliveryDeadline: DateTime.parse(json['deliveryDeadline'] as String),
      paymentTerms: json['paymentTerms'] as String,
      maxBidsExpected: json['maxBidsExpected'] as int,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productCategory': productCategory,
      'productDescription': productDescription,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'originCountryPreference': originCountryPreference,
      'gradePreference': gradePreference,
      'deliveryLocation': deliveryLocation,
      'deliveryDeadline': deliveryDeadline.toIso8601String(),
      'paymentTerms': paymentTerms,
      'maxBidsExpected': maxBidsExpected,
      'description': description,
    };
  }
}

class SubmitBidRequest {
  final String rfqId;
  final double pricePerUnit;
  final String originCountry;
  final String gradeLevel;
  final DateTime estimatedDelivery;
  final String paymentMethod;
  final String? specialTerms;
  final List<String>? certificationsIncluded;

  SubmitBidRequest({
    required this.rfqId,
    required this.pricePerUnit,
    required this.originCountry,
    required this.gradeLevel,
    required this.estimatedDelivery,
    required this.paymentMethod,
    this.specialTerms,
    this.certificationsIncluded,
  });

  factory SubmitBidRequest.fromJson(Map<String, dynamic> json) {
    return SubmitBidRequest(
      rfqId: json['rfqId'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      originCountry: json['originCountry'] as String,
      gradeLevel: json['gradeLevel'] as String,
      estimatedDelivery: DateTime.parse(json['estimatedDelivery'] as String),
      paymentMethod: json['paymentMethod'] as String,
      specialTerms: json['specialTerms'] as String?,
      certificationsIncluded: (json['certificationsIncluded'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rfqId': rfqId,
      'pricePerUnit': pricePerUnit,
      'originCountry': originCountry,
      'gradeLevel': gradeLevel,
      'estimatedDelivery': estimatedDelivery.toIso8601String(),
      'paymentMethod': paymentMethod,
      'specialTerms': specialTerms,
      'certificationsIncluded': certificationsIncluded,
    };
  }
}

class RFQFilterModel {
  final String? status;
  final String? category;
  final String? searchTerm;
  final int page;
  final int limit;

  RFQFilterModel({
    this.status,
    this.category,
    this.searchTerm,
    required this.page,
    required this.limit,
  });

  factory RFQFilterModel.fromJson(Map<String, dynamic> json) {
    return RFQFilterModel(
      status: json['status'] as String?,
      category: json['category'] as String?,
      searchTerm: json['searchTerm'] as String?,
      page: json['page'] as int,
      limit: json['limit'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'category': category,
      'searchTerm': searchTerm,
      'page': page,
      'limit': limit,
    };
  }
}
