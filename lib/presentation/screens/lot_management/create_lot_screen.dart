import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../config/constants.dart';
import '../../../data/services/lot_service.dart';

/// Create Lot Screen (for Sellers)
/// Form to create new product lot with photos
class CreateLotScreen extends ConsumerStatefulWidget {
  final String? lotId; // If provided, edit mode

  const CreateLotScreen({Key? key, this.lotId}) : super(key: key);

  @override
  ConsumerState<CreateLotScreen> createState() => _CreateLotScreenState();
}

class _CreateLotScreenState extends ConsumerState<CreateLotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _qualityGradeController = TextEditingController();
  final _harvestDateController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<File> _selectedPhotos = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _productTypeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _qualityGradeController.dispose();
    _harvestDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lotId == null ? 'Create Lot' : 'Edit Lot'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product type
              const Text(
                'Product Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Select product type',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: Constants.productTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  _productTypeController.text = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select product type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Quantity
              const Text(
                'Quantity (kg)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Enter quantity in kilograms',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Price per kg
              const Text(
                'Price per kg (\$)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Enter price per kilogram',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Quality grade
              const Text(
                'Quality Grade',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Select quality grade',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: Constants.qualityGrades.map((grade) {
                  return DropdownMenuItem(value: grade, child: Text(grade));
                }).toList(),
                onChanged: (value) {
                  _qualityGradeController.text = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select quality grade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Harvest date
              const Text(
                'Harvest Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _harvestDateController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Select harvest date',
                  suffixIcon: const Icon(Icons.calendar_today),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _harvestDateController.text = date.toString().split(' ')[0];
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select harvest date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description
              const Text(
                'Description (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText:
                      'Describe your product (origin, special notes, etc)',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Photo upload
              const Text(
                'Product Photos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload at least 1 photo (max 5)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              _buildPhotoUploadArea(),
              const SizedBox(height: 12),
              if (_selectedPhotos.isNotEmpty)
                _buildPhotoPreview()
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: const Center(
                    child: Text(
                      'No photos selected',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.lotId == null ? 'Create Lot' : 'Save Changes',
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Photo upload area
  Widget _buildPhotoUploadArea() {
    return GestureDetector(
      onTap: _selectedPhotos.length < 5 ? () => _pickPhoto() : null,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedPhotos.length < 5
                ? Colors.green
                : Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.green[50],
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: _selectedPhotos.length < 5 ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to add photo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _selectedPhotos.length < 5 ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_selectedPhotos.length} / 5 photos',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Photo preview grid
  Widget _buildPhotoPreview() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        spacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _selectedPhotos.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(_selectedPhotos[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPhotos.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Pick photo from gallery/camera
  Future<void> _pickPhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedPhotos.add(File(image.path));
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (image != null) {
                    setState(() {
                      _selectedPhotos.add(File(image.path));
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Submit form - REAL backend call
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload at least one photo'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final lotService = ref.read(lotServiceProvider);

      // FUNCTIONAL [SUBMIT] button - REAL backend call
      // This triggers:
      // 1. Photo upload to cloud storage (generates URLs)
      // 2. AI quality analysis on photos
      // 3. Lot creation with immutable ledger
      // 4. QR code generation (cryptographic)
      // 5. Activity logging
      // 6. WebSocket broadcast (LOT_CREATED event)
      // 7. Buyers notified if matches their saved criteria
      final lot = await lotService.createLot(
        productType: _productTypeController.text,
        quantity: double.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        qualityGrade: _qualityGradeController.text,
        harvestDate: DateTime.parse(_harvestDateController.text),
        description: _descriptionController.text,
        photos: _selectedPhotos,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lot created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to lot detail
        context.go('/lot-detail/${lot.id}');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
