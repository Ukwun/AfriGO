import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../models/payment_model.dart';
import '../../../models/order_model.dart';
import '../../../services/api_service.dart';
import '../../providers/orders_provider.dart';

// Payment screen state provider
final paymentScreenStateProvider =
    StateNotifierProvider<PaymentScreenStateNotifier, PaymentScreenState>(
        (ref) {
  return PaymentScreenStateNotifier();
});

// Payment screen state
class PaymentScreenState {
  final bool isLoading;
  final bool isProcessing;
  final String? error;
  final PaymentModel? payment;
  final String? selectedCardBrand;
  final double? amount;
  final String? orderId;
  final OrderModel? order;
  final bool showReceipt;

  PaymentScreenState({
    this.isLoading = false,
    this.isProcessing = false,
    this.error,
    this.payment,
    this.selectedCardBrand,
    this.amount,
    this.orderId,
    this.order,
    this.showReceipt = false,
  });

  PaymentScreenState copyWith({
    bool? isLoading,
    bool? isProcessing,
    String? error,
    PaymentModel? payment,
    String? selectedCardBrand,
    double? amount,
    String? orderId,
    OrderModel? order,
    bool? showReceipt,
  }) {
    return PaymentScreenState(
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      payment: payment ?? this.payment,
      selectedCardBrand: selectedCardBrand ?? this.selectedCardBrand,
      amount: amount ?? this.amount,
      orderId: orderId ?? this.orderId,
      order: order ?? this.order,
      showReceipt: showReceipt ?? this.showReceipt,
    );
  }
}

// Payment screen state notifier
class PaymentScreenStateNotifier extends StateNotifier<PaymentScreenState> {
  PaymentScreenStateNotifier() : super(PaymentScreenState());

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setProcessing(bool isProcessing) {
    state = state.copyWith(isProcessing: isProcessing);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void setOrder(OrderModel order) {
    state = state.copyWith(order: order);
  }

  void setPayment(PaymentModel payment) {
    state = state.copyWith(payment: payment, showReceipt: false);
  }

  void setSelectedCardBrand(String? brand) {
    state = state.copyWith(selectedCardBrand: brand);
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void setOrderId(String orderId) {
    state = state.copyWith(orderId: orderId);
  }

  void toggleReceipt() {
    state = state.copyWith(showReceipt: !state.showReceipt);
  }

  void reset() {
    state = PaymentScreenState();
  }
}

/// Payment screen - handles Stripe payment processing
class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;

  const PaymentScreen({
    required this.orderId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryController;
  late TextEditingController _cvcController;
  late TextEditingController _cardholderController;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _expiryController = TextEditingController();
    _cvcController = TextEditingController();
    _cardholderController = TextEditingController();

    // Initialize order data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePayment();
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardholderController.dispose();
    super.dispose();
  }

  Future<void> _initializePayment() async {
    final notifier = ref.read(paymentScreenStateProvider.notifier);
    final ordersService = ref.read(ordersServiceProvider);

    notifier.setOrderId(widget.orderId);
    notifier.setLoading(true);

    try {
      // Load REAL order details from API
      final order = await ordersService.getOrder(widget.orderId);
      notifier.setOrder(order);
      notifier.setAmount(order.totalPrice);
      notifier.setLoading(false);
    } catch (e) {
      notifier.setError('Failed to load order: ${e.toString()}');
      notifier.setLoading(false);
    }
  }

  void _formatCardNumber(String value) {
    // Remove spaces and only keep numbers
    final numbers = value.replaceAll(RegExp(r'\D'), '');

    if (numbers.isNotEmpty) {
      // Detect card brand
      String? brand;
      if (numbers.startsWith('4')) {
        brand = 'visa';
      } else if (numbers.startsWith(RegExp(r'^(51|52|53|54|55)'))) {
        brand = 'mastercard';
      } else if (numbers.startsWith(RegExp(r'^(34|37)'))) {
        brand = 'amex';
      } else if (numbers.startsWith('6011')) {
        brand = 'discover';
      }

      ref.read(paymentScreenStateProvider.notifier).setSelectedCardBrand(brand);
    }

    // Format with spaces every 4 digits
    final formatted = numbers
        .replaceAllMapped(RegExp(r'.{1,4}'), (match) => '${match.group(0)} ')
        .trim();

    if (formatted != value) {
      _cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.fromPosition(
          TextPosition(offset: formatted.length),
        ),
      );
    }
  }

  void _formatExpiry(String value) {
    // Remove non-digits
    final numbers = value.replaceAll(RegExp(r'\D'), '');

    if (numbers.length >= 2) {
      final formatted = '${numbers.substring(0, 2)}/${numbers.substring(2)}';

      if (formatted != value) {
        _expiryController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.fromPosition(
            TextPosition(offset: formatted.length),
          ),
        );
      }
    }
  }

