import 'package:flutter/material.dart';

/// Trade Status Badge Widget
/// Displays trade status with color coding and icon
class TradeStatusBadge extends StatelessWidget {
  final String status;
  final double? fraudScore;
  final bool showFraudRisk;

  const TradeStatusBadge({
    Key? key,
    required this.status,
    this.fraudScore,
    this.showFraudRisk = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);

    return Tooltip(
      message: _getStatusDescription(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
            if (showFraudRisk && fraudScore != null && fraudScore! > 70) ...[
              const SizedBox(width: 8),
              const Icon(Icons.warning, size: 14, color: Colors.orange),
            ],
          ],
        ),
      ),
    );
  }

  /// Get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'OPEN':
        return Colors.blue;
      case 'NEGOTIATING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.teal;
      case 'CANCELLED':
        return Colors.red;
      case 'PENDING':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Get status icon
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'OPEN':
        return Icons.mail_outline;
      case 'NEGOTIATING':
        return Icons.compare_arrows;
      case 'ACCEPTED':
        return Icons.check_circle;
      case 'COMPLETED':
        return Icons.task_alt;
      case 'CANCELLED':
        return Icons.cancel;
      case 'PENDING':
        return Icons.hourglass_empty;
      default:
        return Icons.info;
    }
  }

  /// Get status description
  String _getStatusDescription(String status) {
    switch (status) {
      case 'OPEN':
        return 'Waiting for seller quotes';
      case 'NEGOTIATING':
        return 'Offers and counter-offers in progress';
      case 'ACCEPTED':
        return 'Quote accepted, proceeding to payment';
      case 'COMPLETED':
        return 'Trade completed successfully';
      case 'CANCELLED':
        return 'Trade cancelled';
      case 'PENDING':
        return 'Trade pending';
      default:
        return status;
    }
  }
}
