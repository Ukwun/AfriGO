import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../models/rfq_model.dart';
import '../providers/rfq_provider.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/animated_button.dart';

class RFQDetailScreen extends ConsumerStatefulWidget {
  final String rfqId;

  const RFQDetailScreen({
    super.key,
    required this.rfqId,
  });

  @override
  ConsumerState<RFQDetailScreen> createState() => _RFQDetailScreenState();
}

class _RFQDetailScreenState extends ConsumerState<RFQDetailScreen> {
  late TextEditingController pricePerUnitController;
  late TextEditingController estimatedDeliveryController;
  late TextEditingController paymentMethodController;
  late TextEditingController specialTermsController;
  late TextEditingController originCountryController;
  late TextEditingController gradeLevelController;

  bool _isSubmittingBid = false;

  @override
  void initState() {
    super.initState();
    pricePerUnitController = TextEditingController();
    estimatedDeliveryController = TextEditingController();
    paymentMethodController = TextEditingController();
    specialTermsController = TextEditingController();
    originCountryController = TextEditingController();
    gradeLevelController = TextEditingController();
  }

  @override
  void dispose() {
    pricePerUnitController.dispose();
    estimatedDeliveryController.dispose();
    paymentMethodController.dispose();
    specialTermsController.dispose();
    originCountryController.dispose();
    gradeLevelController.dispose();
    super.dispose();
  }

  void _submitBid(RFQModel rfq) async {
    if (pricePerUnitController.text.isEmpty ||
        estimatedDeliveryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSubmittingBid = true);

    try {
      final request = SubmitBidRequest(
        rfqId: widget.rfqId,
        pricePerUnit: double.parse(pricePerUnitController.text),
        originCountry: originCountryController.text.isEmpty
            ? rfq.originCountryPreference ?? 'Unknown'
            : originCountryController.text,
        gradeLevel: gradeLevelController.text.isEmpty
            ? rfq.gradePreference ?? 'B'
            : gradeLevelController.text,
        estimatedDelivery: DateTime.parse(estimatedDeliveryController.text),
        paymentMethod: paymentMethodController.text.isEmpty
            ? 'Bank Transfer'
            : paymentMethodController.text,
        specialTerms: specialTermsController.text.isEmpty
            ? null
            : specialTermsController.text,
        certificationsIncluded: null,
      );

      final service = ref.read(rfqServiceProvider);
      final bid = await service.submitBid(request);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Bid submitted! Total: ₵${bid.totalPrice.toStringAsFixed(2)}')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmittingBid = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rfqAsync = ref.watch(rfqDetailProvider(widget.rfqId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('RFQ Details'),
      ),
      body: rfqAsync.when(
        data: (rfq) {
          final totalPrice = (pricePerUnitController.text.isEmpty
                  ? 0
                  : double.tryParse(pricePerUnitController.text) ?? 0) *
              rfq.quantity;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Info Card
                Container(
                  color: Colors.blue.shade50,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rfq.productCategory,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rfq.productDescription,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _daysRemaining(rfq.expiresAt),
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _InfoBox(
                            label: 'Quantity',
                            value:
                                '${rfq.quantity.toStringAsFixed(0)} ${rfq.quantityUnit}',
                          ),
                          _InfoBox(
                            label: 'Origin',
                            value: rfq.originCountryPreference ?? 'Any',
                          ),
                          _InfoBox(
                            label: 'Grade',
                            value: rfq.gradePreference ?? 'Any',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Terms Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RFQ Terms',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _TermRow(
                        label: 'Delivery Deadline',
                        value: DateFormat('MMM d, yyyy')
                            .format(rfq.deliveryDeadline),
                      ),
                      _TermRow(
                        label: 'Payment Terms',
                        value: rfq.paymentTerms,
                      ),
                      _TermRow(
                        label: 'Posted By',
                        value: rfq.buyerCompanyName,
                      ),
                      _TermRow(
                        label: 'Posted Date',
                        value: DateFormat('MMM d, yyyy').format(rfq.createdAt),
                      ),
                      _TermRow(
                        label: 'Total Bids',
                        value:
                            '${rfq.submittedBids.length} of ${rfq.maxBidsExpected} expected',
                      ),
                    ],
                  ),
                ),

                // Description Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rfq.description,
                        style: const TextStyle(color: Colors.grey, height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // BID SUBMISSION FORM
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Submit Your Bid',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Price Per Unit
                      TextField(
                        controller: pricePerUnitController,
                        decoration: const InputDecoration(
                          label: Text('Price Per Unit (₵)'),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 12),

                      // Total Price Display
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Bid Price:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₵${totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Origin Country
                      TextField(
                        controller: originCountryController,
                        decoration: InputDecoration(
                          label: const Text('Origin Country'),
                          hintText:
                              rfq.originCountryPreference ?? 'e.g., Ghana',
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Grade Level
                      TextField(
                        controller: gradeLevelController,
                        decoration: InputDecoration(
                          label: const Text('Grade Level'),
                          hintText: rfq.gradePreference ?? 'A, B, C',
                          prefixIcon: const Icon(Icons.grade),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Estimated Delivery
                      TextField(
                        controller: estimatedDeliveryController,
                        decoration: const InputDecoration(
                          label: Text('Estimated Delivery Date *'),
                          hintText: 'YYYY-MM-DD',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: rfq.deliveryDeadline,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 180)),
                          );
                          if (date != null) {
                            estimatedDeliveryController.text =
                                DateFormat('yyyy-MM-dd').format(date);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Payment Method
                      TextField(
                        controller: paymentMethodController,
                        decoration: const InputDecoration(
                          label: Text('Payment Method'),
                          hintText: 'Bank Transfer, Escrow, etc.',
                          prefixIcon: Icon(Icons.payment),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Special Terms
                      TextField(
                        controller: specialTermsController,
                        decoration: const InputDecoration(
                          label: Text('Special Terms (Optional)'),
                          hintText: 'Any additional terms or conditions',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // Submit Button with real-time responsiveness
                      AnimatedPrimaryButton(
                        label: 'Submit Bid',
                        onPressed:
                            _isSubmittingBid ? null : () => _submitBid(rfq),
                        isLoading: _isSubmittingBid,
                        isLargeTouchTarget: true,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              AnimatedPrimaryButton(
                label: 'Retry',
                onPressed: () => ref.refresh(rfqDetailProvider(widget.rfqId)),
                isLargeTouchTarget: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _daysRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);
    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else {
      return 'Expires today';
    }
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TermRow extends StatelessWidget {
  final String label;
  final String value;

  const _TermRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