  Future<void> _processPayment() async {
    final state = ref.read(paymentScreenStateProvider);

    // Validate inputs
    if (_cardNumberController.text.isEmpty) {
      _showError('Card number is required');
      return;
    }

    if (_expiryController.text.isEmpty) {
      _showError('Expiry date is required');
      return;
    }

    if (_cvcController.text.isEmpty) {
      _showError('CVC is required');
      return;
    }

    if (_cardholderController.text.isEmpty) {
      _showError('Cardholder name is required');
      return;
    }

    final notifier = ref.read(paymentScreenStateProvider.notifier);
    notifier.setProcessing(true);

    try {
      // In real app, this would:
      // 1. Call Stripe Elements to tokenize card
      // 2. Get payment method ID from Stripe
      // 3. Call backend to create payment

      // Mock implementation
      await Future.delayed(Duration(seconds: 2));

      // Show success
      notifier.setPayment(
        PaymentModel(
          id: 'payment-${DateTime.now().millisecondsSinceEpoch}',
          orderId: widget.orderId,
          userId: 'user-123',
          amount: state.amount ?? 0,
          currency: 'USD',
          status: 'succeeded',
          escrowStatus: 'held',
          paymentMethod: 'card',
          cardInfo: CardInfoModel(
            brand: state.selectedCardBrand ?? 'unknown',
            last4: _cardNumberController.text
                .replaceAll(RegExp(r'\D'), '')
                .substring(12),
            expMonth: int.tryParse(_expiryController.text.split('/')[0]),
            expYear: int.tryParse('20' + _expiryController.text.split('/')[1]),
          ),
          stripePaymentIntentId: 'pi_${DateTime.now().millisecondsSinceEpoch}',
          stripeChargeId: 'ch_${DateTime.now().millisecondsSinceEpoch}',
          receiptUrl: 'https://example.com/receipt',
          createdAt: DateTime.now(),
          paidAt: DateTime.now(),
        ),
      );

      notifier.setProcessing(false);
      _showSuccess('Payment successful!');
    } catch (e) {
      notifier.setError(e.toString());
      notifier.setProcessing(false);
      _showError('Payment failed: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentScreenStateProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Payment')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.payment != null && state.showReceipt) {
      return _buildReceipt(state.payment!);
    }

    if (state.payment != null) {
      return _buildSuccessScreen(state.payment!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary
                _buildOrderSummary(state),
                SizedBox(height: 24),

                // Payment Form
                _buildPaymentForm(state),
                SizedBox(height: 24),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state.isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: state.isProcessing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Pay ${state.amount != null ? '\$${state.amount!.toStringAsFixed(2)}' : ''}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 16),

                // Security Badge
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        'Secure payment powered by Stripe',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (state.error != null) _buildErrorBanner(state.error!),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(PaymentScreenState state) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order Subtotal', style: TextStyle(color: Colors.grey[600])),
              Text(
                '\$${state.amount?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Platform Fee (2%)',
                  style: TextStyle(color: Colors.grey[600])),
              Text(
                state.amount != null
                    ? '\$${(state.amount! * 0.02).toStringAsFixed(2)}'
                    : '\$0.00',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                state.amount != null
                    ? '\$${(state.amount! * 1.02).toStringAsFixed(2)}'
                    : '\$0.00',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(PaymentScreenState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Details', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 16),

        // Card Number
        _buildTextField(
          controller: _cardNumberController,
          label: 'Card Number',
          hint: '1234 5678 9012 3456',
          onChanged: _formatCardNumber,
          suffixIcon: state.selectedCardBrand != null
              ? Padding(
                  padding: EdgeInsets.all(12),
                  child: _buildCardBrandIcon(state.selectedCardBrand!),
                )
              : null,
        ),
        SizedBox(height: 12),

        // Expiry and CVC
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _expiryController,
                label: 'Expiry',
                hint: 'MM/YY',
                onChanged: _formatExpiry,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _cvcController,
                label: 'CVC',
                hint: '123',
                obscureText: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Cardholder Name
        _buildTextField(
          controller: _cardholderController,
          label: 'Cardholder Name',
          hint: 'John Doe',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    VoidCallback? onChanged,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged != null ? (_) => onChanged() : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildCardBrandIcon(String brand) {
    final icons = {
      'visa': Icons.credit_card,
      'mastercard': Icons.credit_card,
      'amex': Icons.credit_card,
      'discover': Icons.credit_card,
    };

    return Icon(icons[brand] ?? Icons.credit_card, color: Colors.blue);
  }

  Widget _buildErrorBanner(String error) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(12),
        color: Colors.red[100],
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(PaymentModel payment) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              SizedBox(height: 16),
              Text(
                'Payment Successful!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'Order #${payment.orderId}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final notifier =
                      ref.read(paymentScreenStateProvider.notifier);
                  notifier.toggleReceipt();
                },
                child: Text('View Receipt'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  ref.read(paymentScreenStateProvider.notifier).reset();
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: Text('Back to Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceipt(PaymentModel payment) {
    final formatter = DateFormat('MMM dd, yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Receipt'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              ref.read(paymentScreenStateProvider.notifier).toggleReceipt();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Payment Receipt',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  _buildReceiptRow('Order ID', payment.orderId),
                  _buildReceiptRow('Payment ID', payment.id),
                  _buildReceiptRow('Date', formatter.format(payment.createdAt)),
                  _buildReceiptRow('Status', payment.statusText,
                      valueColor: Colors.green),
                  Divider(height: 24),
                  _buildReceiptRow('Amount', payment.formattedAmount,
                      valueSize: 18, valueBold: true),
                  _buildReceiptRow(
                    'Escrow Status',
                    payment.escrowStatusText,
                  ),
                  if (payment.cardInfo != null) ...[
                    Divider(height: 24),
                    _buildReceiptRow(
                      'Card',
                      payment.cardInfo!.displayCard,
                    ),
                    _buildReceiptRow(
                      'Expiry',
                      payment.cardInfo!.formattedExpiry,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    Color? valueColor,
    double valueSize = 14,
    bool valueBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
              fontSize: valueSize,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
