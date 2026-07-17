import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class DossierViewScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const DossierViewScreen({
    super.key,
    required this.dossierId,
  });

  @override
  ConsumerState<DossierViewScreen> createState() => _DossierViewScreenState();
}

class _DossierViewScreenState extends ConsumerState<DossierViewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dossier ${Uri.decodeComponent(widget.dossierId)}'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Download PDF')),
              const PopupMenuItem(child: Text('Print')),
              const PopupMenuItem(child: Text('Share')),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Packet Info
                ScaleInTransition(
                  child: _buildPacketInfo(),
                ),
                const SizedBox(height: 24),

                // Full Export Packet
                ScaleInTransition(
                  child: _buildSectionHeader('Full Export Packet'),
                ),
                const SizedBox(height: 12),
                ..._buildPacketContents(),
                const SizedBox(height: 24),

                // Audit Stamps
                ScaleInTransition(
                  child: _buildSectionHeader('Audit Stamps & Approvals'),
                ),
                const SizedBox(height: 12),
                ..._buildAuditStamps(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPacketInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentBlue.withOpacity(0.1),
            AppColors.secondaryGold.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COCOA-2024-001',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('5 Tonnes Premium Cocoa Beans',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem('Destination', 'Germany'),
              _buildInfoItem('Status', 'Approved'),
              _buildInfoItem('Date', 'Aug 20, 2024'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  List<Widget> _buildPacketContents() {
    final documents = [
      ('📋 Commercial Invoice', '8 pages', 'view'),
      ('📦 Packing List', '2 pages', 'view'),
      ('🌍 Certificate of Origin', '1 page', 'view'),
      ('✅ Quality Certificate', '3 pages', 'view'),
      ('📄 Bill of Lading', '4 pages', 'view'),
      ('🛡️ Insurance Certificate', '1 page', 'view'),
      ('🏥 Health Certificate', '2 pages', 'view'),
      ('📜 Import License', '1 page', 'view'),
    ];

    return List.generate(documents.length, (index) {
      final (doc, pages, action) = documents[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ScaleInTransition(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(pages,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showPreview(doc),
                  child: const Text('View'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildAuditStamps() {
    final stamps = [
      ('🟢 Customs Cleared', 'Aug 20, 2024 10:45 AM', 'Lagos Port Authority'),
      ('🟢 Quality Verified', 'Aug 19, 2024 02:30 PM', 'Certified Inspector'),
      ('🟢 Export Registered', 'Aug 18, 2024 09:00 AM', 'Trade Ministry'),
      ('🟢 Insurance Approved', 'Aug 18, 2024 08:15 AM', 'Insurance Broker'),
    ];

    return List.generate(stamps.length, (index) {
      final (stamp, date, authority) = stamps[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ScaleInTransition(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stamp,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(date,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(authority,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  void _showPreview(String doc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📄 Preview: $doc')),
    );
  }
}
