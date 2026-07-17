class ContractModel {
  final String id;
  final String lotId;
  final String? rfqId;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final String contractType;
  final String status;
  final String templateName;
  final double totalValue;
  final double totalQuantity;
  final String unit;
  final String currency;
  final double pricePerUnit;
  final String requiredGrade;
  final String? qualitySpecifications;
  final String? deliveryTerms;
  final String paymentMethod;
  final double depositPercentage;
  final int? installmentCount;
  final int? paymentDuesDays;
  final DateTime signatureDeadline;
  final DateTime deliveryStartDate;
  final DateTime deliveryEndDate;
  final DateTime expiryDate;
  final bool buyerSigned;
  final DateTime? buyerSignedAt;
  final bool sellerSigned;
  final DateTime? sellerSignedAt;
  final bool isDisputed;
  final String? disputeReason;
  final int amendmentCount;
  final bool insuranceRequired;
  final String? insurancePolicyNumber;
  final bool phytosanitaryCertificateRequired;
  final DateTime createdAt;
  final DateTime? executedAt;

  ContractModel({
    required this.id,
    required this.lotId,
    this.rfqId,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.contractType,
    required this.status,
    required this.templateName,
    required this.totalValue,
    required this.totalQuantity,
    required this.unit,
    required this.currency,
    required this.pricePerUnit,
    required this.requiredGrade,
    this.qualitySpecifications,
    this.deliveryTerms,
    required this.paymentMethod,
    required this.depositPercentage,
    this.installmentCount,
    this.paymentDuesDays,
    required this.signatureDeadline,
    required this.deliveryStartDate,
    required this.deliveryEndDate,
    required this.expiryDate,
    required this.buyerSigned,
    this.buyerSignedAt,
    required this.sellerSigned,
    this.sellerSignedAt,
    required this.isDisputed,
    this.disputeReason,
    required this.amendmentCount,
    required this.insuranceRequired,
    this.insurancePolicyNumber,
    required this.phytosanitaryCertificateRequired,
    required this.createdAt,
    this.executedAt,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'] as String,
      lotId: json['lotId'] as String,
      rfqId: json['rfqId'] as String?,
      buyerId: json['buyerId'] as String,
      buyerName: json['buyerName'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      contractType: json['contractType'] as String,
      status: json['status'] as String,
      templateName: json['templateName'] as String,
      totalValue: (json['totalValue'] as num).toDouble(),
      totalQuantity: (json['totalQuantity'] as num).toDouble(),
      unit: json['unit'] as String,
      currency: json['currency'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      requiredGrade: json['requiredGrade'] as String,
      qualitySpecifications: json['qualitySpecifications'] as String?,
      deliveryTerms: json['deliveryTerms'] as String?,
      paymentMethod: json['paymentMethod'] as String,
      depositPercentage: (json['depositPercentage'] as num).toDouble(),
      installmentCount: json['installmentCount'] as int?,
      paymentDuesDays: json['paymentDuesDays'] as int?,
      signatureDeadline: DateTime.parse(json['signatureDeadline'] as String),
      deliveryStartDate: DateTime.parse(json['deliveryStartDate'] as String),
      deliveryEndDate: DateTime.parse(json['deliveryEndDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      buyerSigned: json['buyerSigned'] as bool,
      buyerSignedAt: json['buyerSignedAt'] != null
          ? DateTime.parse(json['buyerSignedAt'] as String)
          : null,
      sellerSigned: json['sellerSigned'] as bool,
      sellerSignedAt: json['sellerSignedAt'] != null
          ? DateTime.parse(json['sellerSignedAt'] as String)
          : null,
      isDisputed: json['isDisputed'] as bool,
      disputeReason: json['disputeReason'] as String?,
      amendmentCount: json['amendmentCount'] as int,
      insuranceRequired: json['insuranceRequired'] as bool,
      insurancePolicyNumber: json['insurancePolicyNumber'] as String?,
      phytosanitaryCertificateRequired:
          json['phytosanitaryCertificateRequired'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      executedAt: json['executedAt'] != null
          ? DateTime.parse(json['executedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lotId': lotId,
      'rfqId': rfqId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'contractType': contractType,
      'status': status,
      'templateName': templateName,
      'totalValue': totalValue,
      'totalQuantity': totalQuantity,
      'unit': unit,
      'currency': currency,
      'pricePerUnit': pricePerUnit,
      'requiredGrade': requiredGrade,
      'qualitySpecifications': qualitySpecifications,
      'deliveryTerms': deliveryTerms,
      'paymentMethod': paymentMethod,
      'depositPercentage': depositPercentage,
      'installmentCount': installmentCount,
      'paymentDuesDays': paymentDuesDays,
      'signatureDeadline': signatureDeadline.toIso8601String(),
      'deliveryStartDate': deliveryStartDate.toIso8601String(),
      'deliveryEndDate': deliveryEndDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'buyerSigned': buyerSigned,
      'buyerSignedAt': buyerSignedAt?.toIso8601String(),
      'sellerSigned': sellerSigned,
      'sellerSignedAt': sellerSignedAt?.toIso8601String(),
      'isDisputed': isDisputed,
      'disputeReason': disputeReason,
      'amendmentCount': amendmentCount,
      'insuranceRequired': insuranceRequired,
      'insurancePolicyNumber': insurancePolicyNumber,
      'phytosanitaryCertificateRequired': phytosanitaryCertificateRequired,
      'createdAt': createdAt.toIso8601String(),
      'executedAt': executedAt?.toIso8601String(),
    };
  }
}

class ContractListModel {
  final String id;
  final String contractType;
  final String status;
  final double totalValue;
  final String buyerName;
  final String sellerName;
  final DateTime signatureDeadline;
  final DateTime deliveryEndDate;
  final bool buyerSigned;
  final bool sellerSigned;
  final bool isDisputed;
  final DateTime createdAt;

  ContractListModel({
    required this.id,
    required this.contractType,
    required this.status,
    required this.totalValue,
    required this.buyerName,
    required this.sellerName,
    required this.signatureDeadline,
    required this.deliveryEndDate,
    required this.buyerSigned,
    required this.sellerSigned,
    required this.isDisputed,
    required this.createdAt,
  });

  factory ContractListModel.fromJson(Map<String, dynamic> json) {
    return ContractListModel(
      id: json['id'] as String,
      contractType: json['contractType'] as String,
      status: json['status'] as String,
      totalValue: (json['totalValue'] as num).toDouble(),
      buyerName: json['buyerName'] as String,
      sellerName: json['sellerName'] as String,
      signatureDeadline: DateTime.parse(json['signatureDeadline'] as String),
      deliveryEndDate: DateTime.parse(json['deliveryEndDate'] as String),
      buyerSigned: json['buyerSigned'] as bool,
      sellerSigned: json['sellerSigned'] as bool,
      isDisputed: json['isDisputed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractType': contractType,
      'status': status,
      'totalValue': totalValue,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'signatureDeadline': signatureDeadline.toIso8601String(),
      'deliveryEndDate': deliveryEndDate.toIso8601String(),
      'buyerSigned': buyerSigned,
      'sellerSigned': sellerSigned,
      'isDisputed': isDisputed,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ContractAmendmentModel {
  final String id;
  final String contractId;
  final String reason;
  final String description;
  final String? proposedChanges;
  final String status;
  final bool buyerApproved;
  final bool sellerApproved;
  final String? rejectionReason;
  final String submittedByName;
  final DateTime createdAt;
  final DateTime? approvedAt;

  ContractAmendmentModel({
    required this.id,
    required this.contractId,
    required this.reason,
    required this.description,
    this.proposedChanges,
    required this.status,
    required this.buyerApproved,
    required this.sellerApproved,
    this.rejectionReason,
    required this.submittedByName,
    required this.createdAt,
    this.approvedAt,
  });

  factory ContractAmendmentModel.fromJson(Map<String, dynamic> json) {
    return ContractAmendmentModel(
      id: json['id'] as String,
      contractId: json['contractId'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String,
      proposedChanges: json['proposedChanges'] as String?,
      status: json['status'] as String,
      buyerApproved: json['buyerApproved'] as bool,
      sellerApproved: json['sellerApproved'] as bool,
      rejectionReason: json['rejectionReason'] as String?,
      submittedByName: json['submittedByName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractId': contractId,
      'reason': reason,
      'description': description,
      'proposedChanges': proposedChanges,
      'status': status,
      'buyerApproved': buyerApproved,
      'sellerApproved': sellerApproved,
      'rejectionReason': rejectionReason,
      'submittedByName': submittedByName,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
    };
  }
}

class CreateContractRequest {
  final String rfqId;
  final String lotId;
  final String buyerId;
  final String sellerId;
  final String contractType;
  final String templateName;
  final double totalValue;
  final double totalQuantity;
  final String unit;
  final String currency;
  final double pricePerUnit;
  final String requiredGrade;
  final String? qualitySpecifications;
  final String? deliveryTerms;
  final String paymentMethod;
  final double depositPercentage;
  final int? installmentCount;
  final int? paymentDuesDays;
  final DateTime signatureDeadline;
  final DateTime deliveryStartDate;
  final DateTime deliveryEndDate;
  final DateTime expiryDate;
  final bool insuranceRequired;
  final String? insuranceProvider;
  final bool phytosanitaryCertificateRequired;
  final String? additionalTerms;

  CreateContractRequest({
    required this.rfqId,
    required this.lotId,
    required this.buyerId,
    required this.sellerId,
    required this.contractType,
    required this.templateName,
    required this.totalValue,
    required this.totalQuantity,
    required this.unit,
    required this.currency,
    required this.pricePerUnit,
    required this.requiredGrade,
    this.qualitySpecifications,
    this.deliveryTerms,
    required this.paymentMethod,
    required this.depositPercentage,
    this.installmentCount,
    this.paymentDuesDays,
    required this.signatureDeadline,
    required this.deliveryStartDate,
    required this.deliveryEndDate,
    required this.expiryDate,
    required this.insuranceRequired,
    this.insuranceProvider,
    required this.phytosanitaryCertificateRequired,
    this.additionalTerms,
  });

  factory CreateContractRequest.fromJson(Map<String, dynamic> json) {
    return CreateContractRequest(
      rfqId: json['rfqId'] as String,
      lotId: json['lotId'] as String,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      contractType: json['contractType'] as String,
      templateName: json['templateName'] as String,
      totalValue: (json['totalValue'] as num).toDouble(),
      totalQuantity: (json['totalQuantity'] as num).toDouble(),
      unit: json['unit'] as String,
      currency: json['currency'] as String,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      requiredGrade: json['requiredGrade'] as String,
      qualitySpecifications: json['qualitySpecifications'] as String?,
      deliveryTerms: json['deliveryTerms'] as String?,
      paymentMethod: json['paymentMethod'] as String,
      depositPercentage: (json['depositPercentage'] as num).toDouble(),
      installmentCount: json['installmentCount'] as int?,
      paymentDuesDays: json['paymentDuesDays'] as int?,
      signatureDeadline: DateTime.parse(json['signatureDeadline'] as String),
      deliveryStartDate: DateTime.parse(json['deliveryStartDate'] as String),
      deliveryEndDate: DateTime.parse(json['deliveryEndDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      insuranceRequired: json['insuranceRequired'] as bool? ?? false,
      insuranceProvider: json['insuranceProvider'] as String?,
      phytosanitaryCertificateRequired:
          json['phytosanitaryCertificateRequired'] as bool? ?? false,
      additionalTerms: json['additionalTerms'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rfqId': rfqId,
      'lotId': lotId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'contractType': contractType,
      'templateName': templateName,
      'totalValue': totalValue,
      'totalQuantity': totalQuantity,
      'unit': unit,
      'currency': currency,
      'pricePerUnit': pricePerUnit,
      'requiredGrade': requiredGrade,
      'qualitySpecifications': qualitySpecifications,
      'deliveryTerms': deliveryTerms,
      'paymentMethod': paymentMethod,
      'depositPercentage': depositPercentage,
      'installmentCount': installmentCount,
      'paymentDuesDays': paymentDuesDays,
      'signatureDeadline': signatureDeadline.toIso8601String(),
      'deliveryStartDate': deliveryStartDate.toIso8601String(),
      'deliveryEndDate': deliveryEndDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'insuranceRequired': insuranceRequired,
      'insuranceProvider': insuranceProvider,
      'phytosanitaryCertificateRequired': phytosanitaryCertificateRequired,
      'additionalTerms': additionalTerms,
    };
  }
}

class SignContractRequest {
  final String contractId;
  final String signature;
  final bool agreeToTerms;
  final String? ipAddress;
  final String? deviceInfo;

  SignContractRequest({
    required this.contractId,
    required this.signature,
    required this.agreeToTerms,
    this.ipAddress,
    this.deviceInfo,
  });

  factory SignContractRequest.fromJson(Map<String, dynamic> json) {
    return SignContractRequest(
      contractId: json['contractId'] as String,
      signature: json['signature'] as String,
      agreeToTerms: json['agreeToTerms'] as bool,
      ipAddress: json['ipAddress'] as String?,
      deviceInfo: json['deviceInfo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contractId': contractId,
      'signature': signature,
      'agreeToTerms': agreeToTerms,
      'ipAddress': ipAddress,
      'deviceInfo': deviceInfo,
    };
  }
}

class AmendContractRequest {
  final String contractId;
  final String reason;
  final String description;
  final String? proposedChanges;
  final double? newPrice;
  final double? newQuantity;
  final DateTime? newDeliveryDate;
  final String? newQuality;

  AmendContractRequest({
    required this.contractId,
    required this.reason,
    required this.description,
    this.proposedChanges,
    this.newPrice,
    this.newQuantity,
    this.newDeliveryDate,
    this.newQuality,
  });

  factory AmendContractRequest.fromJson(Map<String, dynamic> json) {
    return AmendContractRequest(
      contractId: json['contractId'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String,
      proposedChanges: json['proposedChanges'] as String?,
      newPrice: (json['newPrice'] as num?)?.toDouble(),
      newQuantity: (json['newQuantity'] as num?)?.toDouble(),
      newDeliveryDate: json['newDeliveryDate'] != null
          ? DateTime.parse(json['newDeliveryDate'] as String)
          : null,
      newQuality: json['newQuality'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contractId': contractId,
      'reason': reason,
      'description': description,
      'proposedChanges': proposedChanges,
      'newPrice': newPrice,
      'newQuantity': newQuantity,
      'newDeliveryDate': newDeliveryDate?.toIso8601String(),
      'newQuality': newQuality,
    };
  }
}

class ApproveAmendmentRequest {
  final String amendmentId;
  final bool approved;
  final String? rejectionReason;

  ApproveAmendmentRequest({
    required this.amendmentId,
    required this.approved,
    this.rejectionReason,
  });

  factory ApproveAmendmentRequest.fromJson(Map<String, dynamic> json) {
    return ApproveAmendmentRequest(
      amendmentId: json['amendmentId'] as String,
      approved: json['approved'] as bool,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amendmentId': amendmentId,
      'approved': approved,
      'rejectionReason': rejectionReason,
    };
  }
}

class InitiateDisputeRequest {
  final String contractId;
  final String disputeReason;
  final String evidence;
  final String? preferredMediatorId;

  InitiateDisputeRequest({
    required this.contractId,
    required this.disputeReason,
    required this.evidence,
    this.preferredMediatorId,
  });

  factory InitiateDisputeRequest.fromJson(Map<String, dynamic> json) {
    return InitiateDisputeRequest(
      contractId: json['contractId'] as String,
      disputeReason: json['disputeReason'] as String,
      evidence: json['evidence'] as String,
      preferredMediatorId: json['preferredMediatorId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contractId': contractId,
      'disputeReason': disputeReason,
      'evidence': evidence,
      'preferredMediatorId': preferredMediatorId,
    };
  }
}

class ContractSummaryModel {
  final String text;
  final DateTime generatedAt;

  ContractSummaryModel({
    required this.text,
    required this.generatedAt,
  });

  factory ContractSummaryModel.fromJson(Map<String, dynamic> json) {
    return ContractSummaryModel(
      text: json['text'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}
