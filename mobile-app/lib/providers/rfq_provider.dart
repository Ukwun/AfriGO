import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rfq_model.dart';

// Mock RFQ data provider - replace with Firebase when ready
final rfqListProvider = FutureProvider<List<RFQModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 400));

  return [
    RFQModel(
      id: 'rfq-001',
      buyerId: 'buyer-123',
      buyerEmail: 'buyer@company.com',
      buyerCompanyName: 'Global Traders Ltd',
      productCategory: 'Cocoa',
      productDescription: 'Premium Grade Cocoa Beans - Fermented & Dried',
      quantity: 10000,
      quantityUnit: 'kg',
      originCountryPreference: 'Ghana',
      gradePreference: 'Grade A',
      deliveryLocation: 'Lagos, Nigeria',
      deliveryDeadline: DateTime.now().add(const Duration(days: 30)),
      paymentTerms: 'L/C at Sight',
      maxBidsExpected: 5,
      submittedBids: [],
      status: 'open',
      selectedSupplierId: null,
      selectedSupplierBidId: null,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      expiresAt: DateTime.now().add(const Duration(days: 10)),
      description: 'Looking for high-quality cocoa beans for processing',
    ),
    RFQModel(
      id: 'rfq-002',
      buyerId: 'buyer-123',
      buyerEmail: 'buyer@company.com',
      buyerCompanyName: 'Global Traders Ltd',
      productCategory: 'Shea Butter',
      productDescription: 'Organic Shea Butter - Unrefined',
      quantity: 5000,
      quantityUnit: 'liters',
      originCountryPreference: 'Burkina Faso',
      gradePreference: 'Premium',
      deliveryLocation: 'Lagos, Nigeria',
      deliveryDeadline: DateTime.now().add(const Duration(days: 25)),
      paymentTerms: 'Payment against documents',
      maxBidsExpected: 4,
      submittedBids: [],
      status: 'evaluating',
      selectedSupplierId: null,
      selectedSupplierBidId: null,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      expiresAt: DateTime.now().add(const Duration(days: 3)),
      description: 'Seeking reliable supplier for bulk shea butter',
    ),
    RFQModel(
      id: 'rfq-003',
      buyerId: 'buyer-456',
      buyerEmail: 'procurement@buyer2.com',
      buyerCompanyName: 'African Agro Traders',
      productCategory: 'Cashew',
      productDescription: 'Raw Cashew Nuts - W320',
      quantity: 20000,
      quantityUnit: 'kg',
      originCountryPreference: 'Ivory Coast',
      gradePreference: 'Grade A',
      deliveryLocation: 'Port of Singapore',
      deliveryDeadline: DateTime.now().add(const Duration(days: 45)),
      paymentTerms: '30% deposit, 70% on shipment',
      maxBidsExpected: 6,
      submittedBids: [],
      status: 'awarded',
      selectedSupplierId: 'supplier-789',
      selectedSupplierBidId: 'bid-awarded-001',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      expiresAt: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Large order for regional distribution',
    ),
  ];
});

// Provider for detailed RFQ view
final rfqDetailProvider =
    FutureProvider.family<RFQModel, String>((ref, rfqId) async {
  final list = await ref.watch(rfqListProvider.future);
  return list.firstWhere((rfq) => rfq.id == rfqId);
});

// Provider to track open RFQs for suppliers
final openRfqsForSuppliersProvider =
    FutureProvider<List<RFQModel>>((ref) async {
  final list = await ref.watch(rfqListProvider.future);
  return list.where((rfq) => rfq.status == 'open').toList();
});

// Provider to track user's submitted bids
final userSubmittedBidsProvider =
    FutureProvider<List<RFQBidModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));

  return [
    RFQBidModel(
      id: 'bid-001',
      rfqId: 'rfq-001',
      supplierId: 'supplier-xyz',
      supplierEmail: 'supplier@company.com',
      supplierCompanyName: 'Premium Cocoa Co',
      pricePerUnit: 1.25,
      totalPrice: 12500,
      originCountry: 'Ghana',
      gradeLevel: 'Grade A',
      estimatedDelivery: DateTime.now().add(const Duration(days: 28)),
      paymentMethod: 'L/C',
      specialTerms: 'Bulk discount available for repeat orders',
      status: 'pending',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
});
