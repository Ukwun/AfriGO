import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateRFQScreen extends StatefulWidget {
  const CreateRFQScreen({super.key});

  @override
  State<CreateRFQScreen> createState() => _CreateRFQScreenState();
}

class _CreateRFQScreenState extends State<CreateRFQScreen> {
  final _formKey = GlobalKey<FormState>();
  final _product = TextEditingController();
  final _description = TextEditingController();
  final _quantity = TextEditingController();
  final _unit = TextEditingController(text: 'kg');
  final _destination = TextEditingController();
  final _budget = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [
      _product,
      _description,
      _quantity,
      _unit,
      _destination,
      _budget,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      final reference = FirebaseFirestore.instance.collection('rfqs').doc();
      await reference.set({
        'id': reference.id,
        'ownerId': user.uid,
        'buyerId': user.uid,
        'participantIds': [user.uid],
        'productCategory': _product.text.trim(),
        'commodity': _product.text.trim(),
        'productDescription': _description.text.trim(),
        'quantity': double.parse(_quantity.text.trim()),
        'quantityUnit': _unit.text.trim(),
        'destination': _destination.text.trim(),
        'targetBudget': _budget.text.trim().isEmpty
            ? null
            : double.parse(_budget.text.trim()),
        'status': 'open',
        'submittedBids': const [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      context.go('/rfqs');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('RFQ was not created. Check connectivity and retry.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create RFQ')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Describe a real purchasing requirement. Suppliers will only see it after Firebase confirms creation.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _field(_product, 'Commodity or product', Icons.inventory_2_outlined),
            _field(_description, 'Quality and specification', Icons.notes,
                lines: 3),
            Row(children: [
              Expanded(child: _field(_quantity, 'Quantity', Icons.scale,
                  numeric: true)),
              const SizedBox(width: 12),
              Expanded(child: _field(_unit, 'Unit', Icons.straighten)),
            ]),
            _field(_destination, 'Delivery destination',
                Icons.location_on_outlined),
            _field(_budget, 'Target budget (optional)',
                Icons.account_balance_wallet_outlined,
                numeric: true, optional: true),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.publish_outlined),
              label: Text(_saving ? 'Publishing…' : 'Publish RFQ'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
      {int lines = 1, bool numeric = false, bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (!optional && (value == null || value.trim().isEmpty)) {
            return 'Required';
          }
          if (numeric && value?.trim().isNotEmpty == true &&
              double.tryParse(value!.trim()) == null) {
            return 'Enter a valid number';
          }
          return null;
        },
      ),
    );
  }
}
