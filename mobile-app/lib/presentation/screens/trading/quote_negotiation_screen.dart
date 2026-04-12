import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/quote_model.dart';
import '../../services/api_service.dart';

// Single quote provider
final singleQuoteProvider =
    FutureProvider.family.autoDispose<QuoteModel, String>((ref, quoteId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getQuoteById(quoteId);
});

class QuoteNegotiationScreen extends ConsumerStatefulWidget {
  final String quoteId;

  const QuoteNegotiationScreen({
    Key? key,
    required this.quoteId,
  }) : super(key: key);

  @override
  ConsumerState<QuoteNegotiationScreen> createState() =>
      _QuoteNegotiationScreenState();
}

class _QuoteNegotiationScreenState
    extends ConsumerState<QuoteNegotiationScreen> {
  late TextEditingController _counterPriceController;
  late TextEditingController _notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _counterPriceController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _counterPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quoteAsync = ref.watch(singleQuoteProvider(widget.quoteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Negotiate Offer'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: quoteAsync.when(
        data: (quote) => _buildNegotiationView(context, quote),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildNegotiationView(BuildContext context, QuoteModel quote) {
    final originalTotal = quote.pricePerUnit * quote.quantity;
    final suggestedTotal = quote.suggestedTotalPrice;
    final savings = originalTotal - suggestedTotal;
    final savingsPercent = (savings / originalTotal * 100);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote status header
          Container(
            color: _getStatusColor(quote.status).withOpacity(0.1),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quote #${quote.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(quote.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        quote.status.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  quote.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${quote.quantity} ${quote.quantityUnit}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Price comparison
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Price Comparison',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                // Seller's listed price
                _buildPriceRow(
                  label: 'Seller\'s Listed Price',
                  pricePerUnit: quote.pricePerUnit,
                  total: originalTotal,
                  isOriginal: true,
                ),
                const SizedBox(height: 12),
                // Arrow down
                Center(
                  child: Icon(
                    Icons.trending_down,
                    color: Colors.green[600],
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                // Current offer
                _buildPriceRow(
                  label: 'Current Offer',
                  pricePerUnit: quote.suggestedPricePerUnit,
                  total: suggestedTotal,
                  isOriginal: false,
                ),
                const SizedBox(height: 16),
                // Savings badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(color: Colors.green[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Potential Savings',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${savings.toStringAsFixed(2)} (${savingsPercent.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Counter offer section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Make a Counter Offer',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Counter Price per Unit',
                  controller: _counterPriceController,
                  hint: '\$0.00',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                if (_counterPriceController.text.isNotEmpty)
                  _buildCounterOfferPreview(
                    counterPrice:
                        double.tryParse(_counterPriceController.text) ?? 0,
                    originalPrice: quote.pricePerUnit,
                    currentPrice: quote.suggestedPricePerUnit,
                    quantity: quote.quantity,
                  ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Message to Buyer (Optional)',
                  controller: _notesController,
                  hint: 'Add any notes about your counter offer...',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: quote.status == 'pending' &&
                            _counterPriceController.text.isEmpty
                        ? () => _acceptQuote(context, quote.id)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Accept Offer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                if (quote.status == 'pending')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _counterPriceController.text.isEmpty
                            ? null
                            : () => _submitCounterOffer(context, quote),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          disabledBackgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text(
                                'Send Counter Offer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _rejectQuote(context, quote.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Reject Offer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required double pricePerUnit,
    required double total,
    required bool isOriginal,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOriginal ? Colors.grey[100] : Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOriginal ? Colors.grey[300]! : Colors.green[300]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${pricePerUnit.toStringAsFixed(2)}/unit',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isOriginal ? Colors.black : Colors.green[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterOfferPreview({
    required double counterPrice,
    required double originalPrice,
    required double currentPrice,
    required double quantity,
  }) {
    final counterTotal = counterPrice * quantity;
    final savings = (originalPrice - counterPrice) * quantity;
    final savingsPercent = (savings / (originalPrice * quantity) * 100);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Counter Offer',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${counterPrice.toStringAsFixed(2)}/unit',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                savingsPercent > 0 ? 'Your Savings' : 'Your Premium',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${savingsPercent > 0 ? '-' : '+'}\$${savings.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: savingsPercent > 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: label.contains('Price')
              ? TextInputType.number
              : TextInputType.multiline,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitCounterOffer(
      BuildContext context, QuoteModel quote) async {
    setState(() => _isSubmitting = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.updateQuote(
        quote.id,
        suggestedPricePerUnit: double.parse(_counterPriceController.text),
        status: 'counter_offered',
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Counter offer sent!')),
        );
        _counterPriceController.clear();
        _notesController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _acceptQuote(BuildContext context, String quoteId) async {
    setState(() => _isSubmitting = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      final order = await apiService.acceptQuote(quoteId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer accepted! Order created.')),
        );
        context.go('/orders/${order.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _rejectQuote(BuildContext context, String quoteId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Offer?'),
        content: const Text('Are you sure you want to reject this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final apiService = ref.read(apiServiceProvider);
              try {
                await apiService.rejectQuote(quoteId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Offer rejected')),
                  );
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Yes, Reject'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'counter_offered':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
