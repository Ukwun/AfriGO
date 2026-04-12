import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/lot_model.dart';
import '../../models/quote_model.dart';
import '../../services/api_service.dart';

// Single lot provider
final lotProvider =
    FutureProvider.family.autoDispose<LotModel, String>((ref, lotId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getLotById(lotId);
});

class CreateQuoteScreen extends ConsumerStatefulWidget {
  final String lotId;

  const CreateQuoteScreen({
    Key? key,
    required this.lotId,
  }) : super(key: key);

  @override
  ConsumerState<CreateQuoteScreen> createState() => _CreateQuoteScreenState();
}

class _CreateQuoteScreenState extends ConsumerState<CreateQuoteScreen> {
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController();
    _quantityController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lotAsync = ref.watch(lotProvider(widget.lotId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Make an Offer'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: lotAsync.when(
        data: (lot) => _buildQuoteForm(context, lot),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildQuoteForm(BuildContext context, LotModel lot) {
    final suggestedPrice = _priceController.text.isNotEmpty
        ? double.tryParse(_priceController.text) ?? 0
        : lot.pricePerUnit;
    final quantity = _quantityController.text.isNotEmpty
        ? double.tryParse(_quantityController.text) ?? 0
        : 0;
    final totalPrice = suggestedPrice * quantity;
    final discount = (lot.pricePerUnit - suggestedPrice).abs();
    final discountPercent = (discount / lot.pricePerUnit * 100);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product info card
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product Available',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  lot.productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${lot.quantity} ${lot.quantityUnit}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Listed Price',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${lot.pricePerUnit.toStringAsFixed(2)}/${lot.quantityUnit}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Form
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quantity input
                _buildInputField(
                  label: 'Quantity (${lot.quantityUnit})',
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  hint: '0',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                // Suggested price input
                _buildInputField(
                  label: 'Offer Price per Unit',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  hint: '\$0.00',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Price comparison
                if (_priceController.text.isNotEmpty &&
                    _quantityController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: discountPercent > 0
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: discountPercent > 0
                            ? Colors.green[300]!
                            : Colors.red[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Compared to Listing Price',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              discountPercent > 0
                                  ? '-${discountPercent.toStringAsFixed(1)}% (${discountPercent > 0 ? 'Lower' : 'Higher'})'
                                  : '+${discountPercent.abs().toStringAsFixed(1)}% (Higher)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: discountPercent > 0
                                    ? Colors.green[700]
                                    : Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                // Notes
                _buildInputField(
                  label: 'Offer Notes (Optional)',
                  controller: _notesController,
                  keyboardType: TextInputType.multiline,
                  hint: 'Add special requests, delivery preferences, etc.',
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Summary
          if (_quantityController.text.isNotEmpty &&
              _priceController.text.isNotEmpty)
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Offer Summary',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${quantity.toStringAsFixed(2)} ${lot.quantityUnit} @ \$${suggestedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (lot.pricePerUnit > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Seller\'s List Price',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '\$${(lot.pricePerUnit * quantity).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    onPressed: _isSubmitting ||
                            _priceController.text.isEmpty ||
                            _quantityController.text.isEmpty
                        ? null
                        : () => _submitQuote(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Text(
                            'Send Offer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
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
          keyboardType: keyboardType,
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

  Future<void> _submitQuote(BuildContext context) async {
    setState(() => _isSubmitting = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      final quote = await apiService.createQuote(
        lotId: widget.lotId,
        suggestedPricePerUnit: double.parse(_priceController.text),
        quantity: double.parse(_quantityController.text),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer sent successfully!')),
        );
        context.go('/trading/quotes/${quote.id}');
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
}
