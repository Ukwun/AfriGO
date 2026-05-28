import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';

/// Contract Display Widget
/// Shows full contract content with all terms
/// Auto-generated from trade agreement (not template)
/// Both parties see identical content simultaneously

class ContractDisplayWidget extends ConsumerWidget {
  final String tradeId;
  final String contractContent;

  const ContractDisplayWidget({
    Key? key,
    required this.tradeId,
    required this.contractContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contract header
              _buildContractHeader(context),
              const SizedBox(height: 24),

              // Contract content
              Text(
                contractContent,
                key: const Key('contract_content_text'),
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              // Footer with important info
              _buildContractFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContractHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMMERCIAL TRADING CONTRACT',
                  key: const Key('contract_title'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Auto-Generated from Trade Agreement',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Trade ID: $tradeId',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade700,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildContractFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Important: This contract is auto-generated from actual trade terms.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '✓ Contract is binding for all parties\n'
            '✓ Digital signatures are legally valid\n'
            '✓ Timestamps are cryptographic and tamper-proof\n'
            '✓ Contract is immutable and permanent',
            style: TextStyle(
              fontSize: 10,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Signature Verification Widget
/// Shows cryptographic verification status and timestamp
/// Proves signature authenticity and immutability

class SignatureVerificationWidget extends ConsumerWidget {
  final String signatureHash;
  final DateTime timestamp;

  const SignatureVerificationWidget({
    Key? key,
    required this.signatureHash,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      key: const Key('signature_verification_widget'),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header with check icon
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Digital Signature Verified',
                  key: const Key('signature_verified_text'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Signature details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verification status
                _buildVerificationRow(
                  context,
                  icon: Icons.check_circle,
                  label: 'Status',
                  value: 'VERIFIED (Cryptographically Signed)',
                  valueColor: Colors.green,
                ),
                const SizedBox(height: 12),

                // Timestamp
                _buildVerificationRow(
                  context,
                  icon: Icons.schedule,
                  label: 'Timestamp (UTC)',
                  value: timestamp.toUtc().toString(),
                  valueColor: Colors.blue,
                  key: const Key('signature_timestamp'),
                ),
                const SizedBox(height: 12),

                // Signature hash
                _buildHashRow(context),
                const SizedBox(height: 12),

                // Tamper-proof indicator
                _buildTamperProofIndicator(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = Colors.black,
    Key? key,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                key: key,
                style: TextStyle(
                  fontSize: 13,
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHashRow(BuildContext context) {
    final displayHash =
        '${signatureHash.substring(0, 16)}...${signatureHash.substring(signatureHash.length - 8)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.fingerprint,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signature Hash (SHA-256)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    displayHash,
                    key: const Key('signature_hash_display'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Full hash: $signatureHash',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade500,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTamperProofIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security,
                size: 16,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Tamper-Proof & Immutable',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'This signature cannot be modified, deleted, or forged. '
            'The cryptographic hash ensures authenticity. '
            'The UTC timestamp proves when it was signed. '
            'The immutable ledger provides permanent records for compliance.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Signature Preview Widget
/// Shows preview of captured signature
/// Used before final submission

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
