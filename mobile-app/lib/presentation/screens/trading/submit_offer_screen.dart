import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubmitOfferScreen extends StatefulWidget {
  const SubmitOfferScreen({super.key, required this.rfqId});
  final String rfqId;

  @override
  State<SubmitOfferScreen> createState() => _SubmitOfferScreenState();
}

class _SubmitOfferScreenState extends State<SubmitOfferScreen> {
  final _key = GlobalKey<FormState>();
  final _price = TextEditingController();
  final _quantity = TextEditingController();
  final _leadTime = TextEditingController();
  final _terms = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [_price, _quantity, _leadTime, _terms]) {
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
      final rfqReference =
          FirebaseFirestore.instance.collection('rfqs').doc(widget.rfqId);
      final rfq = await rfqReference.get();
      final buyerId = rfq.data()?['ownerId']?.toString();
      if (!rfq.exists ||
          rfq.data()?['status'] != 'open' ||
          buyerId == null ||
          buyerId.isEmpty) {
        throw StateError('RFQ is no longer open');
      }
      final offer = FirebaseFirestore.instance.collection('offers').doc();
      await offer.set({
        'id': offer.id,
        'rfqId': widget.rfqId,
        'ownerId': user.uid,
        'supplierId': user.uid,
        'buyerId': buyerId,
        'participantIds': [user.uid, buyerId],
        'unitPrice': double.parse(_price.text.trim()),
        'quantity': double.parse(_quantity.text.trim()),
        'leadTimeDays': int.parse(_leadTime.text.trim()),
        'terms': _terms.text.trim(),
        'currency': 'USD',
        'status': 'submitted',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      context.go('/dashboard/seller');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Offer was not submitted. Confirm the RFQ is open and retry.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Submit commercial offer')),
        body: Form(
          key: _key,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Your offer becomes visible only to you and the buyer who owns this RFQ.',
              ),
              const SizedBox(height: 20),
              _field(_price, 'Unit price (USD)', numeric: true),
              _field(_quantity, 'Quantity available', numeric: true),
              _field(_leadTime, 'Lead time in days', numeric: true),
              _field(_terms, 'Commercial and delivery terms', lines: 4),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: Text(_saving ? 'Submitting…' : 'Submit offer'),
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
              ),
            ],
          ),
        ),
      );

  Widget _field(TextEditingController controller, String label,
      {bool numeric = false, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration:
            InputDecoration(labelText: label, border: const OutlineInputBorder()),
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
