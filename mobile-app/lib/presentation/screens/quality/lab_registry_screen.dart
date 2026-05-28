import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/quality_model.dart';
import '../providers/quality_provider.dart';

class LabRegistryScreen extends ConsumerStatefulWidget {
  const LabRegistryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LabRegistryScreen> createState() => _LabRegistryScreenState();
}

class _LabRegistryScreenState extends ConsumerState<LabRegistryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _labNameController;
  late TextEditingController _countryController;
  late TextEditingController _certNumberController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;

  List<String> _selectedCapabilities = [];
  final List<String> _availableCapabilities = [
    'Moisture Analysis',
    'Aflatoxin Testing',
    'Foreign Matter Detection',
    'Bacterial Count',
    'pH Analysis',
    'Insect Detection',
    'Mycotoxin Analysis',
    'Heavy Metals',
    'Pesticide Residues',
    'Color Grading',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _labNameController = TextEditingController();
    _countryController = TextEditingController();
    _certNumberController = TextEditingController();
    _contactController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _labNameController.dispose();
    _countryController.dispose();
    _certNumberController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labsAsync = ref.watch(availableLabsProvider(''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Registry'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Available Labs'),
            Tab(text: 'Register Lab'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Available Labs Tab
          labsAsync.when(
            data: (labs) => _buildLabsList(context, labs),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
          ),

          // Register Lab Tab
          _buildRegistrationForm(context),
        ],
      ),
    );
  }

  Widget _buildLabsList(
      BuildContext context, List<LabCertificationModel> labs) {
    if (labs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.science_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No labs registered yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: labs.length,
      itemBuilder: (context, index) {
        final lab = labs[index];
        final isExpired = lab.expiryDate.isBefore(DateTime.now());

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lab.labName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lab.labCode,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isExpired
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isExpired ? 'EXPIRED' : 'ACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isExpired
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoRow('Country', lab.country),
                _InfoRow('Certification', lab.certificationNumber),
                _InfoRow('Expires',
                    DateFormat('MMM d, yyyy').format(lab.expiryDate)),
                _InfoRow('Accuracy', '${lab.averageAccuracy}%'),
                const SizedBox(height: 12),
                const Text(
                  'Testing Capabilities:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: lab.testingCapabilities
                      .map((cap) => Chip(
                            label: Text(cap),
                            backgroundColor: Colors.blue.shade50,
                            labelStyle: const TextStyle(fontSize: 10),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegistrationForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lab Registration Form',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Lab Name
          TextField(
            controller: _labNameController,
            decoration: InputDecoration(
              labelText: 'Lab Name *',
              hintText: 'Enter laboratory name',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 16),

          // Country
          TextField(
            controller: _countryController,
            decoration: InputDecoration(
              labelText: 'Country *',
              hintText: 'Ghana',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 16),

          // Certification Number
          TextField(
            controller: _certNumberController,
            decoration: InputDecoration(
              labelText: 'Certification Number *',
              hintText: 'e.g., ISO-17025-2024',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 16),

          // Contact Name
          TextField(
            controller: _contactController,
            decoration: InputDecoration(
              labelText: 'Contact Person *',
              hintText: 'Full name',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 16),

          // Email
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email *',
              hintText: 'lab@example.com',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 24),

          // Testing Capabilities
          const Text(
            'Testing Capabilities *',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableCapabilities.map((cap) {
              final isSelected = _selectedCapabilities.contains(cap);
              return FilterChip(
                label: Text(cap),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCapabilities.add(cap);
                    } else {
                      _selectedCapabilities.remove(cap);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedCapabilities.isEmpty
                  ? null
                  : () => _submitRegistration(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: const Text(
                'Submit Registration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _submitRegistration(BuildContext context) {
    if (_labNameController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _certNumberController.text.isEmpty ||
        _contactController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedCapabilities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    // Submit registration
    final body = CreateLabCertificationDTO(
      labName: _labNameController.text,
      labCode: _labNameController.text.replaceAll(' ', '_').toUpperCase(),
      country: _countryController.text,
      certificationNumber: _certNumberController.text,
      accreditationBody: 'ISO 17025',
      testingCapabilities: _selectedCapabilities,
      contactPerson: _contactController.text,
      email: _emailController.text,
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lab registration submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form
    _labNameController.clear();
    _countryController.clear();
    _certNumberController.clear();
    _contactController.clear();
    _emailController.clear();
    _selectedCapabilities.clear();

    setState(() {});

    // Switch to labs list
    _tabController.animateTo(0);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
