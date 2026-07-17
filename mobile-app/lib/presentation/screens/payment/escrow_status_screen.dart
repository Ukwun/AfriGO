import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/payment_model.dart';
import '../../providers/payment_provider.dart';

/// Escrow Status Screen - Track escrow conditions and fund release
class EscrowStatusScreen extends ConsumerStatefulWidget {
  final String escrowId;
  final String paymentId;

  const EscrowStatusScreen({
    super.key,
    required this.escrowId,
    required this.paymentId,
  });

  @override
  ConsumerState<EscrowStatusScreen> createState() => _EscrowStatusScreenState();
}

class _EscrowStatusScreenState extends ConsumerState<EscrowStatusScreen> {
  final List<String> conditions = [
    'DELIVERY_PROOF',
    'QUALITY_APPROVAL',
    'BUYER_SIGNOFF',
  ];

  @override
  Widget build(BuildContext context) {
    final escrowAsync = ref.watch(getEscrowProvider(widget.escrowId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escrow Status'),
        elevation: 0,
      ),
      body: escrowAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.refresh(getEscrowProvider(widget.escrowId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (escrow) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Overview Card
                  _buildStatusCard(escrow),
                  const SizedBox(height: 24),

                  // Escrow Amount
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Held Amount',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_getCurrencySymbol(escrow.currency)}${escrow.amount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 12),
                          if (escrow.holdingFeePercentage > 0)
                            Text(
                              'Holding Fee: ${escrow.holdingFeePercentage.toStringAsFixed(2)}%',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          if (escrow.autoReleaseDate != null)
                            Text(
                              'Auto-Release: ${DateFormat('MMM dd, yyyy').format(escrow.autoReleaseDate!)}',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Release Conditions
                  Text(
                    'Release Conditions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'All ${escrow.conditionsMetCount}/3 conditions must be met to release funds',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),

                  // Progress indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: escrow.conditionsMetCount / 3,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        escrow.allConditionsMet ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Conditions List
                  ...conditions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final condition = entry.value;
                    final conditionData = escrow.conditionsMet[condition]
                        as Map<String, dynamic>?;
                    final isMet = conditionData?['met'] ?? false;

                    return Column(
                      children: [
                        _buildConditionTile(
                          condition,
                          isMet,
                          conditionData,
                          escrow,
                        ),
                        if (index < conditions.length - 1)
                          const SizedBox(height: 12),
                      ],
                    );
                  }),

                  const SizedBox(height: 24),

                  // Escrow Timeline
                  Text(
                    'Timeline',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildTimelineItem(
                    'Created',
                    DateFormat('MMM dd, yyyy HH:mm').format(escrow.createdAt),
                    true,
                  ),
                  if (escrow.releasedAt != null)
                    _buildTimelineItem(
                      'Released',
                      DateFormat('MMM dd, yyyy HH:mm')
                          .format(escrow.releasedAt!),
                      true,
                    ),
                  if (escrow.refundedAt != null)
                    _buildTimelineItem(
                      'Refunded',
                      DateFormat('MMM dd, yyyy HH:mm')
                          .format(escrow.refundedAt!),
                      true,
                    ),

                  const SizedBox(height: 24),

                  // Actions
                  if (escrow.isHeld && !escrow.allConditionsMet)
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showDisputeDialog(escrow, context),
                            icon: const Icon(Icons.warning),
                            label: const Text('File Dispute'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'If conditions are not met or seller is unresponsive',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                  if (escrow.isReleased)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Funds Released',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Seller has received payment on ${DateFormat('MMM dd, yyyy').format(escrow.releasedAt!)}',
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Security Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Escrow funds are held securely and released only when all conditions are met',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(EscrowModel escrow) {
    final statusColor = _getStatusColor(escrow.status);

    return Card(
      elevation: 4,
      color: statusColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(escrow.status),
                  color: statusColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      escrow.statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Escrow ID: ${escrow.id.substring(0, 8)}...',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionTile(
    String condition,
    bool isMet,
    Map<String, dynamic>? conditionData,
    EscrowModel escrow,
  ) {
    String conditionLabel;
    String conditionDescription;

    switch (condition) {
      case 'DELIVERY_PROOF':
        conditionLabel = 'Delivery Proof';
        conditionDescription = 'Shipment must be delivered to buyer location';
        break;
      case 'QUALITY_APPROVAL':
        conditionLabel = 'Quality Approval';
        conditionDescription = 'Buyer confirms goods meet quality standards';
        break;
      case 'BUYER_SIGNOFF':
        conditionLabel = 'Buyer Sign-off';
        conditionDescription = 'Final buyer confirmation and acceptance';
        break;
      default:
        conditionLabel = condition;
        conditionDescription = 'Release condition';
    }

    return Card(
      color: isMet ? Colors.green.shade50 : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isMet ? Colors.green : Colors.grey.shade300,
                  ),
                  child: Icon(
                    isMet ? Icons.check : Icons.schedule,
                    color: isMet ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conditionLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isMet ? Colors.green.shade700 : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conditionDescription,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isMet && conditionData?['metAt'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Completed: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(conditionData!['metAt']))}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (!isMet && escrow.isHeld)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showConditionProofDialog(condition, escrow),
                    icon: const Icon(Icons.upload, size: 16),
                    label: const Text('Mark as Met'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showConditionProofDialog(String condition, EscrowModel escrow) {
    final proofUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Proof'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: proofUrlController,
              decoration: const InputDecoration(
                labelText: 'Proof URL or file',
                hintText: 'e.g., delivery confirmation, quality report',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Call release escrow condition
              Navigator.pop(context);
              _submitConditionProof(condition, proofUrlController.text);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitConditionProof(String condition, String proofUrl) async {
    try {
      await ref.read(
        releaseEscrowConditionProvider((
          widget.escrowId,
          condition,
          proofUrl.isNotEmpty ? proofUrl : null,
        )).future,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Condition marked as met'),
            backgroundColor: Colors.green,
          ),
        );
        ref.refresh(getEscrowProvider(widget.escrowId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showDisputeDialog(EscrowModel escrow, BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Dispute'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Explain why you are disputing this escrow:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
                hintText: 'Seller not responding, goods not delivered, etc.',
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Dispute filed. Support team will review shortly.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('File Dispute'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.green : Colors.grey.shade300,
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.schedule,
              color: isCompleted ? Colors.white : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'RELEASED':
        return Colors.green;
      case 'HELD':
        return Colors.blue;
      case 'CREATED':
      case 'FUNDED':
        return Colors.orange;
      case 'REFUNDED':
        return Colors.purple;
      case 'DISPUTED':
        return Colors.red;
      case 'RESOLVED':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'RELEASED':
        return Icons.check_circle;
      case 'HELD':
        return Icons.lock;
      case 'CREATED':
        return Icons.info;
      case 'FUNDED':
        return Icons.account_balance;
      case 'REFUNDED':
        return Icons.undo;
      case 'DISPUTED':
        return Icons.warning;
      case 'RESOLVED':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'KES':
        return 'Ksh ';
      case 'USD':
        return '\$ ';
      case 'EUR':
        return '€ ';
      case 'ZAR':
        return 'R ';
      case 'UGX':
        return 'UGX ';
      case 'TZS':
        return 'Tsh ';
      default:
        return '$currency ';
    }
  }
}
