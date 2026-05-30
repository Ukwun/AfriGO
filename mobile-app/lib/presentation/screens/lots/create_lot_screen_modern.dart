import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../widgets/modern_components.dart';

class CreateLotScreen extends StatefulWidget {
  const CreateLotScreen({super.key});
  @override
  State<CreateLotScreen> createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends State<CreateLotScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _productNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  late AnimationController _animationController;

  String _selectedCategory = 'agriculture';
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0;

  final List<String> _categories = [
    'agriculture',
    'organic',
    'minerals',
    'processed',
  ];

  @override
  void initState() {
    super.initState();
    _productNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _quantityController = TextEditingController();
    _priceController = TextEditingController();
    _locationController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitLot() async {
    if (_productNameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _priceController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      // API call would go here
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Lot created successfully!'),
          backgroundColor: AfrigoColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to create lot');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      appBar: AppBar(
        title: Text('Create Lot', style: AfrigoTypography.soraHeading5),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AfrigoSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) {
                    final isActive = index <= _currentStep;
                    return Expanded(
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AfrigoColors.primary
                                  : AfrigoColors.borderLight,
                              borderRadius: BorderRadius.circular(
                                AfriBorderRadius.full,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : AfrigoColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (index < 2) ...[
                            const SizedBox(height: 8),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: isActive
                                    ? AfrigoColors.primary
                                    : AfrigoColors.borderLight,
                              ),
                            ),
                          ]
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AfrigoSpacing.xxl),

                // Error Display
                if (_errorMessage != null) ...[
                  ModernErrorState(
                    title: 'Error',
                    message: _errorMessage!,
                    icon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: AfrigoSpacing.lg),
                ],

                // Step 1: Basic Info
                if (_currentStep == 0) ...[
                  Text(
                    'Product Details',
                    style: AfrigoTypography.soraHeading4,
                  ),
                  const SizedBox(height: AfrigoSpacing.lg),
                  TextField(
                    controller: _productNameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name*',
                      hintText: 'e.g., Premium Cocoa Beans',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                  ),
                  const SizedBox(height: AfrigoSpacing.lg),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe your product...',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                    maxLines: 3,
                  ),
                ],

                // Step 2: Pricing & Quantity
                if (_currentStep == 1) ...[
                  Text(
                    'Pricing & Quantity',
                    style: AfrigoTypography.soraHeading4,
                  ),
                  const SizedBox(height: AfrigoSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity*',
                            hintText: '1000',
                            prefixIcon: Icon(Icons.weight_outlined),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AfrigoSpacing.md),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            hintText: 'kg',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AfrigoSpacing.lg),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price per Unit*',
                      hintText: '2500',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],

                // Step 3: Location & Category
                if (_currentStep == 2) ...[
                  Text(
                    'Location & Category',
                    style: AfrigoTypography.soraHeading4,
                  ),
                  const SizedBox(height: AfrigoSpacing.lg),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'e.g., Ghana',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: AfrigoSpacing.lg),
                  Text(
                    'Category',
                    style: AfrigoTypography.interBody1Semi,
                  ),
                  const SizedBox(height: AfrigoSpacing.md),
                  Wrap(
                    spacing: AfrigoSpacing.md,
                    runSpacing: AfrigoSpacing.md,
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = category);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AfrigoSpacing.lg,
                            vertical: AfrigoSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AfrigoColors.primary
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : AfrigoColors.borderLight,
                            ),
                            borderRadius: BorderRadius.circular(
                              AfriBorderRadius.lg,
                            ),
                          ),
                          child: Text(
                            category.replaceFirst(
                              category[0],
                              category[0].toUpperCase(),
                            ),
                            style: AfrigoTypography.buttonMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AfrigoColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: AfrigoSpacing.xxl),

                // Navigation Buttons
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: ModernButton(
                          onPressed: () {
                            setState(() => _currentStep--);
                          },
                          child: const Text('Back'),
                        ),
                      )
                    else
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ),
                    const SizedBox(width: AfrigoSpacing.md),
                    Expanded(
                      child: ModernButton(
                        onPressed: _currentStep < 2
                            ? () {
                                setState(() => _currentStep++);
                              }
                            : _submitLot,
                        isLoading: _isLoading && _currentStep == 2,
                        child: Text(
                          _currentStep < 2 ? 'Next' : 'Create Lot',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
