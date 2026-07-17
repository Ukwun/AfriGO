import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/api_client.dart';
import '../models/lots_model.dart';
import '../models/payment_model.dart';
import '../models/contract_model.dart';

final _api = ApiClient();

DateTime _date(dynamic value) {
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  if (value is Map) {
    final seconds = value['_seconds'] ?? value['seconds'];
    if (seconds is num) {
      return DateTime.fromMillisecondsSinceEpoch(seconds.toInt() * 1000);
    }
  }
  return DateTime.now();
}

double _number(dynamic value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;

List<Map<String, dynamic>> _records(Map<String, dynamic> response) =>
    (response['data'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

LotModel _lot(Map<String, dynamic> item) {
  final ownerId = (item['supplierId'] ?? item['sellerId'] ?? item['ownerId'] ?? '').toString();
  final quantity = _number(item['quantity']);
  final price = _number(item['pricePerUnit'] ?? item['unitPrice']);
  return LotModel(
    id: item['id'].toString(),
    productName: (item['productName'] ?? item['commodity'] ?? 'Unnamed lot').toString(),
    category: (item['category'] ?? item['commodity'] ?? 'Other').toString(),
    quantity: quantity,
    quantityReserved: _number(item['quantityReserved']),
    quantitySold: _number(item['quantitySold']),
    quantityUnit: (item['quantityUnit'] ?? item['unit'] ?? 'kg').toString(),
    pricePerUnit: price,
    totalValue: _number(item['totalValue']) == 0 ? quantity * price : _number(item['totalValue']),
    batchNumber: (item['batchNumber'] ?? item['id']).toString(),
    qrCode: (item['qrCode'] ?? item['id']).toString(),
    originCountry: (item['originCountry'] ?? item['country'] ?? '').toString(),
    originRegion: item['originRegion']?.toString(),
    originLocation: item['originLocation']?.toString(),
    pickupLocation: (item['pickupLocation'] ?? item['originLocation'] ?? '').toString(),
    latitude: _number(item['latitude']),
    longitude: _number(item['longitude']),
    harvestDate: item['harvestDate'] == null ? null : _date(item['harvestDate']),
    productionDate: item['productionDate'] == null ? null : _date(item['productionDate']),
    expiryDate: item['expiryDate'] == null ? null : _date(item['expiryDate']),
    gradeLevel: (item['gradeLevel'] ?? item['grade'] ?? 'Pending verification').toString(),
    status: (item['status'] ?? 'draft').toString(),
    verifyStatus: (item['verifyStatus'] ?? item['verificationStatus'] ?? 'pending').toString(),
    seller: SellerModel(
      id: ownerId,
      email: (item['supplierEmail'] ?? item['sellerEmail'] ?? '').toString(),
      firstName: item['supplierName']?.toString(),
    ),
    images: List<String>.from(item['images'] ?? item['photoUrls'] ?? const []),
    certifications: List<String>.from(item['certifications'] ?? const []),
    certifiedOrganic: item['certifiedOrganic'] == true,
    fairTradeCertified: item['fairTradeCertified'] == true,
    createdAt: _date(item['createdAt']),
    updatedAt: _date(item['updatedAt']),
  );
}

final lotsListProvider = FutureProvider<List<LotModel>>((ref) async {
  final response = await _api.get('/lots');
  return _records(response).map(_lot).toList();
});

final supplierLotsProvider = FutureProvider<List<LotModel>>(
  (ref) => ref.watch(lotsListProvider.future),
);

final lotDetailProvider = FutureProvider.family<LotModel, String>((ref, id) async {
  return _lot(await _api.get('/lots/$id'));
});

PaymentModel _payment(Map<String, dynamic> item) => PaymentModel(
      id: item['id'].toString(),
      orderId: item['orderId']?.toString(),
      contractId: item['contractId']?.toString(),
      buyerId: item['buyerId']?.toString(),
      sellerId: (item['supplierId'] ?? item['sellerId'])?.toString(),
      amount: _number(item['amount']),
      currency: (item['currency'] ?? 'USD').toString(),
      paymentMethod: (item['provider'] ?? item['paymentMethod'] ?? 'ESCROW').toString(),
      paymentStatus: item['status']?.toString(),
      status: item['status']?.toString(),
      description: item['description']?.toString(),
      reference: item['reference']?.toString(),
      flutterwavePaymentUrl: item['flutterwavePaymentUrl']?.toString(),
      escrowStatus: item['escrowStatus']?.toString(),
      stripePaymentIntentId: item['stripePaymentIntentId']?.toString(),
      paymentDate: item['paymentDate'] == null ? null : _date(item['paymentDate']),
      createdAt: _date(item['createdAt']),
      updatedAt: item['updatedAt'] == null ? null : _date(item['updatedAt']),
    );

final paymentsListProvider = FutureProvider<List<PaymentModel>>((ref) async {
  return _records(await _api.get('/payments')).map(_payment).toList();
});

final paymentDetailProvider =
    FutureProvider.family<PaymentModel, String>((ref, id) async {
  return _payment(await _api.get('/payments/$id'));
});

ContractModel _contract(Map<String, dynamic> item) {
  final created = _date(item['createdAt']);
  final deadline = item['signatureDeadline'] == null
      ? created.add(const Duration(days: 7))
      : _date(item['signatureDeadline']);
  return ContractModel(
    id: item['id'].toString(),
    lotId: (item['lotId'] ?? '').toString(),
    rfqId: item['rfqId']?.toString(),
    buyerId: (item['buyerId'] ?? '').toString(),
    buyerName: (item['buyerName'] ?? 'Buyer').toString(),
    sellerId: (item['supplierId'] ?? item['sellerId'] ?? '').toString(),
    sellerName: (item['supplierName'] ?? item['sellerName'] ?? 'Supplier').toString(),
    contractType: (item['contractType'] ?? 'standard').toString(),
    status: (item['status'] ?? 'draft').toString(),
    templateName: (item['templateName'] ?? 'Trade contract').toString(),
    totalValue: _number(item['totalValue']),
    totalQuantity: _number(item['totalQuantity'] ?? item['quantity']),
    unit: (item['unit'] ?? 'kg').toString(),
    currency: (item['currency'] ?? 'USD').toString(),
    pricePerUnit: _number(item['pricePerUnit']),
    requiredGrade: (item['requiredGrade'] ?? 'As agreed').toString(),
    paymentMethod: (item['paymentMethod'] ?? 'escrow').toString(),
    depositPercentage: _number(item['depositPercentage']),
    signatureDeadline: deadline,
    deliveryStartDate: item['deliveryStartDate'] == null ? deadline : _date(item['deliveryStartDate']),
    deliveryEndDate: item['deliveryEndDate'] == null ? deadline.add(const Duration(days: 30)) : _date(item['deliveryEndDate']),
    expiryDate: item['expiryDate'] == null ? deadline.add(const Duration(days: 30)) : _date(item['expiryDate']),
    buyerSigned: item['buyerSigned'] == true,
    sellerSigned: item['supplierSigned'] == true || item['sellerSigned'] == true,
    isDisputed: item['isDisputed'] == true,
    amendmentCount: (item['amendmentCount'] as num?)?.toInt() ?? 0,
    insuranceRequired: item['insuranceRequired'] == true,
    phytosanitaryCertificateRequired: item['phytosanitaryCertificateRequired'] == true,
    createdAt: created,
  );
}

final contractsListProvider = FutureProvider<List<ContractModel>>((ref) async {
  return _records(await _api.get('/contracts')).map(_contract).toList();
});

final contractDetailProvider =
    FutureProvider.family<ContractModel, String>((ref, id) async {
  return _contract(await _api.get('/contracts/$id'));
});
