import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/contract_model.dart';
import '../../providers/contract_provider.dart';

class ContractListScreen extends ConsumerStatefulWidget {
  const ContractListScreen({super.key});

  @override
  ConsumerState<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends ConsumerState<ContractListScreen> {
  String? _selectedStatus;
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(contractsProvider((
      status: _selectedStatus,
      type: null,
      limit: 20,
      offset: _offset,
    )));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Contracts'),
        elevation: 0,
      ),
      body: contractsAsync.when(
        data: (result) =>
            _buildContractsList(context, result.data, result.total),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContractsList(
      BuildContext context, List<ContractListModel> contracts, int total) {
    if (contracts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No contracts yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Contracts will appear when you win RFQs',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filter Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedStatus == null,
                  onTap: () => setState(() => _selectedStatus = null),
                ),
                _FilterChip(
                  label: 'Draft',
                  selected: _selectedStatus == 'draft',
                  onTap: () => setState(() => _selectedStatus = 'draft'),
                ),
                _FilterChip(
                  label: 'Signed',
                  selected: _selectedStatus == 'signed',
                  onTap: () => setState(() => _selectedStatus = 'signed'),
                ),
                _FilterChip(
                  label: 'Active',
                  selected: _selectedStatus == 'active',
                  onTap: () => setState(() => _selectedStatus = 'active'),
                ),
                _FilterChip(
                  label: 'Disputed',
                  selected: _selectedStatus == 'disputed',
                  onTap: () => setState(() => _selectedStatus = 'disputed'),
                ),
              ],
            ),
          ),
        ),

        // Contract List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final contract = contracts[index];
              return _ContractCard(contract: contract);
            },
          ),
        ),

        // Pagination
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_offset > 0)
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  onPressed: () =>
                      setState(() => _offset = (_offset - 20).clamp(0, total)),
                ),
              Text(
                  'Showing ${_offset + 1}-${(_offset + 20).clamp(0, total)} of $total'),
              if (_offset + 20 < total)
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  onPressed: () => setState(() => _offset += 20),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContractCard extends StatelessWidget {
  final ContractListModel contract;

  const _ContractCard({required this.contract});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(contract.status);
    final daysUntilDelivery =
        contract.deliveryEndDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to contract details
          // context.go('/contracts/${contract.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${contract.buyerName} → ${contract.sellerName}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${contract.id.substring(0, 8)}',
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      contract.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Contract Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${contract.contractType.capitalize()}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    '\$${contract.totalValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Signature Status
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _SignatureIndicator(
                      label: 'You',
                      signed: contract.buyerSigned,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 12, color: Colors.grey),
                  Expanded(
                    flex: 1,
                    child: _SignatureIndicator(
                      label: 'Counterparty',
                      signed: contract.sellerSigned,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dates & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Delivery',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text(
                        DateFormat('MMM d, yyyy')
                            .format(contract.deliveryEndDate),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: daysUntilDelivery > 15
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '$daysUntilDelivery days',
                          style: TextStyle(
                            fontSize: 10,
                            color: daysUntilDelivery > 15
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (contract.isDisputed)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning, size: 16, color: Colors.red),
                          SizedBox(width: 4),
                          Text(
                            'DISPUTE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'active':
        return Colors.blue;
      case 'signed':
        return Colors.green;
      case 'executed':
        return Colors.teal;
      case 'terminated':
        return Colors.red;
      case 'disputed':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class _SignatureIndicator extends StatelessWidget {
  final String label;
  final bool signed;

  const _SignatureIndicator({
    required this.label,
    required this.signed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: signed ? Colors.green : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              signed ? Icons.check : Icons.close,
              color: signed ? Colors.white : Colors.grey,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

extension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
