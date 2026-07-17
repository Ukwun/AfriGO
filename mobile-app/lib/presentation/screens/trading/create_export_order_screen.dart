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
  late final TextEditingController _productController;
  late final TextEditingController _quantityController;
  late final TextEditingController _buyerController;
  late final TextEditingController _destinationController;
  late AnimationController _animationController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController();
    _quantityController = TextEditingController();
    _buyerController = TextEditingController();
    _destinationController = TextEditingController();

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
    _destinationController.dispose();
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Indicator
                ScaleInTransition(
                  child: _buildProgressIndicator(),
                ),
                const SizedBox(height: 32),

                // Form Content
                if (_currentStep == 0) ..._buildProductStep(),
                if (_currentStep == 1) ..._buildBuyerStep(),
                if (_currentStep == 2) ..._buildDeliveryStep(),
                if (_currentStep == 3) ..._buildReviewStep(),

                const SizedBox(height: 32),

                // Navigation Buttons
                ScaleInTransition(
                  child: _buildNavigationButtons(),
                ),
                const SizedBox(height: 32),
              ],
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
        ),
      ),
      const SizedBox(height: 16),
      ScaleInTransition(
        child: _buildInputField(
          controller: _quantityController,
          label: 'Quantity',
          hintText: '5000',
          suffix: 'kg',
          keyboardType: TextInputType.number,
        ),
      ),
      const SizedBox(height: 16),
      ScaleInTransition(
        child: _buildDropdownField(
          label: 'Unit of Measurement',
          value: 'kg',
          items: ['kg', 'tonnes', 'litres', 'boxes'],
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
        ),
      ),
      const SizedBox(height: 16),
      ScaleInTransition(
        child: _buildInputField(
          controller: TextEditingController(text: 'buyer@globaltraders.com'),
          label: 'Buyer Email',
          hintText: 'buyer@company.com',
          readOnly: false,
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
        ),
      ),
      const SizedBox(height: 16),
      ScaleInTransition(
        child: _buildDropdownField(
          label: 'Incoterms',
          value: 'CIF',
          items: ['CIF', 'FOB', 'EXW', 'DDP'],
        ),
      ),
      const SizedBox(height: 16),
      ScaleInTransition(
        child: _buildInputField(
          controller: TextEditingController(text: '2024-09-15'),
          label: 'Delivery Date',
          hintText: 'YYYY-MM-DD',
          readOnly: false,
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
              _buildReviewItem('Quantity', '${_quantityController.text} kg'),
              const Divider(height: 16),
              _buildReviewItem('Buyer', _buyerController.text),
              const Divider(height: 16),
              _buildReviewItem('Destination', _destinationController.text),
              const Divider(height: 16),
              _buildReviewItem('Expected Arrival', '15 Sep 2024'),
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
                        'Please review the information before creating the export order.',
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
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
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
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
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (_) {},
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
                  child: const Text('Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (_currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  _submitOrder();
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentStep < 3 ? 'Next' : 'Create Order',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Export order created successfully!')),
    );
    context.pop();
  }
}
