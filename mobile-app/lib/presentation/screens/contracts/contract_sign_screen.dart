import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/contract_model.dart';
import '../../providers/contract_provider.dart';

class ContractSignScreen extends ConsumerStatefulWidget {
  final String contractId;

  const ContractSignScreen({
    super.key,
    required this.contractId,
  });

  @override
  ConsumerState<ContractSignScreen> createState() => _ContractSignScreenState();
}

class _ContractSignScreenState extends ConsumerState<ContractSignScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  bool _agreeToTerms = false;
  bool _isSubmitting = false;
  String? _signatureBase64;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contractAsync = ref.watch(contractProvider(widget.contractId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Contract'),
        elevation: 0,
      ),
      body: contractAsync.when(
        data: (contract) => _buildSigningFlow(context, contract),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildSigningFlow(BuildContext context, ContractModel contract) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contract Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contract Summary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow('Parties',
                      '${contract.buyerName} & ${contract.sellerName}'),
                  _SummaryRow('Amount',
                      '${contract.currency} ${contract.totalValue.toStringAsFixed(2)}'),
                  _SummaryRow(
                      'Quantity', '${contract.totalQuantity} ${contract.unit}'),
                  _SummaryRow(
                      'Delivery', contract.deliveryTerms ?? 'Not specified'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Signer Information
            const Text(
              'Your Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Legal Name *',
                hintText: 'As per ID/Passport',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address *',
                hintText: 'For signature verification',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),

            // Signature Pad (Simulated)
            const Text(
              'Digital Signature',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      _signatureBase64 != null
                          ? 'Signature captured ✓'
                          : 'Tap to draw signature',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (_signatureBase64 == null) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.draw),
                        label: const Text('Draw Signature'),
                        onPressed: _showSignaturePad,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Terms & Conditions Checkbox
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() => _agreeToTerms = value ?? false);
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Show contract terms dialog
                          },
                          child: const Text(
                            'I have read and agree to all contract terms and conditions',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '⚠️ By signing electronically, you acknowledge that this signature has the same legal effect as a handwritten signature.',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: (_agreeToTerms &&
                        _signatureBase64 != null &&
                        _fullNameController.text.isNotEmpty &&
                        _emailController.text.isNotEmpty &&
                        !_isSubmitting)
                    ? () => _submitSignature()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'SIGN & SUBMIT',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                child: const Text('CANCEL'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSignaturePad() {
    final strokes = <Offset?>[];
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Draw Your Signature'),
          content: Container(
            width: double.maxFinite,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) =>
                  setDialogState(() => strokes.add(details.localPosition)),
              onPanUpdate: (details) =>
                  setDialogState(() => strokes.add(details.localPosition)),
              onPanEnd: (_) => setDialogState(() => strokes.add(null)),
              child: CustomPaint(painter: _SignaturePainter(strokes)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => setDialogState(strokes.clear),
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: strokes.whereType<Offset>().length < 3
                  ? null
                  : () {
                      final vector = strokes
                          .map((point) => point == null
                              ? null
                              : {'x': point.dx, 'y': point.dy})
                          .toList(growable: false);
                      setState(() => _signatureBase64 =
                          base64Encode(utf8.encode(jsonEncode(vector))));
                      Navigator.pop(dialogContext);
                    },
              child: const Text('Save Signature'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitSignature() {
    if (!_agreeToTerms || _signatureBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final service = ref.read(contractServiceProvider);
    final request = SignContractRequest(
      contractId: widget.contractId,
      signature: _signatureBase64!,
      agreeToTerms: true,
      ipAddress: 'server-resolved',
      deviceInfo: 'Flutter Mobile App',
    );

    service.signContract(request).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Contract signed successfully! Awaiting counter-signature.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }).whenComplete(() {
      setState(() => _isSubmitting = false);
    });
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.points);
  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      if (start != null && end != null) canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
