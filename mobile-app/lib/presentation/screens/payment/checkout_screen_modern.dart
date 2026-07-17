import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../widgets/modern_components.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedPaymentMethod = 0;
  bool _isProcessing = false;
  String? _errorMessage;
  bool _agreedToTerms = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 0,
      'name': 'Flutterwave',
      'icon': '💳',
      'description': 'Credit/Debit Card'
    },
    {
      'id': 1,
      'name': 'Mobile Money',
      'icon': '📱',
      'description': 'MTN, Vodafone, Airtel'
    },
    {
      'id': 2,
      'name': 'Bank Transfer',
      'icon': '🏦',
      'description': 'Direct bank transfer'
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_agreedToTerms) {
      setState(
          () => _errorMessage = 'Please agree to the terms and conditions');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      // Show success
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AfriBorderRadius.xl),
          ),
          title: Text(
            'Payment Successful! ✅',
            style: AfrigoTypography.soraHeading5,
          ),
          content: Text(
            'Your order has been placed. You will receive a confirmation email shortly.',
            style: AfrigoTypography.interBody1,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('View Order'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _errorMessage = 'Payment failed. Please try again.');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      appBar: AppBar(
        title: Text('Checkout', style: AfrigoTypography.soraHeading5),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Order Summary
              Padding(
                padding: const EdgeInsets.all(AfrigoSpacing.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
                    border: Border.all(
                      color: AfrigoColors.borderLight,
                    ),
                    boxShadow: AfrigoElevation.shadow1,
                  ),
                  padding: const EdgeInsets.all(AfrigoSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: AfrigoTypography.soraHeading5,
                      ),
                      const SizedBox(height: AfrigoSpacing.lg),
                      _buildSummaryRow(
                        'Premium Cocoa Beans (500kg)',
                        '\$2,500.00',
                      ),
                      const SizedBox(height: AfrigoSpacing.md),
                      _buildSummaryRow(
                        'Shipping',
                        '\$150.00',
                      ),
                      const SizedBox(height: AfrigoSpacing.md),
                      const Divider(
                        color: AfrigoColors.borderLight,
                        height: AfrigoSpacing.lg,
                      ),
                      _buildSummaryRow(
                        'Total',
                        '\$2,650.00',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),

              // Payment Method Selection
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AfrigoSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Payment Method',
                      style: AfrigoTypography.soraHeading5,
                    ),
                    const SizedBox(height: AfrigoSpacing.lg),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _paymentMethods.length,
                      itemBuilder: (context, index) {
                        final method = _paymentMethods[index];
                        final isSelected = _selectedPaymentMethod == index;
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AfrigoSpacing.md,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedPaymentMethod = index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AfrigoColors.bgLightAlt
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? AfrigoColors.primary
                                      : AfrigoColors.borderLight,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AfriBorderRadius.lg,
                                ),
                              ),
                              padding: const EdgeInsets.all(
                                AfrigoSpacing.lg,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    method['icon'],
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(
                                    width: AfrigoSpacing.lg,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          method['name'],
                                          style:
                                              AfrigoTypography.interBody1Semi,
                                        ),
                                        Text(
                                          method['description'],
                                          style: AfrigoTypography.bodySmall
                                              .copyWith(
                                            color: AfrigoColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AfrigoColors.primary,
                                        borderRadius: BorderRadius.circular(
                                          AfriBorderRadius.full,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AfrigoSpacing.lg),

              // Error Display
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AfrigoSpacing.lg,
                  ),
                  child: ModernErrorState(
                    title: 'Error',
                    message: _errorMessage!,
                    icon: Icons.error_outline,
                  ),
                ),

              const SizedBox(height: AfrigoSpacing.lg),

              // Terms Checkbox
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AfrigoSpacing.lg,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() => _agreedToTerms = value ?? false);
                        },
                        activeColor: AfrigoColors.primary,
                      ),
                    ),
                    const SizedBox(width: AfrigoSpacing.md),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _agreedToTerms = !_agreedToTerms);
                        },
                        child: Text(
                          'I agree to the Terms of Service and Privacy Policy',
                          style: AfrigoTypography.bodySmall.copyWith(
                            color: AfrigoColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AfrigoSpacing.xxl),

              // Pay Button
              Padding(
                padding: const EdgeInsets.all(AfrigoSpacing.lg),
                child: ModernButton(
                  onPressed: _processPayment,
                  isLoading: _isProcessing,
                  child: const Text('Complete Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String amount, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AfrigoTypography.interBody1Semi
              : AfrigoTypography.interBody1.copyWith(
                  color: AfrigoColors.textSecondary,
                ),
        ),
        Text(
          amount,
          style: isBold
              ? AfrigoTypography.soraHeading5.copyWith(
                  color: AfrigoColors.primary,
                )
              : AfrigoTypography.interBody1,
        ),
      ],
    );
  }
}
