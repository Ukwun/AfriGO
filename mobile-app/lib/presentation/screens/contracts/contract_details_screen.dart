import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/contract_model.dart';
import '../../providers/contract_provider.dart';

class ContractDetailsScreen extends ConsumerWidget {
  final String contractId;

  const ContractDetailsScreen({
    super.key,
    required this.contractId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(contractProvider(contractId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract Details'),
        elevation: 0,
      ),
      body: contractAsync.when(
        data: (contract) => _buildContractDetails(context, ref, contract),
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

  Widget _buildContractDetails(
      BuildContext context, WidgetRef ref, ContractModel contract) {
    final statusColor = _getStatusColor(contract.status);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          contract.status.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${contract.buyerName} ↔ ${contract.sellerName}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type: ${contract.contractType.toUpperCase()}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (contract.isDisputed) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'UNDER DISPUTE - MEDIATION IN PROGRESS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Financial Terms
            _ContractSection(
              title: 'Financial Terms',
              children: [
                _DetailRow('Total Value',
                    '${contract.currency} ${contract.totalValue.toStringAsFixed(2)}'),
                _DetailRow(
                    'Quantity', '${contract.totalQuantity} ${contract.unit}'),
                _DetailRow('Price per Unit',
                    '${contract.currency} ${contract.pricePerUnit.toStringAsFixed(2)}'),
                _DetailRow('Payment Method',
                    _formatPaymentMethod(contract.paymentMethod)),
                if (contract.depositPercentage > 0)
                  _DetailRow(
                      'Deposit Required', '${contract.depositPercentage}%'),
                if (contract.installmentCount != null)
                  _DetailRow(
                      'Installments', contract.installmentCount.toString()),
              ],
            ),

            // Quality Requirements
            _ContractSection(
              title: 'Quality Requirements',
              children: [
                _DetailRow('Required Grade', contract.requiredGrade),
                if (contract.qualitySpecifications != null)
                  _QualitySpecsRow(
                      'Specifications', contract.qualitySpecifications!),
              ],
            ),

            // Delivery Terms
            _ContractSection(
              title: 'Delivery Terms',
              children: [
                _DetailRow(
                    'Start Date',
                    DateFormat('MMM d, yyyy')
                        .format(contract.deliveryStartDate)),
                _DetailRow('End Date',
                    DateFormat('MMM d, yyyy').format(contract.deliveryEndDate)),
                _DetailRow('Terms', contract.deliveryTerms ?? 'Not specified'),
                if (contract.phytosanitaryCertificateRequired)
                  const _DetailRow(
                    'Phytosanitary Certificate',
                    'REQUIRED',
                  ),
              ],
            ),

            // Signature Status
            _ContractSection(
              title: 'Signatures',
              children: [
                _SignatureStatus(
                  party: contract.buyerName,
                  signed: contract.buyerSigned,
                  signedAt: contract.buyerSignedAt,
                ),
                const SizedBox(height: 12),
                _SignatureStatus(
                  party: contract.sellerName,
                  signed: contract.sellerSigned,
                  signedAt: contract.sellerSignedAt,
                ),
                const SizedBox(height: 12),
                Text(
                  'Signature Deadline: ${DateFormat('MMM d, yyyy hh:mm').format(contract.signatureDeadline)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),

            // Insurance & Compliance
            if (contract.insuranceRequired ||
                contract.phytosanitaryCertificateRequired)
              _ContractSection(
                title: 'Insurance & Compliance',
                children: [
                  if (contract.insuranceRequired) ...[
                    const _DetailRow('Insurance Required', 'YES'),
                    if (contract.insuranceProvider != null)
                      _DetailRow('Provider', contract.insuranceProvider!),
                    if (contract.insurancePolicyNumber != null)
                      _DetailRow('Policy #', contract.insurancePolicyNumber!),
                    const SizedBox(height: 12),
                  ],
                  if (contract.phytosanitaryCertificateRequired)
                    const _DetailRow('Phytosanitary Cert', 'REQUIRED'),
                ],
              ),

            // Amendments
            if (contract.amendmentCount > 0)
              _ContractSection(
                title: 'Amendments',
                children: [
                  _DetailRow(
                      'Total Amendments', contract.amendmentCount.toString()),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text('View Amendment History'),
                    onPressed: () {
                      // Navigate to amendments
                    },
                  ),
                ],
              ),

            // Action Buttons
            const SizedBox(height: 32),
            _buildActionButtons(context, contract),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ContractModel contract) {
    if (contract.status == 'draft') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Sign Contract'),
              onPressed: () {
                // Navigate to sign screen
                // context.go('/contracts/${contract.id}/sign');
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close),
              label: const Text('Reject Contract'),
              onPressed: () {
                // Show rejection dialog
              },
            ),
          ),
        ],
      );
    } else if (contract.status == 'signed') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Propose Amendment'),
              onPressed: () {
                // Navigate to amendment screen
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.warning),
              label: const Text('Initiate Dispute'),
              onPressed: () {
                // Show dispute dialog
              },
            ),
          ),
        ],
      );
    } else if (contract.isDisputed) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            children: [
              Icon(Icons.info, color: Colors.orange),
              SizedBox(height: 8),
              Text(
                'This contract is under mediation.',
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                'A mediator has been assigned and will contact both parties.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
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

  String _formatPaymentMethod(String method) {
    return method.replaceAll('_', ' ').toUpperCase();
  }
}

class _ContractSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ContractSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _QualitySpecsRow extends StatelessWidget {
  final String label;
  final String specs;

  const _QualitySpecsRow(this.label, this.specs);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              specs,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignatureStatus extends StatelessWidget {
  final String party;
  final bool signed;
  final DateTime? signedAt;

  const _SignatureStatus({
    required this.party,
    required this.signed,
    this.signedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: signed
            ? Colors.green.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: signed ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            signed ? Icons.check_circle : Icons.schedule,
            color: signed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  party,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
                if (signedAt != null)
                  Text(
                    'Signed ${DateFormat('MMM d, yyyy hh:mm').format(signedAt!)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
              ],
            ),
          ),
          Text(
            signed ? 'SIGNED' : 'PENDING',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: signed ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
