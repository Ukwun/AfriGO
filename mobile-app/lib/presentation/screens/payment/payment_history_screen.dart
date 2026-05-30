import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/motion_system.dart';

/// Payment History Screen - List of past payments with status tracking
class PaymentHistoryScreen extends ConsumerStatefulWidget {
  final String? contractId;

  const PaymentHistoryScreen({
    super.key,
    this.contractId,
  });

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  String? _selectedStatus;
  String? _selectedMethod;
  final int _limit = 20;
  int _offset = 0;

  final List<String> statuses = [
    'COMPLETED',
    'PENDING',
    'INITIATED',
    'PROCESSING',
    'FAILED',
    'REFUNDED',
    'DISPUTED',
  ];

  final List<String> methods = [
    'FULL_UPFRONT',
    'PARTIAL_DEPOSIT',
    'ON_DELIVERY',
    'INSTALLMENT',
    'ESCROW',
  ];

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(
      listPaymentsProvider((
        status: _selectedStatus,
        paymentMethod: _selectedMethod,
        contractId: widget.contractId,
        currency: null,
        limit: _limit,
        offset: _offset,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildFilterChip(
                    'Status',
                    _selectedStatus,
                    statuses,
                    (value) {
                      setState(() {
                        _selectedStatus = value;
                        _offset = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Method',
                    _selectedMethod,
                    methods,
                    (value) {
                      setState(() {
                        _selectedMethod = value;
                        _offset = 0;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          // Payments List
          Expanded(
            child: paymentsAsync.when(
              loading: () => PageSkeletonLoader(
                elements: [
                  SkeletonElement(type: SkeletonType.card, height: 100),
                  SkeletonElement(type: SkeletonType.card, height: 100),
                  SkeletonElement(type: SkeletonType.card, height: 100),
                  SkeletonElement(type: SkeletonType.card, height: 100),
                ],
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    AnimatedPrimaryButton(
                      label: 'Retry',
                      onPressed: () => ref.refresh(
                        listPaymentsProvider((
                          status: _selectedStatus,
                          paymentMethod: _selectedMethod,
                          contractId: widget.contractId,
                          currency: null,
                          limit: _limit,
                          offset: _offset,
                        )),
                      ),
                      isLargeTouchTarget: true,
                    ),
                  ],
                ),
              ),
              data: (payments) {
                if (payments.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No payments found'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return ScaleInTransition(
                      duration: const Duration(milliseconds: 250),
                      child: _buildPaymentTile(payment, context),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? selectedValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return PopupMenuButton<String>(
      initialValue: selectedValue,
      onSelected: (value) {
        onChanged(value == selectedValue ? null : value);
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: null,
          child: Text('All'),
        ),
        ...options.map((option) {
          return PopupMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }),
      ],
      child: FilterChip(
        label: Text('$label: ${selectedValue ?? 'All'}'),
        onSelected: (selected) {},
        backgroundColor:
            selectedValue != null ? Colors.blue.shade100 : Colors.grey.shade100,
      ),
    );
  }

  Widget _buildPaymentTile(PaymentModel payment, BuildContext context) {
    final statusColor = _getStatusColor(payment.status);
    final methodText = _getPaymentMethodText(payment.paymentMethod);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ModernCard(
        isFloating: true,
        onTap: () => _showPaymentDetails(payment, context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Status Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withOpacity(0.2),
                ),
                child: Center(
                  child: Icon(
                    _getStatusIcon(payment.status),
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Payment Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.invoiceReference,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      methodText,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm')
                          .format(payment.createdAt),
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Amount & Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    payment.formattedAmount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      payment.statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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

  void _showPaymentDetails(PaymentModel payment, BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Amount
              _buildDetailRow('Amount', payment.formattedAmount),
              _buildDetailRow('Invoice', payment.invoiceReference),
              _buildDetailRow(
                  'Method', _getPaymentMethodText(payment.paymentMethod)),
              _buildDetailRow('Currency', payment.currency),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Status Section
              Text('Status', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(payment.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(payment.status),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (payment.isOverdue)
                      Text(
                        '⚠️ Overdue by ${payment.daysUntilDue.abs()} days',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    if (payment.completedAt != null)
                      Text(
                        'Completed: ${DateFormat('MMM dd, yyyy').format(payment.completedAt!)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Dates
              if (payment.dueDate.isAfter(DateTime.now()))
                _buildDetailRow(
                  'Due Date',
                  DateFormat('MMM dd, yyyy').format(payment.dueDate),
                ),

              if (payment.lateFeeAmount != null && payment.lateFeeAmount! > 0)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚠️ Late Fee Applied',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        payment.formattedAmount,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Action Buttons
              if (payment.isPending)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showRefundDialog(payment);
                    },
                    icon: const Icon(Icons.undo),
                    label: const Text('Request Refund'),
                  ),
                ),

              if (payment.isDisputed)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dispute details view coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.help_outline),
                      label: const Text('View Dispute'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRefundDialog(PaymentModel payment) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for refund',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              // Trigger refund
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refund request submitted')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'PROCESSING':
      case 'INITIATED':
      case 'PENDING':
        return Colors.blue;
      case 'FAILED':
        return Colors.red;
      case 'REFUNDED':
        return Colors.purple;
      case 'DISPUTED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'COMPLETED':
        return Icons.check_circle;
      case 'PROCESSING':
      case 'INITIATED':
      case 'PENDING':
        return Icons.schedule;
      case 'FAILED':
        return Icons.error;
      case 'REFUNDED':
        return Icons.undo;
      case 'DISPUTED':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'FULL_UPFRONT':
        return 'Full Payment Upfront';
      case 'PARTIAL_DEPOSIT':
        return 'Deposit (30%)';
      case 'ON_DELIVERY':
        return 'Pay on Delivery';
      case 'INSTALLMENT':
        return 'Installment Plan';
      case 'ESCROW':
        return 'Escrow Fund Hold';
      default:
        return method;
    }
  }
}
