import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../widgets/modern_components.dart';
import '../../../data/services/api_client.dart';

class QualityInspectionScreen extends StatefulWidget {
  const QualityInspectionScreen({super.key});
  @override
  State<QualityInspectionScreen> createState() =>
      _QualityInspectionScreenState();
}

class _QualityInspectionScreenState extends State<QualityInspectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final int _currentStep = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _inspectionItems = [
    {'name': 'Color', 'status': 'pending', 'notes': ''},
    {'name': 'Texture', 'status': 'pending', 'notes': ''},
    {'name': 'Moisture Content', 'status': 'pending', 'notes': ''},
    {'name': 'Defects', 'status': 'pending', 'notes': ''},
    {'name': 'Weight', 'status': 'pending', 'notes': ''},
  ];

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

  Future<void> _submitInspection() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (_inspectionItems.any((item) => item['status'] == 'pending')) {
        throw Exception('Complete every inspection item before submitting');
      }
      await ApiClient().post('/quality_inspections', body: {
        'items': _inspectionItems,
        'status': _inspectionItems.any((item) => item['status'] == 'fail')
            ? 'failed'
            : 'passed',
        'inspectedAt': DateTime.now().toUtc().toIso8601String(),
      });
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AfriBorderRadius.xl),
          ),
          title: Text(
            'Inspection Complete! ✅',
            style: AfrigoTypography.soraHeading5,
          ),
          content: Text(
            'Quality inspection report has been submitted.',
            style: AfrigoTypography.interBody1,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('View Report'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to submit inspection: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _markAsPass(int index) {
    setState(() {
      _inspectionItems[index]['status'] = 'pass';
    });
  }

  void _markAsFail(int index) {
    setState(() {
      _inspectionItems[index]['status'] = 'fail';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AfrigoColors.bgLight,
      appBar: AppBar(
        title: Text(
          'Quality Inspection',
          style: AfrigoTypography.soraHeading5,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AfrigoSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Summary
                Container(
                  padding: const EdgeInsets.all(AfrigoSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AfriBorderRadius.lg),
                    border: Border.all(
                      color: AfrigoColors.borderLight,
                    ),
                    boxShadow: AfrigoElevation.shadow1,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inspection Progress',
                                style: AfrigoTypography.interBody1Semi,
                              ),
                              const SizedBox(
                                height: AfrigoSpacing.md,
                              ),
                              Text(
                                '${_inspectionItems.where((e) => e['status'] != 'pending').length}/${_inspectionItems.length} completed',
                                style: AfrigoTypography.soraHeading5.copyWith(
                                  color: AfrigoColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${((_inspectionItems.where((e) => e['status'] != 'pending').length / _inspectionItems.length) * 100).toStringAsFixed(0)}%',
                            style: AfrigoTypography.kpiLarge.copyWith(
                              color: AfrigoColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: AfrigoSpacing.lg,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AfriBorderRadius.full,
                        ),
                        child: LinearProgressIndicator(
                          value: _inspectionItems
                                  .where(
                                    (e) => e['status'] != 'pending',
                                  )
                                  .length /
                              _inspectionItems.length,
                          minHeight: 8,
                          backgroundColor: AfrigoColors.bgLightAlt,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AfrigoColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AfrigoSpacing.xxl),

                // Error Display
                if (_errorMessage != null) ...[
                  ModernErrorState(
                    title: 'Error',
                    message: _errorMessage!,
                    icon: Icons.error_outline,
                  ),
                  const SizedBox(height: AfrigoSpacing.lg),
                ],

                // Inspection Items
                Text(
                  'Inspection Checklist',
                  style: AfrigoTypography.soraHeading5,
                ),
                const SizedBox(height: AfrigoSpacing.lg),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _inspectionItems.length,
                  itemBuilder: (context, index) {
                    final item = _inspectionItems[index];
                    final status = item['status'];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AfrigoSpacing.lg,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: status == 'pass'
                                ? AfrigoColors.success
                                : status == 'fail'
                                    ? AfrigoColors.error
                                    : AfrigoColors.borderLight,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(
                            AfriBorderRadius.lg,
                          ),
                        ),
                        padding: const EdgeInsets.all(
                          AfrigoSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _buildStatusIcon(
                                      status,
                                    ),
                                    const SizedBox(
                                      width: AfrigoSpacing.md,
                                    ),
                                    Text(
                                      item['name'],
                                      style: AfrigoTypography.interBody1Semi,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (status == 'pending') ...[
                              const SizedBox(
                                height: AfrigoSpacing.lg,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _markAsPass(index),
                                      icon: const Icon(
                                        Icons.check,
                                      ),
                                      label: const Text(
                                        'Pass',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: AfrigoSpacing.md,
                                  ),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _markAsFail(index),
                                      icon: const Icon(
                                        Icons.close,
                                        color: AfrigoColors.error,
                                      ),
                                      label: const Text(
                                        'Fail',
                                        style: TextStyle(
                                          color: AfrigoColors.error,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: AfrigoSpacing.xxl,
                ),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ModernButton(
                    onPressed: _submitInspection,
                    isLoading: _isSubmitting,
                    child: const Text(
                      'Submit Inspection Report',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    if (status == 'pass') {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AfrigoColors.success,
          borderRadius: BorderRadius.circular(
            AfriBorderRadius.full,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 14,
          ),
        ),
      );
    } else if (status == 'fail') {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AfrigoColors.error,
          borderRadius: BorderRadius.circular(
            AfriBorderRadius.full,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: 14,
          ),
        ),
      );
    } else {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AfrigoColors.neutral300,
          borderRadius: BorderRadius.circular(
            AfriBorderRadius.full,
          ),
        ),
      );
    }
  }
}
