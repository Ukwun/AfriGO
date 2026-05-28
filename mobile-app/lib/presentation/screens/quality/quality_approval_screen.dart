import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/quality_model.dart';
import '../providers/quality_provider.dart';

class QualityApprovalScreen extends ConsumerStatefulWidget {
  final String inspectionId;

  const QualityApprovalScreen({
    Key? key,
    required this.inspectionId,
  }) : super(key: key);

  @override
  ConsumerState<QualityApprovalScreen> createState() =>
      _QualityApprovalScreenState();
}

class _QualityApprovalScreenState extends ConsumerState<QualityApprovalScreen> {
  late TextEditingController _notesController;
  String? _overrideGrade;
  bool _isApproving = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inspectionAsync =
        ref.watch(qualityInspectionProvider(widget.inspectionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('QA Review & Approval'),
      ),
      body: inspectionAsync.when(
        data: (inspection) => _buildApprovalForm(context, inspection),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildApprovalForm(
      BuildContext context, QualityInspectionModel inspection) {
    final gradeColor = _getGradeColor(inspection.finalGrade);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inspection Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inspection Summary',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _SummaryRow('Inspection ID', inspection.id.substring(0, 8)),
                    _SummaryRow(
                        'Type', inspection.inspectionType.toUpperCase()),
                    _SummaryRow('Status', inspection.status.toUpperCase()),
                    _SummaryRow(
                        'Inspector', inspection.inspectorName ?? 'System'),
                    _SummaryRow(
                      'Submitted',
                      DateFormat('MMM d, yyyy hh:mm')
                          .format(inspection.createdAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Inspection Results Display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inspection Results',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Current Grade
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: gradeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: gradeColor),
                      ),
                      child: Column(
                        children: [
                          const Text('Tentative Grade'),
                          const SizedBox(height: 8),
                          Text(
                            inspection.finalGrade ?? '—',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: gradeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Visual Results
                    if (inspection.visualGrade != null)
                      _ResultSection(
                        title: 'Visual Assessment',
                        items: [
                          ('Grade', inspection.visualGrade ?? '—'),
                          ('Defects', '${inspection.visualDefectPercentage}%'),
                          (
                            'Detected Types',
                            (inspection.visualDefectsFound ?? []).join(', ') ??
                                'None'
                          ),
                        ],
                      ),

                    // Lab Test Results
                    if (inspection.moistureContent != null)
                      _ResultSection(
                        title: 'Lab Test Results',
                        items: [
                          ('Moisture', '${inspection.moistureContent}%'),
                          ('Aflatoxin', '${inspection.afflatoxinLevel} ppb'),
                          (
                            'Foreign Matter',
                            '${inspection.foreignMatterPercentage}%'
                          ),
                        ],
                      ),

                    // AI Analysis
                    if (inspection.aiPredictedGrade != null)
                      _ResultSection(
                        title: 'AI Analysis',
                        items: [
                          ('Predicted', inspection.aiPredictedGrade ?? '—'),
                          (
                            'Confidence',
                            '${(inspection.aiConfidenceScore ?? 0).toStringAsFixed(1)}%'
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Approval Options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Approval Actions',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Grade Override
                    const Text(
                      'Manual Grade Override (Optional)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: ['A', 'B', 'C', 'Rejected']
                          .map((grade) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _overrideGrade = grade;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _overrideGrade == grade
                                        ? _getGradeColor(grade)
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      grade,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _overrideGrade == grade
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),

                    // Approval Notes
                    const Text(
                      'Approval Notes',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Enter approval notes (e.g., grade overridden due to...)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isApproving ? null : () => _rejectInspection(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'REJECT',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isApproving ? null : () => _approveInspection(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green.shade600,
                    ),
                    child: const Text(
                      'APPROVE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _approveInspection(BuildContext context) {
    setState(() => _isApproving = true);

    final request = ApproveQualityInspectionDTO(
      approved: true,
      manualOverrideGrade: _overrideGrade,
      approvalNotes: _notesController.text,
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isApproving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inspection approved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    });
  }

  void _rejectInspection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Inspection?'),
        content: const Text(
          'Are you sure you want to reject this inspection? The lot will need to be re-inspected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              setState(() => _isApproving = true);

              final request = ApproveQualityInspectionDTO(
                approved: false,
                approvalNotes: _notesController.text,
              );

              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) {
                  setState(() => _isApproving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inspection rejected.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  Navigator.pop(context);
                }
              });
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final String title;
  final List<(String, String)> items;

  const _ResultSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.$1,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(item.$2,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
