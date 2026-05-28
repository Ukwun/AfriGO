import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../data/services/lot_service.dart';

/// Lot QR Display Screen
/// Displays unique QR code for lot tracking
/// QR code embedded with lot ID for supply chain visibility
///
/// Features:
/// - Display unique QR code
/// - Download/share QR code
/// - Lot details with QR embedded
/// - Real API calls to backend
/// - All buttons functional and clickable
/// - Share via SMS/WhatsApp

class LotQRDisplayScreen extends ConsumerStatefulWidget {
  final String lotId;

  const LotQRDisplayScreen({
    Key? key,
    required this.lotId,
  }) : super(key: key);

  @override
  ConsumerState<LotQRDisplayScreen> createState() => _LotQRDisplayScreenState();
}

class _LotQRDisplayScreenState extends ConsumerState<LotQRDisplayScreen> {
  late Future<Map<String, dynamic>> _lotDetailsFuture;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _lotDetailsFuture = _loadLotDetails();
  }

  /// Load lot details from backend
  Future<Map<String, dynamic>> _loadLotDetails() async {
    try {
      final lotService = LotService();
      final details = await lotService.getLotDetails(widget.lotId);
      print('✅ Lot details loaded');
      return details;
    } catch (e) {
      print('❌ Error loading lot details: $e');
      rethrow;
    }
  }

  /// Download QR code
  Future<void> _downloadQRCode() async {
    try {
      print('📥 Downloading QR code...');
      final lotService = LotService();
      await lotService.downloadLotQRCode(widget.lotId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ QR code downloaded!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Download failed: $e');
    }
  }

  /// Share QR code
  Future<void> _shareQRCode() async {
    setState(() => _isSharing = true);
    try {
      print('📤 Sharing QR code...');
      final lotService = LotService();
      await lotService.shareLotQRCode(widget.lotId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ QR code shared!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Share failed: $e');
    } finally {
      setState(() => _isSharing = false);
    }
  }

  /// Go to lot tracking page
  void _goToTracking() {
    context.go('/trading/lot-tracking/${widget.lotId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lot QR Code'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _lotDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 48, color: Colors.red.shade700),
                  const SizedBox(height: 16),
                  Text('Error loading lot details'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _lotDetailsFuture = _loadLotDetails();
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final lotDetails = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  _buildHeaderCard(context, lotDetails),
                  const SizedBox(height: 24),

                  // QR code display
                  _buildQRCodeDisplay(context),
                  const SizedBox(height: 24),

                  // Lot details card
                  _buildLotDetailsCard(context, lotDetails),
                  const SizedBox(height: 24),

                  // Info section
                  _buildInfoSection(context),
                  const SizedBox(height: 24),

                  // Action buttons
                  _buildActionButtons(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(
      BuildContext context, Map<String, dynamic> lotDetails) {
    return Container(
      key: const Key('qr_display_header'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_2, color: Colors.green.shade700, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lot Ready for Tracking',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your unique QR code is ready to use',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Lot ID: ${widget.lotId}',
              style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeDisplay(BuildContext context) {
    return Container(
      key: const Key('qr_code_display'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Scan to Track Lot',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Center(
            child: QrImageView(
              key: const Key('qr_code_widget'),
              data: widget.lotId,
              version: QrVersions.auto,
              size: 280,
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.lotId,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLotDetailsCard(
      BuildContext context, Map<String, dynamic> lotDetails) {
    return Container(
      key: const Key('lot_details_card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lot Information',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Product:', lotDetails['productType'] ?? 'N/A'),
          _buildDetailRow('Quantity:', '${lotDetails['quantity'] ?? 0} kg'),
          _buildDetailRow('Grade:', lotDetails['grade'] ?? 'N/A'),
          _buildDetailRow('Origin:', lotDetails['origin'] ?? 'N/A'),
          _buildDetailRow('Status:', lotDetails['status'] ?? 'ACTIVE'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      key: const Key('qr_info_section'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'How to Use Your QR Code',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1. Print or save this QR code\n'
            '2. Attach to shipment packaging\n'
            '3. Buyers scan to verify lot authenticity\n'
            '4. Real-time GPS tracking enabled\n'
            '5. Complete supply chain visibility',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                key: const Key('download_qr_button'),
                icon: const Icon(Icons.download),
                label: const Text('DOWNLOAD'),
                onPressed: _downloadQRCode,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                key: const Key('share_qr_button'),
                icon: const Icon(Icons.share),
                label: _isSharing
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('SHARE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                onPressed: _isSharing ? null : _shareQRCode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            key: const Key('view_tracking_button'),
            icon: const Icon(Icons.location_on),
            label: const Text('VIEW TRACKING'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: _goToTracking,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('back_button'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('BACK'),
            onPressed: () => context.pop(),
          ),
        ),
      ],
    );
  }
}
