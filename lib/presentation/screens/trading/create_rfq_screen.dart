import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../data/services/trade_service.dart';

/// Create RFQ Screen
/// Allows buyers to create request for quote
class CreateRFQScreen extends ConsumerStatefulWidget {
  const CreateRFQScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateRFQScreen> createState() => _CreateRFQScreenState();
}

class _CreateRFQScreenState extends ConsumerState<CreateRFQScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _deliveryLocationController = TextEditingController();
  final _deliveryDateController = TextEditingController();
  final _requirementsController = TextEditingController();

  bool _isSubmitting = false;
  double _fraudScore = 0;
  bool _showFraudWarning = false;

  @override
  void dispose() {
    _productTypeController.dispose();
    _quantityController.dispose();
    _maxPriceController.dispose();
    _deliveryLocationController.dispose();
    _deliveryDateController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create RFQ'),
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
                'What do you need?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a request and sellers will submit their best quotes',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Product type
              const Text(
                'Product Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Select product type',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: Constants.productTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  _productTypeController.text = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select product type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Quantity
              const Text(
                'Quantity (kg)',
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
                  hintText: 'Enter quantity needed',
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

              // Max price
              const Text(
                'Maximum Price per kg (\$)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Enter maximum price you\'ll pay',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter maximum price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Delivery location
              const Text(
                'Delivery Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Select delivery country',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: Constants.africanCountries.map((country) {
                  return DropdownMenuItem(value: country, child: Text(country));
                }).toList(),
                onChanged: (value) {
                  _deliveryLocationController.text = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select delivery location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Delivery date
              const Text(
                'Required Delivery Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _deliveryDateController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Select delivery date',
                  suffixIcon: const Icon(Icons.calendar_today),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) {
                    _deliveryDateController.text = date.toString().split(
                      ' ',
                    )[0];
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select delivery date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Special requirements
              const Text(
                'Special Requirements (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _requirementsController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText:
                      'e.g., Organic certification, specific packaging, etc.',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Fraud risk indicator (if high)
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
                                  ? 'RFQ Blocked'
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
                                  ? 'Unusual activity detected. Additional verification required.'
                                  : 'This RFQ may be flagged for review. Continue?',
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
                  onPressed: _isSubmitting ? null : _submitForm,
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
                      : const Text('Create RFQ'),
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

  /// Submit form - REAL backend call
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final tradeService = ref.read(tradeServiceProvider);

      final quantity = double.parse(_quantityController.text);
      final maxPrice = double.parse(_maxPriceController.text);

      // REAL fraud detection before RFQ creation
      final fraudScore = await tradeService.detectFraud(
        amount: quantity * maxPrice,
        action: 'CREATE_RFQ',
      );

      setState(() => _fraudScore = fraudScore);

      // Check fraud score
      if (fraudScore > 80) {
        setState(() => _showFraudWarning = true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'RFQ creation blocked due to fraud detection. Please contact support.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // FUNCTIONAL [CREATE RFQ] button - REAL backend call
      // This triggers:
      // 1. RFQ created in database (immutable)
      // 2. Fraud detection score logged
      // 3. Activity log entry created
      // 4. WebSocket broadcast (RFQ_CREATED event)
      // 5. All matching sellers notified in real-time (<500ms)
      // 6. Sellers see RFQ in their app instantly
      final trade = await tradeService.createRFQ(
        productType: _productTypeController.text,
        quantity: quantity,
        maxPrice: maxPrice,
        deliveryLocation: _deliveryLocationController.text,
        deliveryDate: DateTime.parse(_deliveryDateController.text),
        specialRequirements: _requirementsController.text,
        fraudScore: fraudScore,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('RFQ created! Sellers will start submitting quotes.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to RFQ detail
        context.go('/trade-detail/${trade.id}');
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
