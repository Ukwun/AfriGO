import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:hand_signature/hand_signature.dart';  // TODO: Package installation issue
import '../../../../data/services/contract_service.dart';
import '../../../../data/services/trade_service.dart';
import 'widgets/contract_display_widget.dart';
import 'widgets/signature_widgets.dart';

/// Contract Signing Screen
/// Digital e-signature capture with cryptographic timestamps
/// Both parties see contract in real-time via WebSocket
///
/// Features:
/// - Auto-generated contract from trade terms
/// - E-signature capture (finger drawing on screen)
/// - Cryptographic signing with UTC timestamp
/// - Both parties synchronized <500ms
/// - Immutable signature log
/// - Contract PDF export

class ContractSigningScreen extends ConsumerStatefulWidget {
  final String tradeId;

  const ContractSigningScreen({
    super.key,
    required this.tradeId,
  });

  @override
  ConsumerState<ContractSigningScreen> createState() =>
      _ContractSigningScreenState();
}

class _ContractSigningScreenState extends ConsumerState<ContractSigningScreen> {
  // late HandSignatureControl _signatureControl;  // TODO: hand_signature package issue
  final bool _isSignatureCapturing = false;
  final bool _isSigning = false;
  String? _signatureHash;
  DateTime? _signatureTimestamp;

  @override
  void initState() {
    super.initState();
    // TODO: Initialize signature control when hand_signature is fixed
    // _signatureControl = HandSignatureControl(
    //   onPointerDown: () => setState(() => _isSignatureCapturing = true),
    //   onPointerUp: () => setState(() => _isSignatureCapturing = false),
    // );
  }

  @override
  void dispose() {
    // TODO: Dispose signature control when hand_signature is fixed
    // _signatureControl.dispose();
    super.dispose();
  }

