import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class LotEditScreen extends ConsumerStatefulWidget {
  final String lotId;

  const LotEditScreen({
    super.key,
    required this.lotId,
  });

  @override
  ConsumerState<LotEditScreen> createState() => _LotEditScreenState();
}

class _LotEditScreenState extends ConsumerState<LotEditScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _locationController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: '12500');
    _quantityController = TextEditingController(text: '5000');
    _locationController = TextEditingController(text: 'Kumasi, Ghana');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Lot ${widget.lotId}'),
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
                // Product Info
                ScaleInTransition(
                  child: _buildInfoSection(),
                ),
                const SizedBox(height: 24),

                // Pricing
                ScaleInTransition(
                  child: _buildSectionHeader('Pricing'),
                ),
                const SizedBox(height: 12),
                ScaleInTransition(
                  child: _buildInputField(
                    controller: _priceController,
                    label: 'Price per Unit (USD)',
                    prefix: '\$',
                  ),
                ),
                const SizedBox(height: 24),

                // Stock Allocation
                ScaleInTransition(
                  child: _buildSectionHeader('Stock Allocation'),
                ),
                const SizedBox(height: 12),
                ScaleInTransition(
                  child: _buildInputField(
                    controller: _quantityController,
                    label: 'Available Quantity (kg)',
                    suffix: 'kg',
                  ),
                ),
                const SizedBox(height: 24),

                // Location
                ScaleInTransition(
                  child: _buildSectionHeader('Location'),
                ),
                const SizedBox(height: 12),
                ScaleInTransition(
                  child: _buildInputField(
                    controller: _locationController,
                    label: 'Pickup Location',
                  ),
                ),
                const SizedBox(height: 24),

                // Certifications
                ScaleInTransition(
                  child: _buildCertificationsSection(),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                ScaleInTransition(
                  child: Row(
                    children: [
                      Expanded(
                        child:
                            _buildButton('Cancel', false, () => context.pop()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildButton('Save', true, _handleSave),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryGold.withOpacity(0.1),
            AppColors.accentBlue.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGold.withOpacity(0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Premium Cocoa Beans',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Grade A • Kumasi, Ghana',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
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

  Widget _buildCertificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Certifications'),
        const SizedBox(height: 12),
        _buildCertificationCheckbox('Organic Certified', true),
        _buildCertificationCheckbox('Fair Trade', false),
        _buildCertificationCheckbox('Rainforest Alliance', true),
      ],
    );
  }

  Widget _buildCertificationCheckbox(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: (_) {}),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildButton(String label, bool isPrimary, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.accentBlue : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: !isPrimary ? Border.all(color: Colors.grey[300]!) : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isPrimary ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lot ${widget.lotId} updated successfully!')),
    );
    context.pop();
  }
}
