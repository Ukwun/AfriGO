import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class ContractDetailScreen extends ConsumerStatefulWidget {
  final String contractId;

  const ContractDetailScreen({
    super.key,
    required this.contractId,
  });

  @override
  ConsumerState<ContractDetailScreen> createState() =>
      _ContractDetailScreenState();
}

class _ContractDetailScreenState extends ConsumerState<ContractDetailScreen>
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
        title: Text('Contract ${widget.contractId}'),
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
                // Contract Status
                ScaleInTransition(
                  child: _buildStatusCard(),
                ),
                const SizedBox(height: 24),

                // Parties
                ScaleInTransition(
                  child: _buildSectionHeader('Parties'),
                ),
                const SizedBox(height: 12),
                ScaleInTransition(
                  child: _buildPartyCard(
                      'Buyer', 'Global Traders Ltd', 'info@globaltraders.com'),
                ),
                const SizedBox(height: 8),
                ScaleInTransition(
                  child: _buildPartyCard(
                      'Supplier', 'Premium Cocoa Co', 'sales@premiumcocoa.com'),
                ),
                const SizedBox(height: 24),

                // Contract Terms
                ScaleInTransition(
                  child: _buildSectionHeader('Contract Terms'),
                ),
                const SizedBox(height: 12),
                ..._buildTermsList(),
                const SizedBox(height: 24),

                // Clauses
                ScaleInTransition(
                  child: _buildSectionHeader('Key Clauses'),
                ),
                const SizedBox(height: 12),
                ..._buildClausesList(),
                const SizedBox(height: 24),

                // Signatures
                ScaleInTransition(
                  child: _buildSignaturesSection(),
                ),
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
            Colors.green.withOpacity(0.1),
            Colors.teal.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contract Status',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(height: 4),
              Text('Active & Signed',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.green)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.verified_user, color: Colors.green, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyCard(String role, String name, String email) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.business,
                color: AppColors.accentBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(email,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTermsList() {
    final terms = [
      ('Product', 'Premium Cocoa Beans Grade A'),
      ('Quantity', '5,000 kg'),
      ('Price', '\$12,500 (CIF)'),
      ('Delivery Date', 'September 15, 2024'),
      ('Payment Terms', '30% upfront, 70% on delivery'),
      ('Inspection', 'By certified inspector'),
    ];

    return List.generate(terms.length, (index) {
      final (label, value) = terms[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ScaleInTransition(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _buildClausesList() {
    final clauses = [
      ('Force Majeure', 'Neither party liable for unforeseen circumstances'),
      ('Quality Assurance', 'Goods must meet ISO standards'),
      ('Liability', 'Limited to contract value'),
      ('Dispute Resolution', 'Arbitration in neutral territory'),
    ];

    return List.generate(clauses.length, (index) {
      final (title, description) = clauses[index];
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
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(description,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSignaturesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Compliance & Verification'),
          const SizedBox(height: 12),
          _buildSignatureItem(
              'Buyer Signature', true, 'Signed on Aug 20, 2024'),
          const SizedBox(height: 8),
          _buildSignatureItem(
              'Supplier Signature', true, 'Signed on Aug 20, 2024'),
          const SizedBox(height: 8),
          _buildSignatureItem('Legal Review', true, 'Approved on Aug 20, 2024'),
        ],
      ),
    );
  }

  Widget _buildSignatureItem(String label, bool signed, String date) {
    return Row(
      children: [
        Icon(
          signed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: signed ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}