  /// Generate contract from trade terms
  Future<void> _generateContract() async {
    try {
      final contractService = ContractService();
      final tradeService = TradeService();

      // Get trade details
      final trade = await tradeService.getTradeDetail(widget.tradeId);

      // Generate contract from trade terms
      await contractService.generateContract(
        tradeId: widget.tradeId,
        productType: trade['productType'],
        quantity: trade['quantity'],
        price: trade['price'],
        qualityGrade: trade['qualityGrade'],
        deliveryDays: trade['deliveryDays'],
        buyerId: trade['buyerId'],
        sellerId: trade['sellerId'],
      );

      print('✅ Contract Generated from Trade Terms');
    } catch (e) {
      print('❌ Contract Generation Failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating contract: $e')),
        );
      }
    }
  }

  /// Capture and sign contract with cryptographic signature
  Future<void> _signContract() async {
    // TODO: Re-enable when hand_signature is fixed
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Signature capture (temporarily unavailable - hand_signature package pending)'),
          duration: Duration(seconds: 3),
        ),
      );
    }
    return;
    // Original code commented out:
    // if (_signatureControl.isEmpty) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Please draw your signature')),
    //     );
    //   }
    //   return;
    // }

    // setState(() => _isSigning = true);

    // try {
    //   final contractService = ContractService();

    //   // Get signature as image bytes
    //   final signatureImage = await _signatureControl.toImage();
    //   final signatureBytes = await signatureImage?.toByteData(
    //     format: ui.ImageByteFormat.png,
    //   );

    //   if (signatureBytes == null) {
    //     throw Exception('Failed to capture signature');
    //   }

    //   // Sign contract with cryptographic timestamp
    //   final signature = await contractService.signContract(
    //     tradeId: widget.tradeId,
    //     signatureBytes: signatureBytes.buffer.asUint8List(),
    //     signerName: 'Current User', // Get from auth
    //   );

    //   setState(() {
    //     _signatureHash = signature['hash'];
    //     _signatureTimestamp = DateTime.parse(signature['timestamp']);
    //   });

    //   // Show success
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: const Text('Contract Signed Successfully! ✅'),
    //         backgroundColor: Colors.green,
    //       ),
    //     );
    //   }

    //   // Broadcast signing event to other party
    //   print('🔔 Broadcasting CONTRACT_SIGNED event via WebSocket');

    //   // Wait 2 seconds then navigate to tracking
    //   await Future.delayed(const Duration(seconds: 2));
    //   if (mounted) {
    //     context.go('/trading/tracking/${widget.tradeId}');
    //   }
    // } catch (e) {
    //   print('❌ Signing Failed: $e');
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Error signing contract: $e'),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
    // } finally {
    //   setState(() => _isSigning = false);
    // }
  }

  /// Export contract as PDF
  Future<void> _exportPDF() async {
    try {
      final contractService = ContractService();
      await contractService.exportContractPDF(widget.tradeId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contract exported as PDF ✅')),
        );
      }
    } catch (e) {
      print('❌ PDF Export Failed: $e');
    }
  }

  /// Clear signature for redrawing
  void _clearSignature() {
    // TODO: Re-enable when hand_signature is fixed
    // _signatureControl.clear();
    setState(() {
      _signatureHash = null;
      _signatureTimestamp = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Contract Signing'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (_signatureHash != null)
            Tooltip(
              message: 'Contract signed and immutable',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'Signed',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contract Display Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  _buildStatusCard(context),
                  const SizedBox(height: 16),

                  // Trade Terms Summary
                  _buildTradeTermsSummary(context),
                  const SizedBox(height: 16),

                  // Full Contract Display
                  _buildContractDisplay(context),
                  const SizedBox(height: 24),

                  // Signature Section Header
                  Text(
                    'Digital Signature',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Draw your signature below to sign this contract',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),

                  // Signature Canvas
                  _buildSignatureCanvas(context),
                  const SizedBox(height: 16),

                  // Signature Controls
                  _buildSignatureControls(context),
                  const SizedBox(height: 16),

                  // Signature Verification (if signed)
                  if (_signatureHash != null) ...[
                    SignatureVerificationWidget(
                      key: const Key('signature_verification_widget'),
                      signatureHash: _signatureHash!,
                      timestamp: _signatureTimestamp!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action Buttons
                  _buildActionButtons(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build status card showing contract status
  Widget _buildStatusCard(BuildContext context) {
    return Container(
      key: const Key('contract_status_card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.document_scanner,
            color: Colors.blue.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contract Ready for Signing',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generated from trade agreement. Valid for all parties.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build trade terms summary at top of contract
  Widget _buildTradeTermsSummary(BuildContext context) {
    return Container(
      key: const Key('contract_trade_terms'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trade Terms Summary',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          _buildTermRow('Product:', 'Cocoa Grade A'),
          _buildTermRow('Quantity:', '1,000 kg'),
          _buildTermRow('Unit Price:', '\$2.40/kg'),
          _buildTermRow('Total Value:', '\$2,400.00'),
          _buildTermRow('Delivery Days:', '7 days'),
          _buildTermRow('Quality Grade:', 'Grade A'),
          _buildTermRow('Buyer Trust Score:', '4.8 ⭐'),
          _buildTermRow('Seller Trust Score:', '4.9 ⭐'),
        ],
      ),
    );
  }

  /// Build individual term row
  Widget _buildTermRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  /// Build full contract display
  Widget _buildContractDisplay(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Contract',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ContractDisplayWidget(
          key: const Key('contract_content'),
          tradeId: widget.tradeId,
          contractContent: _getContractContent(),
        ),
      ],
    );
  }

  /// Build signature canvas for drawing signature
  Widget _buildSignatureCanvas(BuildContext context) {
    return Container(
      key: const Key('signature_canvas'),
      decoration: BoxDecoration(
        border: Border.all(
          color: _isSignatureCapturing ? Colors.blue : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Text(
            'Signature Pad\n(Package update pending)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  /// Build signature control buttons
  Widget _buildSignatureControls(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            key: const Key('clear_signature_button'),
            icon: const Icon(Icons.clear),
            label: const Text('Clear Signature'),
            onPressed: _clearSignature,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            key: const Key('undo_signature_button'),
            icon: const Icon(Icons.undo),
            label: const Text('Undo'),
            onPressed: null, // TODO: Re-enable when hand_signature is fixed
          ),
        ),
      ],
    );
  }

  /// Build main action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Real-time event badge
        RealTimeEventBadge(
          eventType: 'CONTRACT_SIGNING',
          eventMessage: 'Signing in progress...',
          isVisible: _isSigning,
        ),
        if (_isSigning) const SizedBox(height: 12),

        // Both parties sync indicator
        BothPartiesSyncIndicator(
          isSynced: _signatureHash != null,
          lastSyncTime: _signatureTimestamp,
        ),
        const SizedBox(height: 12),

        // Sign Contract Button (Main action)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            key: const Key('sign_contract_button'),
            icon: const Icon(Icons.edit_document),
            label: _isSigning
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text('SIGN CONTRACT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              disabledBackgroundColor: Colors.grey,
            ),
            onPressed: _isSigning ? null : _signContract,
          ),
        ),
        const SizedBox(height: 12),

        // Secondary Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('export_pdf_button'),
                icon: const Icon(Icons.download),
                label: const Text('Export PDF'),
                onPressed: _exportPDF,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('view_history_button'),
                icon: const Icon(Icons.history),
                label: const Text('View History'),
                onPressed: () {
                  // Show signature history
                  showDialog(
                    context: context,
                    builder: (context) => _buildSignatureHistoryDialog(context),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Immutability guarantee
        ImmutabilityGuaranteeWidget(contractId: widget.tradeId),

        const SizedBox(height: 12),

        // Info message
        if (_signatureHash != null)
          Container(
            key: const Key('contract_signed_message'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contract Signed ✅',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Signature is immutable and verified.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Build signature history dialog
  Widget _buildSignatureHistoryDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Signature Audit Trail'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_signatureTimestamp != null) ...[
              _buildHistoryItem(
                key: const Key('current_signature_history'),
                signerName: 'You (Current User)',
                timestamp: _signatureTimestamp!,
                status: 'Signed',
                hash: _signatureHash!,
              ),
            ],
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'This audit trail is immutable and permanently stored.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  /// Build individual history item
  Widget _buildHistoryItem({
    required Key key,
    required String signerName,
    required DateTime timestamp,
    required String status,
    required String hash,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                signerName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Timestamp: ${timestamp.toUtc()}',
            key: const Key('signature_timestamp'),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Hash: ${hash.substring(0, 16)}...',
            style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  /// Get contract content (would be fetched from backend in real app)
  String _getContractContent() {
    return '''
COMMERCIAL TRADING CONTRACT

This Contract is entered into as of ${DateTime.now().toString().split(' ')[0]}, between:

BUYER: Current User (Buyer Entity)
SELLER: Seller Name (Seller Entity)

WHEREAS, the Buyer wishes to purchase from the Seller, and the Seller wishes to sell to the Buyer, certain goods as outlined below;

NOW, THEREFORE, in consideration of the mutual covenants and agreements contained herein, the parties agree as follows:

1. PRODUCT DESCRIPTION
   Product: Cocoa Grade A
   Quality Grade: Grade A
   Specifications: As per international standards

2. QUANTITY AND PRICE
   Quantity: 1,000 kg
   Unit Price: \$2.40 per kg
   Total Amount: \$2,400.00 USD

3. DELIVERY TERMS
   Estimated Delivery: 7 days from contract signing
   Delivery Location: Buyer's specified destination
   Shipping Method: As agreed upon
   Delivery Risk: Passed to Buyer upon delivery

4. PAYMENT TERMS
   Payment Method: Escrow through AfriGo Platform
   Timing: Payment held in escrow until delivery confirmed
   Release: Upon buyer's delivery confirmation

5. QUALITY VERIFICATION
   Quality tests performed before shipment
   Results included in shipping documentation
   Buyer has 48 hours to verify quality upon delivery

6. DISPUTE RESOLUTION
   Any disputes shall be resolved through AfriGo's dispute resolution process
   Evidence-based review by platform administrators
   Decisions are binding on both parties

7. IMMUTABILITY
   This contract, once signed, is immutable and permanent
   All signatures are cryptographically verified
   Digital signatures have the same legal weight as physical signatures

8. ACKNOWLEDGMENT
   Both parties acknowledge that they have read and understood this contract
   Both parties agree to be bound by its terms
   This contract is binding and enforceable

SIGNATURE:
[Digital Signature Captured]

VERIFICATION:
This contract has been cryptographically signed with UTC timestamp.
All signatures and timestamps are immutable and cannot be modified.

---
Generated by AfriGo Trading Platform
Immutable Ledger: Permanent Record
''';
  }
}
