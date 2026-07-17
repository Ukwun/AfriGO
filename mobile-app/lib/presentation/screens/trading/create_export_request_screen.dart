import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateExportRequestScreen extends StatefulWidget {
  const CreateExportRequestScreen({super.key});

  @override
  State<CreateExportRequestScreen> createState() =>
      _CreateExportRequestScreenState();
}

class _CreateExportRequestScreenState extends State<CreateExportRequestScreen> {
  final _key = GlobalKey<FormState>();
  final _product = TextEditingController();
  final _quantity = TextEditingController();
  final _buyer = TextEditingController();
  final _destination = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [_product, _quantity, _buyer, _destination]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      final reference =
          FirebaseFirestore.instance.collection('export_orders').doc();
      await reference.set({
        'id': reference.id,
        'ownerId': user.uid,
        'exporterId': user.uid,
        'participantIds': [user.uid],
        'productName': _product.text.trim(),
        'quantity': double.parse(_quantity.text.trim()),
        'quantityUnit': 'kg',
        'buyerCompany': _buyer.text.trim(),
        'destination': _destination.text.trim(),
        'status': 'draft',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Export order was not created. Verified exporter KYC and connectivity are required.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create export order')),
        body: Form(
          key: _key,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Create an operational export record. Payment and shipment execution begin only after verified contracts and KYC.',
              ),
              const SizedBox(height: 20),
              _field(_product, 'Contracted product'),
              _field(_quantity, 'Quantity in kg', numeric: true),
              _field(_buyer, 'Buyer company'),
              _field(_destination, 'Destination'),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.public),
                label: Text(_saving ? 'Creating…' : 'Create draft order'),
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
              ),
            ],
          ),
        ),
      );

  Widget _field(TextEditingController controller, String label,
      {bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
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
