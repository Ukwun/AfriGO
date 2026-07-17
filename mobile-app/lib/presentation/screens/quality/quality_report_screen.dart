import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/quality_model.dart';
import '../providers/quality_provider.dart';

class QualityReportScreen extends ConsumerWidget {
  final String inspectionId;

  const QualityReportScreen({
    super.key,
    required this.inspectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspectionAsync = ref.watch(qualityInspectionProvider(inspectionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading report...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: inspectionAsync.when(
        data: (inspection) => _buildReportContent(context, inspection),
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

  Widget _buildReportContent(
      BuildContext context, QualityInspectionModel inspection) {
    final gradeColor = _getGradeColor(inspection.finalGrade);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Grade
            Container(
              decoration: BoxDecoration(
                color: gradeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: gradeColor, width: 2),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Final Grade',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inspection.finalGrade ?? '—',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: inspection.isApproved
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      inspection.isApproved ? 'APPROVED ✓' : 'PENDING APPROVAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: inspection.isApproved
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Inspection Details
            _Section(
              title: 'Inspection Details',
              children: [
                _DetailRow('Inspection ID', inspection.id.substring(0, 8)),
                _DetailRow('Type', inspection.inspectionType.toUpperCase()),
                _DetailRow('Status', inspection.status.toUpperCase()),
                _DetailRow(
                    'Inspector', inspection.inspectorName ?? 'Automated'),
                _DetailRow(
                  'Date',
                  DateFormat('MMM d, yyyy').format(inspection.createdAt),
                ),
                if (inspection.completedAt != null)
                  _DetailRow(
                    'Completed',
                    DateFormat('MMM d, yyyy hh:mm')
                        .format(inspection.completedAt!),
                  ),
              ],
            ),

            // Visual Inspection Results
            if (inspection.visualGrade != null)
              _Section(
                title: 'Visual Inspection Results',
                children: [
                  _DetailRow('Visual Grade', inspection.visualGrade!),
                  _DetailRow(
                      'Defect %', '${inspection.visualDefectPercentage ?? 0}%'),
                  if (inspection.visualDefectsFound != null &&
                      inspection.visualDefectsFound!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Detected Defects:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (inspection.visualDefectsFound ?? [])
                                .map((defect) => Chip(label: Text(defect)))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

            // Lab Test Results
            if (inspection.moistureContent != null ||
                inspection.afflatoxinLevel != null)
              _Section(
                title: 'Lab Test Results',
                children: [
                  if (inspection.labName != null)
                    _DetailRow('Laboratory', inspection.labName!),
                  if (inspection.moistureContent != null)
                    _DetailRow(
                        'Moisture Content', '${inspection.moistureContent}%'),
                  if (inspection.afflatoxinLevel != null)
                    _DetailRow(
                        'Aflatoxin Level', '${inspection.afflatoxinLevel} ppb'),
                  if (inspection.foreignMatterPercentage != null)
                    _DetailRow('Foreign Matter',
                        '${inspection.foreignMatterPercentage}%'),
                  if (inspection.pH != null)
                    _DetailRow('pH', inspection.pH.toString()),
                  if (inspection.bacterialCount != null)
                    _DetailRow('Bacterial Count', inspection.bacterialCount!),
                ],
              ),

            // AI Analysis Results
            if (inspection.aiPredictedGrade != null)
              _Section(
                title: 'AI Analysis Results',
                children: [
                  _DetailRow('Predicted Grade', inspection.aiPredictedGrade!),
                  _DetailRow(
                    'Confidence',
                    '${(inspection.aiConfidenceScore ?? 0).toStringAsFixed(1)}%',
                  ),
                ],
              ),

            // Approval Notes
            if (inspection.approvalNotes != null &&
                inspection.approvalNotes!.isNotEmpty)
              _Section(
                title: 'Approval Notes',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      inspection.approvalNotes!,
                      style: const TextStyle(color: Colors.grey, height: 1.5),
                    ),
                  ),
                ],
              ),

            // Certification Status
            if (inspection.isApproved)
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✓ Certified Product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This product has been quality certified and is approved for marketplace listing.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String? grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
