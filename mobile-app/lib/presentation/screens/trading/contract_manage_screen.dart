import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/colors.dart';
import '../../widgets/motion_system.dart';

class ContractManageScreen extends ConsumerStatefulWidget {
  final String contractId;

  const ContractManageScreen({
    super.key,
    required this.contractId,
  });

  @override
  ConsumerState<ContractManageScreen> createState() =>
      _ContractManageScreenState();
}

class _ContractManageScreenState extends ConsumerState<ContractManageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedTab = 'amendments';

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
        title: Text('Manage Contract ${widget.contractId}'),
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
                // Tab Selection
                ScaleInTransition(
                  child: _buildTabSelection(),
                ),
                const SizedBox(height: 24),

                // Content based on selected tab
                if (_selectedTab == 'amendments') ..._buildAmendmentsSection(),
                if (_selectedTab == 'delivery') ..._buildDeliverySection(),
                if (_selectedTab == 'milestones') ..._buildMilestonesSection(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelection() {
    return Row(
      children: [
        _buildTab('amendments', 'Amendments'),
        const SizedBox(width: 12),
        _buildTab('delivery', 'Delivery'),
        const SizedBox(width: 12),
        _buildTab('milestones', 'Milestones'),
      ],
    );
  }

  Widget _buildTab(String value, String label) {
    final isSelected = _selectedTab == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedTab = value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentBlue : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAmendmentsSection() {
    return [
      ScaleInTransition(
        child: _buildSectionHeader('Contract Amendments'),
      ),
      const SizedBox(height: 12),
      ScaleInTransition(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Amendment #1',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Requested: 2024-08-25',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              const Text(
                  'Extension of delivery date by 5 days due to port congestion'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showDialog('Amendment Approved'),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDialog('Amendment Rejected'),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildDeliverySection() {
    return [
      ScaleInTransition(
        child: _buildSectionHeader('Delivery Updates'),
      ),
      const SizedBox(height: 12),
      ScaleInTransition(
        child: Column(
          children: [
            _buildDeliveryItem('Goods Prepared', '2024-08-20', true),
            const SizedBox(height: 8),
            _buildDeliveryItem('Goods Shipped', '2024-08-22', true),
            const SizedBox(height: 8),
            _buildDeliveryItem('In Transit', 'Expected 2024-08-28', true),
            const SizedBox(height: 8),
            _buildDeliveryItem('Delivered', 'Pending', false),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildMilestonesSection() {
    return [
      ScaleInTransition(
        child: _buildSectionHeader('Payment Milestones'),
      ),
      const SizedBox(height: 12),
      ScaleInTransition(
        child: Column(
          children: [
            _buildMilestoneItem('30% Upfront', '\$3,750', 'Paid', true),
            const SizedBox(height: 8),
            _buildMilestoneItem('70% on Delivery', '\$8,750', 'Pending', false),
          ],
        ),
      ),
    ];
  }

  Widget _buildDeliveryItem(String label, String date, bool completed) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: completed ? Colors.green.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: completed ? Colors.green.withOpacity(0.2) : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(
      String label, String amount, String status, bool completed) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(amount,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryGold,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: completed
                  ? Colors.green.withOpacity(0.2)
                  : Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: completed ? Colors.green : Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
