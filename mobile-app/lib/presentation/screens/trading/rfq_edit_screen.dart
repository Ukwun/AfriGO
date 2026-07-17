import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class RfqEditScreen extends ConsumerStatefulWidget {
  final String rfqId;

  const RfqEditScreen({
    super.key,
    required this.rfqId,
  });

  @override
  ConsumerState<RfqEditScreen> createState() => _RfqEditScreenState();
}

class _RfqEditScreenState extends ConsumerState<RfqEditScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _quantityController;
  late final TextEditingController _budgetController;
  late final TextEditingController _deliveryNotesController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedDeliveryTerm = 'CIF';
  String _selectedCategory = 'Cocoa Beans';

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '5000');
    _budgetController = TextEditingController(text: '62500');
    _deliveryNotesController = TextEditingController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _budgetController.dispose();
    _deliveryNotesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit RFQ'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ScaleInTransition(
              child: TextButton(
                onPressed: _showSaveConfirmation,
                child: const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // RFQ ID & Status
                  ScaleInTransition(
                    child: _buildInfoCard(
                      title: 'RFQ #${widget.rfqId}',
                      subtitle: 'Status: Open for Bidding',
                      icon: Icons.request_quote,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Product Category
                  ScaleInTransition(
                    child: _buildSectionHeader('Product Category'),
                  ),
                  const SizedBox(height: 12),
                  ScaleInTransition(
                    child: _buildDropdownField(
                      label: 'Select Product',
                      value: _selectedCategory,
                      items: [
                        'Cocoa Beans',
                        'Shea Butter',
                        'Cashew Nuts',
                        'Coffee',
                        'Cotton'
                      ]
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        setState(() =>
                            _selectedCategory = value ?? _selectedCategory);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quantity
                  ScaleInTransition(
                    child: _buildSectionHeader('Quantity Required'),
                  ),
                  const SizedBox(height: 12),
                  ScaleInTransition(
                    child: _buildInputField(
                      controller: _quantityController,
                      label: 'Quantity (kg/L)',
                      keyboardType: TextInputType.number,
                      suffix: _selectedCategory.contains('Butter') ? 'L' : 'kg',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Budget
                  ScaleInTransition(
                    child: _buildSectionHeader('Budget'),
                  ),
                  const SizedBox(height: 12),
                  ScaleInTransition(
                    child: _buildInputField(
                      controller: _budgetController,
                      label: 'Budget Amount (USD)',
                      keyboardType: TextInputType.number,
                      prefix: '\$',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Delivery Terms
                  ScaleInTransition(
                    child: _buildSectionHeader('Delivery Terms'),
                  ),
                  const SizedBox(height: 12),
                  ScaleInTransition(
                    child: _buildDropdownField(
                      label: 'Incoterms',
                      value: _selectedDeliveryTerm,
                      items: ['CIF', 'FOB', 'EXW', 'DDP']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedDeliveryTerm =
                            value ?? _selectedDeliveryTerm);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Special Notes
                  ScaleInTransition(
                    child: _buildSectionHeader('Delivery Notes & Compliance'),
                  ),
                  const SizedBox(height: 12),
                  ScaleInTransition(
                    child: _buildMultilineField(
                      controller: _deliveryNotesController,
                      label:
                          'Any special requirements, certifications, or quality standards?',
                      maxLines: 4,
                      hintText:
                          'E.g., Organic certification, Fair Trade, specific shipping method...',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  ScaleInTransition(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            label: 'Cancel',
                            onPressed: () => context.pop(),
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            label: 'Save Changes',
                            onPressed: _showSaveConfirmation,
                            isPrimary: true,
                          ),
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
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentBlue.withOpacity(0.1),
            AppColors.secondaryGold.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accentBlue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    String? prefix,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildMultilineField({
    required TextEditingController controller,
    required String label,
    required int maxLines,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isPrimary ? AppColors.accentBlue : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border:
                    !isPrimary ? Border.all(color: Colors.grey[400]!) : null,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSaveConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Changes?'),
          content: const Text(
            'Your RFQ will be updated with the new information. Existing bids will remain active.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _saveChanges();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('RFQ #${widget.rfqId} updated successfully!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }
}
