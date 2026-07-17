import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/lots_model.dart';
import '../../providers/lots_provider.dart';

class CreateLotScreen extends ConsumerStatefulWidget {
  const CreateLotScreen({super.key});

  @override
  ConsumerState<CreateLotScreen> createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends ConsumerState<CreateLotScreen> {
  int currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Basic Info
  late TextEditingController productNameController;
  late TextEditingController categoryController;
  late TextEditingController descriptionController;

  // Step 2: Pricing & Quantity
  late TextEditingController quantityController;
  late TextEditingController quantityUnitController;
  late TextEditingController pricePerUnitController;

  // Step 3: Origin & Quality
  late TextEditingController originCountryController;
  late TextEditingController originRegionController;
  late TextEditingController originLocationController;
  late TextEditingController pickupLocationController;
  late TextEditingController gradeLevelController;
  late TextEditingController moistureContentController;
  late TextEditingController harvestDateController;

  List<String> selectedImages = [];

  @override
  void initState() {
    super.initState();
    productNameController = TextEditingController();
    categoryController = TextEditingController();
    descriptionController = TextEditingController();
    quantityController = TextEditingController();
    quantityUnitController = TextEditingController(text: 'kg');
    pricePerUnitController = TextEditingController();
    originCountryController = TextEditingController();
    originRegionController = TextEditingController();
    originLocationController = TextEditingController();
    pickupLocationController = TextEditingController();
    gradeLevelController = TextEditingController(text: 'B');
    moistureContentController = TextEditingController();
    harvestDateController = TextEditingController();
  }

  @override
  void dispose() {
    productNameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    quantityUnitController.dispose();
    pricePerUnitController.dispose();
    originCountryController.dispose();
    originRegionController.dispose();
    originLocationController.dispose();
    pickupLocationController.dispose();
    gradeLevelController.dispose();
    moistureContentController.dispose();
    harvestDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImages.add(pickedFile.path);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final request = CreateLotRequest(
        productName: productNameController.text,
        category: categoryController.text,
        quantity: double.parse(quantityController.text),
        quantityUnit: quantityUnitController.text,
        pricePerUnit: double.parse(pricePerUnitController.text),
        description: descriptionController.text,
        images: selectedImages,
        originCountry: originCountryController.text,
        originRegion: originRegionController.text.isNotEmpty
            ? originRegionController.text
            : null,
        originLocation: originLocationController.text.isNotEmpty
            ? originLocationController.text
            : null,
        pickupLocation: pickupLocationController.text,
        latitude: 0.0, // Get from GPS
        longitude: 0.0, // Get from GPS
        gradeLevel: gradeLevelController.text,
        harvestDate: harvestDateController.text.isNotEmpty
            ? DateTime.parse(harvestDateController.text)
            : null,
        moistureContent: moistureContentController.text.isNotEmpty
            ? double.parse(moistureContentController.text)
            : null,
        afflatoxinLevel: null,
        foreignMatterPercentage: null,
        certifications: null,
        certifiedOrganic: false,
        fairTradeCertified: false,
        productionDate: null,
        expiryDate: null,
      );

      try {
        final service = ref.read(lotsServiceProvider);
        final createdLot = await service.createLot(request);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Lot created successfully! Now publish it to marketplace.')),
        );

        Navigator.of(context)
            .pushReplacementNamed('/lot-detail', arguments: createdLot.id);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Listing'),
      ),
      body: Stepper(
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 2) {
            setState(() => currentStep += 1);
          } else {
            _submitForm();
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() => currentStep -= 1);
          }
        },
        steps: [
          // Step 1: Basic Info
          Step(
            title: const Text('Product Information'),
            isActive: currentStep >= 0,
            content: Column(
              children: [
                TextFormField(
                  controller: productNameController,
                  decoration: const InputDecoration(
                    label: Text('Product Name'),
                    hintText: 'e.g., Cocoa Beans',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: categoryController.text.isEmpty
                      ? null
                      : categoryController.text,
                  decoration: const InputDecoration(label: Text('Category')),
                  items: ['Cocoa', 'Coffee', 'Cashew', 'Grains', 'Vegetables']
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) => categoryController.text = value ?? '',
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    label: Text('Description'),
                    hintText: 'Describe your product...',
                  ),
                  maxLines: 5,
                  validator: (value) => value?.length ?? 0 < 10
                      ? '10+ characters required'
                      : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Images'),
                  onPressed: _pickImage,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: selectedImages
                      .map((img) => Image.file(
                            File(img),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          // Step 2: Pricing & Quantity
          Step(
            title: const Text('Pricing & Quantity'),
            isActive: currentStep >= 1,
            content: Column(
              children: [
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(label: Text('Quantity')),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: quantityUnitController,
                  decoration: const InputDecoration(label: Text('Unit')),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: pricePerUnitController,
                  decoration:
                      const InputDecoration(label: Text('Price per Unit')),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),
          ),
          // Step 3: Origin & Quality
          Step(
            title: const Text('Origin & Quality'),
            isActive: currentStep >= 2,
            content: Column(
              children: [
                TextFormField(
                  controller: originCountryController,
                  decoration:
                      const InputDecoration(label: Text('Origin Country')),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: originRegionController,
                  decoration:
                      const InputDecoration(label: Text('Region (Optional)')),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: pickupLocationController,
                  decoration:
                      const InputDecoration(label: Text('Pickup Location')),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: gradeLevelController.text,
                  decoration: const InputDecoration(label: Text('Grade Level')),
                  items: ['A', 'B', 'C']
                      .map((grade) => DropdownMenuItem(
                          value: grade, child: Text('Grade $grade')))
                      .toList(),
                  onChanged: (value) =>
                      gradeLevelController.text = value ?? 'B',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: harvestDateController,
                  decoration: const InputDecoration(
                    label: Text('Harvest Date (Optional)'),
                    hintText: 'YYYY-MM-DD',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: moistureContentController,
                  decoration: const InputDecoration(
                    label: Text('Moisture Content % (Optional)'),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
