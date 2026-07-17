import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../models/payment_model.dart';
import '../../../models/order_model.dart';
import '../../providers/orders_provider.dart';
import '../../../data/services/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

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
    super.key,
  });

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
    final notifier = ref.read(paymentScreenStateProvider.notifier);
    notifier.setProcessing(true);

    try {
      final response = await ApiClient().post(
        '/payments',
        body: {'orderId': widget.orderId},
        headers: {
          'Idempotency-Key':
              'order-${widget.orderId}-${DateTime.now().microsecondsSinceEpoch}'
        },
      );
      final checkout = response['flutterwavePaymentUrl']?.toString();
      if (checkout == null || checkout.isEmpty) {
        throw Exception('The payment provider did not return a checkout URL');
      }
      final opened = await launchUrl(Uri.parse(checkout),
          mode: LaunchMode.externalApplication);
      if (!opened) throw Exception('Could not open Flutterwave checkout');
      notifier.setProcessing(false);
      _showSuccess(
          'Checkout opened. Payment status updates only after Flutterwave verification.');
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentScreenStateProvider);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment')),
        body: const Center(child: CircularProgressIndicator()),
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
        title: const Text('Payment'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary
                _buildOrderSummary(state),
                const SizedBox(height: 24),

                // Payment Form
                _buildPaymentForm(state),
                const SizedBox(height: 24),

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
                        ? const SizedBox(
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
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Security Badge
                const Center(
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
      padding: const EdgeInsets.all(12),
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
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Platform Fee (2%)',
                  style: TextStyle(color: Colors.grey[600])),
              Text(
                state.amount != null
                    ? '\$${(state.amount! * 0.02).toStringAsFixed(2)}'
                    : '\$0.00',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                state.amount != null
                    ? '\$${(state.amount! * 1.02).toStringAsFixed(2)}'
                    : '\$0.00',
                style: const TextStyle(
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Icon(Icons.verified_user_outlined, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Secure Flutterwave checkout',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                const Text(
                  'Card, bank transfer, USSD, and supported mobile-money details are entered only on Flutterwave. Afrigo never stores your card number or CVC.',
                ),
              ],
            ),
          ),
        ]),
      ),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        padding: const EdgeInsets.all(12),
        color: Colors.red[100],
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(color: Colors.red),
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
              const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Successful!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Order #${payment.orderId}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final notifier =
                      ref.read(paymentScreenStateProvider.notifier);
                  notifier.toggleReceipt();
                },
                child: const Text('View Receipt'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  ref.read(paymentScreenStateProvider.notifier).reset();
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                ),
                child: const Text('Back to Order'),
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
        title: const Text('Payment Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(paymentScreenStateProvider.notifier).toggleReceipt();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
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
                  const SizedBox(height: 16),
                  _buildReceiptRow('Order ID', payment.orderId ?? '—'),
                  _buildReceiptRow('Payment ID', payment.id),
                  _buildReceiptRow('Date', formatter.format(payment.createdAt)),
                  _buildReceiptRow('Status', payment.statusText,
                      valueColor: Colors.green),
                  const Divider(height: 24),
                  _buildReceiptRow('Amount', payment.formattedAmount,
                      valueSize: 18, valueBold: true),
                  _buildReceiptRow(
                    'Escrow Status',
                    payment.escrowStatusText,
                  ),
                  if (payment.cardInfo != null) ...[
                    const Divider(height: 24),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
