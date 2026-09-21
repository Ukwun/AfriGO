import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RequestLogisticsScreen extends StatefulWidget {
  const RequestLogisticsScreen({super.key, required this.orderId});
  final String orderId;
  @override State<RequestLogisticsScreen> createState() => _RequestLogisticsScreenState();
}
class _RequestLogisticsScreenState extends State<RequestLogisticsScreen> {
  final _form = GlobalKey<FormState>(); final _pickup = TextEditingController(); final _delivery = TextEditingController(); final _note = TextEditingController(); bool _saving = false;
  @override void dispose() { _pickup.dispose(); _delivery.dispose(); _note.dispose(); super.dispose(); }
  Future<void> _send(Map<String, dynamic> order) async {
    if (!_form.currentState!.validate()) return; final user = FirebaseAuth.instance.currentUser; if (user == null) return; setState(() => _saving = true);
    try { await FirebaseFirestore.instance.collection('service_requests').add({'ownerId': user.uid, 'participantIds': List<String>.from(order['participantIds'] as List? ?? [user.uid]), 'orderId': widget.orderId, 'type': 'logistics', 'status': 'requested', 'pickupLocation': _pickup.text.trim(), 'deliveryLocation': _delivery.text.trim(), 'cargo': order['productName'] ?? order['commodity'] ?? 'Not specified', 'note': _note.text.trim(), 'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()}); if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logistics request submitted for provider review.'))); context.pop(); }} on FirebaseException { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request was not sent. Check your connection and retry.'))); } finally { if (mounted) setState(() => _saving = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Request logistics')), body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots(), builder: (context, snapshot) { final order = snapshot.data?.data(); if (order == null) return const Center(child: CircularProgressIndicator()); return Form(key: _form, child: ListView(padding: const EdgeInsets.all(20), children: [Text('Request logistics', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 8), const Text('Send real shipment details to approved logistics providers. Availability and charges are confirmed by the provider.'), const SizedBox(height: 24), _input('Collection location', _pickup), _input('Delivery location', _delivery), TextFormField(initialValue: (order['productName'] ?? order['commodity'] ?? 'Not specified').toString(), enabled: false, decoration: const InputDecoration(labelText: 'Cargo', border: OutlineInputBorder())), const SizedBox(height: 16), _input('Optional note', _note, false), const SizedBox(height: 16), FilledButton.icon(onPressed: _saving ? null : () => _send(order), icon: const Icon(Icons.local_shipping_outlined), label: Text(_saving ? 'Sending…' : 'Request provider quotes'))])); }));
  Widget _input(String label, TextEditingController controller, [bool required = true]) => Padding(padding: const EdgeInsets.only(bottom: 16), child: TextFormField(controller: controller, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()), validator: required ? (value) => value == null || value.trim().isEmpty ? '$label is required' : null : null));
}
