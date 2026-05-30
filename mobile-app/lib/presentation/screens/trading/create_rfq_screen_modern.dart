import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../widgets/modern_components.dart';

class CreateRFQScreen extends StatefulWidget {
  const CreateRFQScreen({super.key});
  @override
  State<CreateRFQScreen> createState() => _CreateRFQScreenState();
}

class _CreateRFQScreenState extends State<CreateRFQScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _productController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  late AnimationController _animationController;

  String _selectedQuality = 'premium';
  DateTime? _deliveryDate;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController();
    _quantityController = TextEditingController();
    _descriptionController = TextEditingController();
    _budgetController = TextEditingController();
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
    _descriptionController.dispose();
    _budgetController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitRFQ() async {
    if (_productController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _deliveryDate == null) {
      setState(() => _errorMessage = 'Please fill in all required fields');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ RFQ sent successfully!'),
          backgroundColor: AfrigoColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to submit RFQ');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      appBar: AppBar(
        title: Text('Request for Quote', style: AfrigoTypography.soraHeading5),
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
                if (_errorMessage != null) ...[
                  ModernErrorState(
                    title: 'Validation Error',
                    message: _errorMessage!,
                    icon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: AfrigoSpacing.lg),
                ],

                // What are you looking for?
                Text(
                  'What are you looking for?',
                  style: AfrigoTypography.soraHeading5,
                ),
                const SizedBox(height: AfrigoSpacing.md),
                TextField(
                  controller: _productController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Cocoa Beans, Cashews',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: AfrigoSpacing.xxl),

                // Quantity & Budget
                Text(
                  'Quantity & Budget',
                  style: AfrigoTypography.soraHeading5,
                ),
                const SizedBox(height: AfrigoSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity*',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AfrigoSpacing.md),
                    SizedBox(
                      width: 80,
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
                  controller: _budgetController,
                  decoration: const InputDecoration(
                    labelText: 'Budget',
                    hintText: '\$10,000',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AfrigoSpacing.xxl),

                // Quality
                Text(
                  'Preferred Quality',
                  style: AfrigoTypography.soraHeading5,
                ),
                const SizedBox(height: AfrigoSpacing.md),
                Row(
                  children: [
                    _buildQualityOption('standard', 'Standard'),
                    const SizedBox(width: AfrigoSpacing.md),
                    _buildQualityOption('premium', 'Premium'),
                    const SizedBox(width: AfrigoSpacing.md),
                    _buildQualityOption('organic', 'Organic'),
                  ],
                ),
                const SizedBox(height: AfrigoSpacing.xxl),

                // Delivery Date
                Text(
                  'Needed By*',
                  style: AfrigoTypography.soraHeading5,
                ),
                const SizedBox(height: AfrigoSpacing.md),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(
                        const Duration(days: 7),
                      ),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 180),
                      ),
                    );
                    if (date != null) {
                      setState(() => _deliveryDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AfrigoSpacing.lg),
                    decoration: BoxDecoration(
                      color: AfrigoColors.bgLightAlt,
                      border: Border.all(
                        color: AfrigoColors.borderLight,
                      ),
                      borderRadius: BorderRadius.circular(
                        AfriBorderRadius.md,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AfrigoColors.primary,
                        ),
                        const SizedBox(width: AfrigoSpacing.lg),
                        Expanded(
                          child: Text(
                            _deliveryDate == null
                                ? 'Select delivery date'
                                : 'By ${_deliveryDate!.toString().split(' ')[0]}',
                            style: _deliveryDate == null
                                ? AfrigoTypography.interBody1.copyWith(
                                    color: AfrigoColors.textSecondary,
                                  )
                                : AfrigoTypography.interBody1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AfrigoSpacing.xxl),

                // Description
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Details',
                    hintText: 'Any specific requirements...',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AfrigoSpacing.xxl),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ModernButton(
                    onPressed: _submitRFQ,
                    isLoading: _isSubmitting,
                    child: const Text('Send RFQ'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQualityOption(String value, String label) {
    final isSelected = _selectedQuality == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedQuality = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: AfrigoSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AfrigoColors.primary : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.transparent : AfrigoColors.borderLight,
            ),
            borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
          ),
          child: Center(
            child: Text(
              label,
              style: AfrigoTypography.buttonMedium.copyWith(
                color: isSelected ? Colors.white : AfrigoColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
