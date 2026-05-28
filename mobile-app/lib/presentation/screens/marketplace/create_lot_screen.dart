import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/lot_model.dart';
import '../../../services/api_service.dart';
import '../../../config/theme.dart';

final createLotFormProvider = StateProvider<Map<String, dynamic>>((ref) => {
      'productName': '',
      'quantity': '',
      'quantityUnit': 'kg',
      'pricePerUnit': '',
      'description': '',
      'images': <File>[],
      'pickupLocation': '',
      'latitude': 0.0,
      'longitude': 0.0,
      'category': '',
      'certifications': <String>[],
    });

final selectedImagesProvider = StateProvider<List<File>>((ref) => []);

class CreateLotScreen extends ConsumerWidget {
  const CreateLotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(createLotFormProvider);
    final selectedImages = ref.watch(selectedImagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Lot'),
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name
            _buildTextField(
              label: 'Product Name',
              hintText: 'e.g., Maize, Rice, Cassava',
              onChanged: (value) {
                ref.read(createLotFormProvider.notifier).update(
                      (state) => {...state, 'productName': value},
                    );
              },
            ),
            const SizedBox(height: 16),

            // Category
            _buildDropdown(
              label: 'Category',
              value: formData['category'] ?? '',
              items: ['Grains', 'Vegetables', 'Fruits', 'Spices', 'Others'],
              onChanged: (value) {
                ref.read(createLotFormProvider.notifier).update(
                      (state) => {...state, 'category': value},
                    );
              },
            ),
            const SizedBox(height: 16),

            // Quantity
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    label: 'Quantity',
                    hintText: '1000',
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      ref.read(createLotFormProvider.notifier).update(
                            (state) => {
                              ...state,
                              'quantity': value,
                            },
                          );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: 'Unit',
                    value: formData['quantityUnit'] ?? 'kg',
                    items: ['kg', 'bag', 'ton', 'crate', 'box'],
                    onChanged: (value) {
                      ref.read(createLotFormProvider.notifier).update(
                            (state) => {
                              ...state,
                              'quantityUnit': value,
                            },
                          );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price per Unit
            _buildTextField(
              label: 'Price per Unit (\$)',
              hintText: '0.50',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref.read(createLotFormProvider.notifier).update(
                      (state) => {...state, 'pricePerUnit': value},
                    );
              },
            ),
            const SizedBox(height: 16),

            // Description
            _buildTextField(
              label: 'Description',
              hintText: 'Describe your product quality, ripeness, grade, etc.',
              maxLines: 4,
              onChanged: (value) {
                ref.read(createLotFormProvider.notifier).update(
                      (state) => {...state, 'description': value},
                    );
              },
            ),
            const SizedBox(height: 16),

            // Images
            const Text(
              'Product Images (3-5 recommended)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildImagePicker(context, ref, selectedImages),
            const SizedBox(height: 16),

            // Certifications
            const Text(
              'Certifications (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildCertificationChips(ref, formData),
            const SizedBox(height: 16),

            // Pickup Location
            _buildTextField(
              label: 'Pickup Location',
              hintText: 'Market name or address',
              onChanged: (value) {
                ref.read(createLotFormProvider.notifier).update(
                      (state) => {...state, 'pickupLocation': value},
                    );
              },
            ),
            const SizedBox(height: 16),

            // Estimated Total Value
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimated Total Value:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${_calculateTotal(formData).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showPreview(context, ref, formData, selectedImages);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _submitLot(context, ref, formData, selectedImages);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Create Lot'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value.isEmpty ? items[0] : value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(
    BuildContext context,
    WidgetRef ref,
    List<File> selectedImages,
  ) {
    return Column(
      children: [
        // Selected images
        if (selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            final newImages = List<File>.from(selectedImages);
                            newImages.removeAt(index);
                            ref.read(selectedImagesProvider.notifier).state =
                                newImages;
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),

        // Add image button
        if (selectedImages.length < 5)
          ElevatedButton.icon(
            onPressed: () {
              _pickImage(ref);
            },
            icon: const Icon(Icons.photo_library),
            label: Text(
              'Add Image (${selectedImages.length}/5)',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
            ),
          ),
      ],
    );
  }

  Widget _buildCertificationChips(
    WidgetRef ref,
    Map<String, dynamic> formData,
  ) {
    final availableCerts = [
      'Organic',
      'Fair Trade',
      'Non-GMO',
      'Rainforest Alliance',
      'Premium Grade'
    ];
    final selectedCerts = List<String>.from(formData['certifications'] ?? []);

    return Wrap(
      spacing: 8,
      children: availableCerts.map((cert) {
        final isSelected = selectedCerts.contains(cert);
        return ChoiceChip(
          label: Text(cert),
          selected: isSelected,
          onSelected: (selected) {
            final newCerts = List<String>.from(selectedCerts);
            if (selected) {
              newCerts.add(cert);
            } else {
              newCerts.remove(cert);
            }
            ref.read(createLotFormProvider.notifier).update(
                  (state) => {...state, 'certifications': newCerts},
                );
          },
        );
      }).toList(),
    );
  }

  Future<void> _pickImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final selectedImages = ref.read(selectedImagesProvider);
      ref.read(selectedImagesProvider.notifier).state = [
        ...selectedImages,
        File(image.path),
      ];
    }
  }

  double _calculateTotal(Map<String, dynamic> formData) {
    final quantity = double.tryParse(formData['quantity'] ?? '0') ?? 0;
    final price = double.tryParse(formData['pricePerUnit'] ?? '0') ?? 0;
    return quantity * price;
  }

  void _showPreview(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> formData,
    List<File> selectedImages,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preview Lot'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Product: ${formData['productName']}'),
              Text(
                  'Quantity: ${formData['quantity']} ${formData['quantityUnit']}'),
              Text('Price: \$${formData['pricePerUnit']}'),
              Text('Location: ${formData['pickupLocation']}'),
              Text('Images: ${selectedImages.length}'),
              const SizedBox(height: 12),
              const Text('Images Preview:'),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          selectedImages[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitLot(context, ref, formData, selectedImages);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submitLot(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> formData,
    List<File> selectedImages,
  ) {
    // Validate form
    if (formData['productName'].isEmpty ||
        formData['quantity'].isEmpty ||
        formData['pricePerUnit'].isEmpty ||
        formData['description'].isEmpty ||
        formData['pickupLocation'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    // TODO: Upload images to cloud storage
    // TODO: Call API to create lot
    // TODO: Show success message
    // TODO: Navigate back to dashboard

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lot created successfully!')),
    );

    // Navigate back
    context.go('/seller-dashboard');
  }
}
