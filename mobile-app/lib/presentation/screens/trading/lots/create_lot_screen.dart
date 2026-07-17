import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateLotScreen extends StatefulWidget {
  const CreateLotScreen({super.key, this.tradeId});
  final String? tradeId;

  @override
  State<CreateLotScreen> createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends State<CreateLotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _quantity = TextEditingController();
  final _price = TextEditingController();
  final _origin = TextEditingController();
  final _description = TextEditingController();
  String _category = 'Cocoa';
  String _grade = 'Grade A';
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [_name, _quantity, _price, _origin, _description]) {
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
      final reference = FirebaseFirestore.instance.collection('lots').doc();
      await reference.set({
        'id': reference.id,
        'ownerId': user.uid,
        'supplierId': user.uid,
        'participantIds': [user.uid],
        'productName': _name.text.trim(),
        'productType': _category,
        'category': _category,
        'quantity': double.parse(_quantity.text.trim()),
        'quantityUnit': 'kg',
        'unit': 'kg',
        'pricePerUnit': double.parse(_price.text.trim()),
        'currency': 'USD',
        'grade': _grade,
        'gradeLevel': _grade,
        'origin': _origin.text.trim(),
        'originLocation': _origin.text.trim(),
        'description': _description.text.trim(),
        'photoUrls': const <String>[],
        'status': 'draft',
        'verificationStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      context.push('/trading/lot-photo-upload/${reference.id}');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lot was not created. Check connectivity and retry.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create inventory lot')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Publish traceable inventory using real quantities, origin and pricing.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _field(_name, 'Product name', Icons.inventory_2_outlined),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Commodity category',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: const ['Cocoa', 'Coffee', 'Cashews', 'Shea Butter', 'Palm Oil']
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: _field(_quantity, 'Quantity (kg)', Icons.scale,
                    numeric: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(_price, 'USD per kg', Icons.payments_outlined,
                    numeric: true),
              ),
            ]),
            DropdownButtonFormField<String>(
              initialValue: _grade,
              decoration: const InputDecoration(
                labelText: 'Declared grade',
                prefixIcon: Icon(Icons.verified_outlined),
                border: OutlineInputBorder(),
              ),
              items: const ['Grade A', 'Grade B', 'Grade C', 'Standard']
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => _grade = value!),
            ),
            const SizedBox(height: 14),
            _field(_origin, 'Origin location', Icons.location_on_outlined),
            _field(_description, 'Description and specifications', Icons.notes,
                lines: 3),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward),
              label: Text(_saving ? 'Creating…' : 'Create and add photos'),
              style:
                  FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
      {bool numeric = false, int lines = 1}) {
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
          if (value == null || value.trim().isEmpty) return 'Required';
          if (numeric && (double.tryParse(value) ?? 0) <= 0) {
            return 'Enter a value above zero';
          }
          return null;
        },
      ),
    );
  }
}
