import 'package:flutter/material.dart';
import 'dart:typed_data';

/// Signature Preview Widget
/// Shows preview of captured signature before final submission
/// Visual confirmation that signature was captured

class SignaturePreviewWidget extends StatelessWidget {
  final Uint8List? signatureImage;
  final bool isCapturing;

  const SignaturePreviewWidget({
    Key? key,
    this.signatureImage,
    this.isCapturing = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (signatureImage == null) {
      return Container(
        key: const Key('signature_preview_empty'),
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_note,
                size: 32,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'Signature preview will appear here',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      key: const Key('signature_preview'),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.green.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.memory(
        signatureImage!,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Signature Status Indicator
/// Shows whether contract is signed or awaiting signature

class SignatureStatusIndicator extends StatelessWidget {
  final bool isSigned;
  final String? signerName;
  final DateTime? signedAt;

  const SignatureStatusIndicator({
    Key? key,
    required this.isSigned,
    this.signerName,
    this.signedAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isSigned) {
      return Container(
        key: const Key('signature_status_unsigned'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          border: Border.all(color: Colors.orange.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.pending, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Awaiting Signature',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Please sign this contract to proceed',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      key: const Key('signature_status_signed'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signed by $signerName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (signedAt != null)
                  Text(
                    'Signed: ${signedAt!.toUtc()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Contract Term Card
/// Displays individual contract term in formatted card

class ContractTermCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ContractTermCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Both Parties Sync Indicator
/// Shows real-time synchronization status
/// Verifies both parties see identical contract

class BothPartiesSyncIndicator extends StatelessWidget {
  final bool isSynced;
  final DateTime? lastSyncTime;

  const BothPartiesSyncIndicator({
    Key? key,
    required this.isSynced,
    this.lastSyncTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('both_parties_sync_indicator'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSynced ? Colors.green.shade50 : Colors.blue.shade50,
        border: Border.all(
          color: isSynced ? Colors.green.shade300 : Colors.blue.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isSynced ? Icons.sync : Icons.sync_disabled,
            color: isSynced ? Colors.green.shade700 : Colors.blue.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSynced
                      ? '✅ Both Parties Synchronized'
                      : '🔄 Synchronizing...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isSynced ? Colors.green.shade700 : Colors.blue.shade700,
                  ),
                ),
                if (lastSyncTime != null)
                  Text(
                    'Last sync: ${lastSyncTime!.difference(DateTime.now()).inSeconds}s ago',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          if (!isSynced)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.blue.shade700),
              ),
            ),
        ],
      ),
    );
  }
}

/// Immutability Guarantee Widget
/// Shows that contract is immutable and permanent

class ImmutabilityGuaranteeWidget extends StatelessWidget {
  final String contractId;

  const ImmutabilityGuaranteeWidget({
    Key? key,
    required this.contractId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('immutability_guarantee'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        border: Border.all(color: Colors.purple.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock, color: Colors.purple.shade700),
              const SizedBox(width: 8),
              Text(
                'Immutable & Permanent',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '✓ This contract cannot be modified\n'
            '✓ Signatures cannot be deleted\n'
            '✓ Timestamps are tamper-proof\n'
            '✓ Full audit trail maintained\n'
            '✓ 7-year compliance record',
            style: TextStyle(
              fontSize: 11,
              color: Colors.purple.shade700,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            'Contract ID: $contractId',
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Real-Time Event Badge
/// Shows real-time event happening (e.g., "Other party signing...")

class RealTimeEventBadge extends StatefulWidget {
  final String eventType;
  final String eventMessage;
  final bool isVisible;

  const RealTimeEventBadge({
    Key? key,
    required this.eventType,
    required this.eventMessage,
    required this.isVisible,
  }) : super(key: key);

  @override
  State<RealTimeEventBadge> createState() => _RealTimeEventBadgeState();
}

class _RealTimeEventBadgeState extends State<RealTimeEventBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      key: const Key('real_time_event_badge'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween(begin: 0.8, end: 1.0).animate(_controller),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.eventMessage,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
