import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../data/services/trade_service.dart';

/// Submit Bid Screen
/// Allows sellers to submit quote/bid on an RFQ
/// FUNCTIONAL button with real backend call + fraud detection
class SubmitBidScreen extends ConsumerStatefulWidget {
  final String rfqId;

  const SubmitBidScreen({Key? key, required this.rfqId}) : super(key: key);

  @override
  ConsumerState<SubmitBidScreen> createState() => _SubmitBidScreenState();
}

class _SubmitBidScreenState extends ConsumerState<SubmitBidScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _qualityGradeController = TextEditingController();
  final _deliveryDaysController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;
  double _fraudScore = 0;
  bool _showFraudWarning = false;

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _qualityGradeController.dispose();
    _deliveryDaysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Quote'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Quote Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Submit competitive pricing to win this order',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Price per unit
              const Text(
                'Price per kg (\$)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Enter your price',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Quantity available
              const Text(
                'Quantity Available (kg)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'How much can you supply?',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Quality grade
              const Text(
                'Quality Grade',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Select quality grade',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: ['Grade A', 'Grade B', 'Grade C', 'Premium', 'Standard']
                    .map((grade) {
                      return DropdownMenuItem(value: grade, child: Text(grade));
                    })
                    .toList(),
                onChanged: (value) {
                  _qualityGradeController.text = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select quality grade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Delivery days
              const Text(
                'Delivery Time (days)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deliveryDaysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Days to delivery',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter delivery days';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Additional notes
              const Text(
                'Additional Notes (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText:
                      'e.g., "Certified organic", "Bulk discount available"',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fraud warning (if applicable)
              if (_showFraudWarning)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _fraudScore > 80
                        ? Colors.red[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _fraudScore > 80
                          ? Colors.red[300]!
                          : Colors.orange[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _fraudScore > 80 ? Icons.block : Icons.warning,
                        color: _fraudScore > 80 ? Colors.red : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fraudScore > 80
                                  ? 'Quote Blocked'
                                  : 'Fraud Risk Alert',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _fraudScore > 80
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _fraudScore > 80
                                  ? 'Unusual activity detected. Quote cannot be submitted.'
                                  : 'This quote may be flagged for review. Continue?',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitBid,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Submit Quote'),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Submit bid - REAL backend call
  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final tradeService = ref.read(tradeServiceProvider);

      final price = double.parse(_priceController.text);
      final quantity = double.parse(_quantityController.text);

      // REAL fraud detection before bid submission
      final fraudScore = await tradeService.detectFraud(
        amount: quantity * price,
        action: 'SUBMIT_BID',
      );

      setState(() => _fraudScore = fraudScore);

      // Check fraud score
      if (fraudScore > 80) {
        setState(() => _showFraudWarning = true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Quote submission blocked due to fraud detection. Please contact support.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // FUNCTIONAL [SUBMIT QUOTE] button - REAL backend call
      // This triggers:
      // 1. Bid created in database (immutable)
      // 2. Fraud detection score logged
      // 3. Activity log entry created
      // 4. WebSocket broadcast (BID_RECEIVED event)
      // 5. Buyer notified in real-time (<500ms)
      // 6. Quote appears in buyer's app instantly
      await tradeService.createBid(
        rfqId: widget.rfqId,
        offeredPrice: price,
        quantity: quantity,
        qualityGrade: _qualityGradeController.text,
        estimatedDeliveryDays: int.parse(_deliveryDaysController.text),
        specialNotes: _notesController.text,
        fraudScore: fraudScore,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote submitted! Buyer will review your offer.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
