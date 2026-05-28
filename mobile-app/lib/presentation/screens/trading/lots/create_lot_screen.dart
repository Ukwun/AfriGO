import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/services/lot_service.dart';
import '../../../../providers/trading_providers.dart';

/// Create Lot Screen
/// Allows sellers to create and list new lots for trading
/// All data stored in PostgreSQL, real-time operations
///
/// Features:
/// - Create lot from product details
/// - Set quantity, grade, origin
/// - Upload photos (next screen)
/// - Auto-generate QR code
/// - Real API calls to backend
/// - All buttons functional and clickable

class CreateLotScreen extends ConsumerStatefulWidget {
  final String? tradeId;

  const CreateLotScreen({
    Key? key,
    this.tradeId,
  }) : super(key: key);

  @override
  ConsumerState<CreateLotScreen> createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends ConsumerState<CreateLotScreen> {
  late TextEditingController _productNameController;
  late TextEditingController _quantityController;
  late TextEditingController _pricePerUnitController;
  late TextEditingController _originController;
  late TextEditingController _descriptionController;

  String _selectedGrade = 'Grade A';
  String _selectedProductType = 'Cocoa';
  bool _isCreating = false;

  final List<String> _grades = ['Grade A', 'Grade B', 'Grade C', 'Standard'];
  final List<String> _productTypes = [
    'Cocoa',
    'Coffee',
    'Cashews',
    'Shea Butter',
    'Palm Oil'
  ];

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController();
    _quantityController = TextEditingController();
    _pricePerUnitController = TextEditingController();
    _originController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _quantityController.dispose();
    _pricePerUnitController.dispose();
    _originController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Create lot with all details
  Future<void> _createLot() async {
    if (!_validateForm()) return;

    setState(() => _isCreating = true);

    try {
      final lotService = LotService();

      print('🏷️  Creating new lot...');

      final lot = await lotService.createLot(
        productName: _productNameController.text,
        productType: _selectedProductType,
        quantity: int.parse(_quantityController.text),
        quantityUnit: 'kg',
        pricePerUnit: double.parse(_pricePerUnitController.text),
        grade: _selectedGrade,
        origin: _originController.text,
        description: _descriptionController.text,
      );

      print('✅ Lot Created:');
      print('   - Lot ID: ${lot['lotId']}');
      print('   - Product: $_selectedProductType');
      print('   - Quantity: ${_quantityController.text} kg');
      print('   - QR Code Generated');
      print('   - Ready for photos');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Lot created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to photo upload
        context.push('/trading/lot-photo-upload/${lot['lotId']}');
      }
    } catch (e) {
      print('❌ Lot Creation Failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating lot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isCreating = false);
    }
  }

  /// Validate all form fields
  bool _validateForm() {
    if (_productNameController.text.isEmpty) {
      _showError('Please enter product name');
      return false;
    }
    if (_quantityController.text.isEmpty) {
      _showError('Please enter quantity');
      return false;
    }
    if (_pricePerUnitController.text.isEmpty) {
      _showError('Please enter price per unit');
      return false;
    }
    if (_originController.text.isEmpty) {
      _showError('Please enter product origin');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('⚠️  $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Lot'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              _buildHeaderCard(context),
              const SizedBox(height: 24),

              // Product type section
              _buildProductTypeSection(context),
              const SizedBox(height: 16),

              // Product details section
              _buildProductDetailsSection(context),
              const SizedBox(height: 16),

              // Grade and pricing section
              _buildGradePricingSection(context),
              const SizedBox(height: 16),

              // Origin and description
              _buildOriginDescriptionSection(context),
              const SizedBox(height: 24),

              // Summary card
              _buildSummaryCard(context),
              const SizedBox(height: 24),

              // Action buttons
              _buildActionButtons(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      key: const Key('create_lot_header'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a New Lot',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'List your product for sale on AfriGo Marketplace',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '✅ All lots stored permanently with unique QR code',
              style: TextStyle(fontSize: 12, color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTypeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Type',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          key: const Key('product_type_dropdown'),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedProductType,
            isExpanded: true,
            underline: const SizedBox(),
            items: _productTypes
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedProductType = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Details',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('product_name_field'),
          controller: _productNameController,
          decoration: InputDecoration(
            labelText: 'Product Name',
            hintText: 'e.g., Premium Cocoa Beans',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('quantity_field'),
          controller: _quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Quantity (kg)',
            hintText: '1000',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradePricingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grade & Pricing',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          key: const Key('grade_dropdown'),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: _selectedGrade,
            isExpanded: true,
            underline: const SizedBox(),
            items: _grades
                .map((grade) => DropdownMenuItem(
                      value: grade,
                      child: Text(grade),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedGrade = value);
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('price_field'),
          controller: _pricePerUnitController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Price per Unit (\$)',
            hintText: '2.40',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOriginDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Origin & Description',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('origin_field'),
          controller: _originController,
          decoration: InputDecoration(
            labelText: 'Origin Country/Region',
            hintText: 'e.g., Uganda - Kampala Region',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('description_field'),
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Product Description',
            hintText: 'Add details about harvest date, certifications, etc.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_pricePerUnitController.text) ?? 0.0;
    final total = quantity * price;

    return Container(
      key: const Key('lot_summary_card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lot Summary',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Value:'),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Quantity:'),
              Text('${quantity > 0 ? quantity : 0} kg'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grade:'),
              Text(_selectedGrade),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            key: const Key('create_lot_button'),
            icon: const Icon(Icons.add_circle),
            label: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text('CREATE LOT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: _isCreating ? null : _createLot,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('cancel_button'),
            icon: const Icon(Icons.close),
            label: const Text('CANCEL'),
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }
}
