import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import '../../../models/payment_model.dart';
import '../../../models/contract_model.dart';
import '../../providers/payment_provider.dart';

/// Checkout Screen - Payment method selection and Flutterwave processing
class CheckoutScreen extends ConsumerStatefulWidget {
  final String contractId;
  final double amount;
  final String currency;

  const CheckoutScreen({
    Key? key,
    required this.contractId,
    required this.amount,
    required this.currency,
  }) : super(key: key);

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  late WebViewController _webViewController;
  String? _selectedPaymentMethod;
  bool _isProcessing = false;
  String? _error;
  String? _paymentId;
  bool _showWebView = false;
  int _selectedInstallments = 3;

  final List<PaymentMethodOption> paymentMethods = [
    PaymentMethodOption(
      id: 'FULL_UPFRONT',
      title: 'Full Payment Upfront',
      description: 'Pay the complete amount now',
      icon: '💰',
      fees: 0.0,
    ),
    PaymentMethodOption(
      id: 'PARTIAL_DEPOSIT',
      title: 'Deposit Required (30%)',
      description: 'Pay 30% deposit, balance on delivery',
      icon: '📋',
      fees: 0.0,
      depositPercentage: 30.0,
    ),
    PaymentMethodOption(
      id: 'ON_DELIVERY',
      title: 'Pay on Delivery',
      description: 'Inspect goods before payment',
      icon: '🚚',
      fees: 2.0,
    ),
    PaymentMethodOption(
      id: 'INSTALLMENT',
      title: 'Installment Plan',
      description: 'Spread payment over 3-12 months',
      icon: '📅',
      fees: 1.5,
      hasOptions: true,
    ),
    PaymentMethodOption(
      id: 'ESCROW',
      title: 'Escrow Fund Hold',
      description: 'Funds held until conditions met',
      icon: '🔒',
      fees: 0.5,
      requiresConditions: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Page loaded
            print('WebView loaded: $url');
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _error = 'WebView error: ${error.description}';
            });
          },
        ),
      );
  }

  Future<void> _proceedWithPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      // Create payment request
      final request = CreatePaymentRequest(
        contractId: widget.contractId,
        paymentMethod: _selectedPaymentMethod!,
        amount: _selectedPaymentMethod == 'PARTIAL_DEPOSIT'
            ? widget.amount * 0.30
            : widget.amount,
        currency: widget.currency,
        dueDate: DateTime.now().add(const Duration(days: 7)),
        metadata: {
          if (_selectedPaymentMethod == 'INSTALLMENT')
            'installments': _selectedInstallments,
          'originalAmount': widget.amount,
        },
      );

      // Create payment
      final paymentAsync = await ref.read(
        createPaymentProvider(request).future,
      );

      setState(() {
        _paymentId = paymentAsync.id;
      });

      // If payment requires Flutterwave redirect
      if (_selectedPaymentMethod != 'ON_DELIVERY' &&
          _selectedPaymentMethod != 'PARTIAL_DEPOSIT') {
        _initiateFlutterwavePayment();
      } else {
        // Show success for deferred payment methods
        _showPaymentSuccess(paymentAsync);
      }
    } catch (e) {
      setState(() {
        _error = 'Payment creation failed: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _initiateFlutterwavePayment() async {
    if (_paymentId == null) return;

    try {
      // Get Flutterwave payment URL
      final paymentUrl = await ref.read(
        initiatePaymentProvider(_paymentId!).future,
      );

      setState(() {
        _showWebView = true;
      });

      // Load URL in WebView
      await _webViewController.loadRequest(Uri.parse(paymentUrl));
    } catch (e) {
      setState(() {
        _error = 'Failed to initiate payment: $e';
        _isProcessing = false;
      });
    }
  }

  void _showPaymentSuccess(PaymentModel payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Initiated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('✅ Payment created successfully'),
            const SizedBox(height: 16),
            Text('Invoice: ${payment.invoiceReference}'),
            Text('Amount: ${payment.formattedAmount}'),
            Text('Status: ${payment.statusText}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.pop(); // Back to contract
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showWebView) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Complete Payment'),
          actions: [
            if (_isProcessing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
        body: _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: $_error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _showWebView = false;
                        _error = null;
                      }),
                      child: const Text('Back to Methods'),
                    ),
                  ],
                ),
              )
            : WebViewWidget(controller: _webViewController),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Payment Method'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Summary Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_getCurrencySymbol(widget.currency)}${widget.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Contract: ${widget.contractId.substring(0, 8)}...',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),

              // Payment Methods
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethod == method.id;
                return _buildPaymentMethodCard(method, isSelected);
              }).toList(),

              const SizedBox(height: 24),

              // Installment Options (if INSTALLMENT selected)
              if (_selectedPaymentMethod == 'INSTALLMENT')
                _buildInstallmentOptions(),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _proceedWithPayment,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.payment),
                      label: Text(_isProcessing ? 'Processing...' : 'Pay Now'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Security Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Secured by Flutterwave (PCI DSS Compliant)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodOption method, bool isSelected) {
    final paymentAmount = method.depositPercentage != null
        ? widget.amount * (method.depositPercentage! / 100)
        : widget.amount;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: Colors.blue.shade500, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          ),
          child: Center(
            child: Text(method.icon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(
          method.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(method.description, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '${_getCurrencySymbol(widget.currency)}${paymentAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                if (method.fees > 0)
                  Text(
                    '(+${method.fees}% fee)',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Radio<String>(
          value: method.id,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) {
            setState(() {
              _selectedPaymentMethod = value;
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = method.id;
          });
        },
      ),
    );
  }

  Widget _buildInstallmentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 12),
        Text(
          'Select Installment Plan',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...([3, 6, 9, 12]).map((months) {
          final monthlyAmount = widget.amount / months;
          return RadioListTile<int>(
            title: Text('$months months'),
            subtitle: Text(
              '${_getCurrencySymbol(widget.currency)}${monthlyAmount.toStringAsFixed(2)} x $months',
            ),
            value: months,
            groupValue: _selectedInstallments,
            onChanged: (value) {
              setState(() {
                _selectedInstallments = value ?? 3;
              });
            },
          );
        }).toList(),
      ],
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'KES':
        return 'Ksh ';
      case 'USD':
        return '\$ ';
      case 'EUR':
        return '€ ';
      case 'ZAR':
        return 'R ';
      case 'UGX':
        return 'UGX ';
      case 'TZS':
        return 'Tsh ';
      default:
        return '$currency ';
    }
  }
}

/// Payment method option model
class PaymentMethodOption {
  final String id;
  final String title;
  final String description;
  final String icon;
  final double fees;
  final double? depositPercentage;
  final bool hasOptions;
  final bool requiresConditions;

  PaymentMethodOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.fees,
    this.depositPercentage,
    this.hasOptions = false,
    this.requiresConditions = false,
  });
}
