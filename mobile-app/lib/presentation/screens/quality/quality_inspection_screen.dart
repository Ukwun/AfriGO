import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/quality_model.dart';
import '../providers/quality_provider.dart';

class QualityInspectionScreen extends ConsumerStatefulWidget {
  final String lotId;

  const QualityInspectionScreen({
    Key? key,
    required this.lotId,
  }) : super(key: key);

  @override
  ConsumerState<QualityInspectionScreen> createState() =>
      _QualityInspectionScreenState();
}

class _QualityInspectionScreenState
    extends ConsumerState<QualityInspectionScreen> {
  int currentStep = 0;
  String? selectedInspectionType;
  String? selectedGrade;
  int defectPercentage = 0;
  final ImagePicker _picker = ImagePicker();
  List<File> selectedPhotos = [];

  final List<String> inspectionTypes = [
    'Visual',
    'Lab Test',
    'AI Analysis',
    'Manual'
  ];
  final List<String> grades = ['A', 'B', 'C', 'Rejected'];
  final List<String> defects = [
    'Damaged',
    'Moldy',
    'Discolored',
    'Foreign Matter',
    'Insect Damaged',
    'Fermentation Issues',
  ];
  Set<String> selectedDefects = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Inspection'),
      ),
      body: Stepper(
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 2) {
            setState(() => currentStep += 1);
          } else {
            _submitInspection();
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() => currentStep -= 1);
          }
        },
        steps: [
          // Step 1: Inspection Type
          Step(
            title: const Text('Inspection Type'),
            isActive: currentStep >= 0,
            content: Column(
              children: [
                const Text(
                  'Select inspection method',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: inspectionTypes.map((type) {
                    final isSelected = selectedInspectionType == type;
                    return FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() =>
                            selectedInspectionType = selected ? type : null);
                      },
                      backgroundColor:
                          isSelected ? Colors.blue : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Step 2: Visual Inspection
          Step(
            title: const Text('Visual Assessment'),
            isActive: currentStep >= 1,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Grade Assessment',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: grades.map((grade) {
                    final isSelected = selectedGrade == grade;
                    return FilterChip(
                      label: Text('Grade $grade'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => selectedGrade = selected ? grade : null);
                      },
                      backgroundColor:
                          isSelected ? Colors.blue : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text('Defect Percentage',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: defectPercentage.toDouble(),
                  min: 0,
                  max: 100,
                  onChanged: (value) {
                    setState(() => defectPercentage = value.toInt());
                  },
                  label: '$defectPercentage%',
                ),
                Text(
                  'Estimated defects: $defectPercentage%',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Text('Detected Defects',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: defects.map((defect) {
                    final isSelected = selectedDefects.contains(defect);
                    return FilterChip(
                      label: Text(defect),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedDefects.add(defect);
                          } else {
                            selectedDefects.remove(defect);
                          }
                        });
                      },
                      backgroundColor: isSelected
                          ? Colors.red.shade100
                          : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.red.shade700 : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text('Inspection Photos',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Photos'),
                  onPressed: _pickPhotos,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: selectedPhotos
                      .map((photo) => Image.file(
                            photo,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

          // Step 3: Summary & Submit
          Step(
            title: const Text('Review & Submit'),
            isActive: currentStep >= 2,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryCard(
                  label: 'Inspection Type',
                  value: selectedInspectionType ?? 'Not selected',
                ),
                _SummaryCard(
                  label: 'Visual Grade',
                  value: selectedGrade ?? 'Not selected',
                ),
                _SummaryCard(
                  label: 'Defect Percentage',
                  value: '$defectPercentage%',
                ),
                _SummaryCard(
                  label: 'Detected Defects',
                  value: selectedDefects.isEmpty
                      ? 'None'
                      : selectedDefects.join(', '),
                ),
                _SummaryCard(
                  label: 'Photos Attached',
                  value: '${selectedPhotos.length} photos',
                ),
                const SizedBox(height: 24),
                const Text(
                  'Review all information and submit for processing. Quality team will review and provide final certification.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhotos() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        selectedPhotos = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  void _submitInspection() async {
    if (selectedInspectionType == null || selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    try {
      final request = CreateQualityInspectionRequest(
        lotId: widget.lotId,
        inspectionType: selectedInspectionType!.toLowerCase(),
      );

      final service = ref.read(qualityServiceProvider);
      final inspection = await service.createInspection(request);

      // Submit visual inspection data
      final visualRequest = SubmitVisualInspectionRequest(
        inspectionId: inspection.id,
        visualGrade: selectedGrade!,
        visualDefectPercentage: defectPercentage,
        visualDefectsFound: selectedDefects.toList(),
        inspectionPhotos: [], // In production: upload photos to cloud storage first
      );

      await service.submitVisualInspection(visualRequest);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inspection submitted successfully')),
      );

      Navigator.of(context).pop(inspection);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
