import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class CreateExportOrderScreen extends ConsumerStatefulWidget {
  const CreateExportOrderScreen({super.key});

  @override
  ConsumerState<CreateExportOrderScreen> createState() =>
      _CreateExportOrderScreenState();
}

class _CreateExportOrderScreenState
    extends ConsumerState<CreateExportOrderScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _productController;
  late final TextEditingController _quantityController;
  late final TextEditingController _buyerController;
  late final TextEditingController _buyerEmailController;
  late final TextEditingController _destinationController;
  late final TextEditingController _deliveryDateController;

  late AnimationController _animationController;

  String _selectedUnit = 'kg';
  String _selectedIncoterm = 'CIF';
  int _currentStep = 0;
  bool _isSubmitting = false;

  final List<String> _units = ['kg', 'tonnes', 'litres', 'boxes'];
  final List<String> _incoterms = ['CIF', 'FOB', 'EXW', 'DDP'];

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;

    _productController = TextEditingController();
    _quantityController = TextEditingController();
    _buyerController = TextEditingController();
    _buyerEmailController = TextEditingController(
      text: currentUser?.email ?? '',
    );
    _destinationController = TextEditingController();
    _deliveryDateController = TextEditingController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    _buyerController.dispose();
    _buyerEmailController.dispose();
    _destinationController.dispose();
    _deliveryDateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Export Order'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaleInTransition(
                    child: _buildProgressIndicator(),
                  ),
                  const SizedBox(height: 32),
                  if (_currentStep == 0) ..._buildProductStep(),
                  if (_currentStep == 1) ..._buildBuyerStep(),
                  if (_currentStep == 2) ..._buildDeliveryStep(),
                  if (_currentStep == 3) ..._buildReviewStep(),
                  const SizedBox(height: 32),
                  ScaleInTransition(
                    child: _buildNavigationButtons(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${_currentStep + 1} of 4',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            minHeight: 6,
            backgroundColor: Colors.grey[300],
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildProductStep() {
    return [
      ScaleInTransition(
        child: _buildSectionHeader('Product Information'),
      ),
      const SizedBox(height: 24),
      ScaleInTransition(
        child: _buildInputField(
          controller: _productController,
          label: 'Product Name',
          hintText: 'E.g., Premium Cocoa Beans Grade A',
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter a product name'
              : null,
        ),
      ),
      const SizedBox(height: 16),
      ScaleInTransition(
        child: _buildInputField(
          controller: _quantityController,
          label: 'Quantity',
          hintText: '5000',
          suffix: _selectedUnit,
          keyboardType: TextInputType.number,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter a quantity' : null,
        ),
      ),
      const SizedBox(height: 16),
      ScaleInTransition(
        child: _buildDropdownField(
          label: 'Unit of Measurement',
          value: _selectedUnit,
          items: _units,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedUnit = value);
          },
        ),
      ),
    ];
  }

  List<Widget> _buildBuyerStep() {
    return [
      ScaleInTransition(
        child: _buildSectionHeader('Buyer Information'),
      ),
      const SizedBox(height: 24),
      ScaleInTransition(
        child: _buildInputField(
          controller: _buyerController,
          label: 'Buyer Company Name',
          hintText: 'E.g., Global Traders Ltd',
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter buyer company'
              : null,
        ),
      ),
      const SizedBox(height: 16),
      ScaleInTransition(
        child: _buildInputField(
          controller: _buyerEmailController,
          label: 'Buyer Email',
          hintText: 'buyer@company.com',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter buyer email';
            }
            return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)
                ? null
                : 'Enter a valid email address';
          },
        ),
      ),
    ];
  }

  List<Widget> _buildDeliveryStep() {
    return [
      ScaleInTransition(
        child: _buildSectionHeader('Delivery Details'),
      ),
      const SizedBox(height: 24),
      ScaleInTransition(
        child: _buildInputField(
          controller: _destinationController,
          label: 'Destination Country',
          hintText: 'E.g., Germany',
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter destination country'
              : null,
        ),
      ),
      const SizedBox(height: 16),
      ScaleInTransition(
        child: _buildDropdownField(
          label: 'Incoterms',
          value: _selectedIncoterm,
          items: _incoterms,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedIncoterm = value);
          },
        ),
      ),
      const SizedBox(height: 16),
      ScaleInTransition(
        child: _buildInputField(
          controller: _deliveryDateController,
          label: 'Delivery Date',
          hintText: 'YYYY-MM-DD',
          keyboardType: TextInputType.datetime,
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Enter delivery date'
              : null,
        ),
      ),
    ];
  }

  List<Widget> _buildReviewStep() {
    return [
      ScaleInTransition(
        child: _buildSectionHeader('Review & Confirm'),
      ),
      const SizedBox(height: 24),
      ScaleInTransition(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewItem('Product', _productController.text),
              const Divider(height: 16),
              _buildReviewItem(
                  'Quantity', '${_quantityController.text} $_selectedUnit'),
              const Divider(height: 16),
              _buildReviewItem('Buyer', _buyerController.text),
              const Divider(height: 16),
              _buildReviewItem('Destination', _destinationController.text),
              const Divider(height: 16),
              _buildReviewItem('Delivery Date', _deliveryDateController.text),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This order will be saved to the live records and audited as part of the transaction workflow.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildReviewItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? suffix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _currentStep--),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isSubmitting
                  ? null
                  : () {
                      if (_currentStep < 3) {
                        if (_formKey.currentState?.validate() ?? false) {
                          setState(() => _currentStep++);
                        }
                      } else {
                        _submitOrder();
                      }
                    },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isSubmitting ? Colors.grey : AppColors.accentBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isSubmitting
                      ? 'Saving...'
                      : (_currentStep < 3 ? 'Next' : 'Create Order'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitOrder() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('You must be signed in to create an order.');
        }

        final orderedQuantity =
            double.tryParse(_quantityController.text.trim());
        if (orderedQuantity == null || orderedQuantity <= 0) {
          throw Exception('Enter a valid quantity greater than zero.');
        }

        final ordersRef =
            FirebaseFirestore.instance.collection('export_orders').doc();
        final createdAt = FieldValue.serverTimestamp();

        final orderData = {
          'id': ordersRef.id,
          'ownerId': user.uid,
          'exporterId': user.uid,
          'participantIds': [user.uid],
          'productName': _productController.text.trim(),
          'quantity': orderedQuantity,
          'quantityUnit': _selectedUnit,
          'buyerCompanyName': _buyerController.text.trim(),
          'buyerEmail': _buyerEmailController.text.trim(),
          'destinationCountry': _destinationController.text.trim(),
          'incoterms': _selectedIncoterm,
          'deliveryDate': _deliveryDateController.text.trim(),
          'status': 'draft',
          'paymentStatus': 'not_paid',
          'createdAt': createdAt,
          'updatedAt': createdAt,
        };

        await ordersRef.set(orderData);

        await FirebaseFirestore.instance.collection('audit_events').add({
          'actorId': user.uid,
          'action': 'export_orders.created',
          'entityType': 'export_orders',
          'entityId': ordersRef.id,
          'details': {
            'productName': orderData['productName'],
            'quantity': orderData['quantity'],
            'destinationCountry': orderData['destinationCountry'],
            'buyerEmail': orderData['buyerEmail'],
          },
          'createdAt': createdAt,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Export order created and saved to live records.'),
          ),
        );
        context.pop();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceFirst('Exception: ', '')),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }
}
