import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/motion_system.dart';

class DossierDetailScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const DossierDetailScreen({
    super.key,
    required this.dossierId,
  });

  @override
  ConsumerState<DossierDetailScreen> createState() =>
      _DossierDetailScreenState();
}

class _DossierDetailScreenState extends ConsumerState<DossierDetailScreen>
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
      ),
      body: FadeTransition(
        opacity: _animationController,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status
                ScaleInTransition(
                  child: _buildStatusCard(),
                ),
                const SizedBox(height: 24),

                // Document Status
                ScaleInTransition(
                  child: _buildSectionHeader('Document Status'),
                ),
                const SizedBox(height: 12),
                ..._buildDocumentsList(),
                const SizedBox(height: 24),

                // Missing Items
                ScaleInTransition(
                  child: _buildSectionHeader('Missing Items'),
                ),
                const SizedBox(height: 12),
                ScaleInTransition(
                  child: _buildMissingItemsAlert(),
                ),
                const SizedBox(height: 24),

                // Verification Trail
                ScaleInTransition(
                  child: _buildSectionHeader('Verification Trail'),
                ),
                const SizedBox(height: 12),
                ..._buildVerificationTrail(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.1),
            Colors.orange.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dossier Status',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(height: 4),
              Text('Pending',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber)),
              SizedBox(height: 4),
              Text('6/8 documents ready',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.hourglass_empty,
                color: Colors.amber, size: 24),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDocumentsList() {
    final docs = [
      ('Commercial Invoice', true, 'Verified Aug 20'),
      ('Bill of Lading', true, 'Verified Aug 20'),
      ('Certificate of Origin', true, 'Verified Aug 19'),
      ('Quality Certificate', true, 'Verified Aug 19'),
      ('Packing List', true, 'Verified Aug 18'),
      ('Insurance Certificate', true, 'Verified Aug 18'),
      ('Health Certificate', false, 'Pending'),
      ('Import License', false, 'Awaiting approval'),
    ];

    return List.generate(docs.length, (index) {
      final (name, verified, status) = docs[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ScaleInTransition(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: verified
                  ? Colors.green.withOpacity(0.05)
                  : Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: verified
                    ? Colors.green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      verified
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: verified ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text(status,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMissingItemsAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text('2 Items Missing',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          _buildMissingItem(
              'Health Certificate - Export health clearance (from supplier)'),
          const SizedBox(height: 8),
          _buildMissingItem(
              'Import License - Recipient country import approval'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showAction('Notification sent to supplier'),
            icon: const Icon(Icons.notifications, size: 18),
            label: const Text('Notify Supplier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingItem(String item) {
    return Row(
      children: [
        const Icon(Icons.info, size: 18, color: Colors.orange),
        const SizedBox(width: 8),
        Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  List<Widget> _buildVerificationTrail() {
    final events = [
      ('Commercial Invoice Verified', 'Aug 20, 10:30 AM', 'by Admin'),
      ('Dossier Submitted', 'Aug 18, 02:15 PM', 'by Exporter'),
      ('Dossier Created', 'Aug 15, 09:00 AM', 'by System'),
    ];

    return List.generate(events.length, (index) {
      final (event, time, actor) = events[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ScaleInTransition(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(time,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(actor,
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

  void _showAction(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
