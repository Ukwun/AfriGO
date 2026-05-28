import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' as io;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import '../../models/shipment_model.dart';
import '../providers/shipment_provider.dart';

class DeliveryProofScreen extends ConsumerStatefulWidget {
  final String shipmentId;

  const DeliveryProofScreen({
    Key? key,
    required this.shipmentId,
  }) : super(key: key);

  @override
  ConsumerState<DeliveryProofScreen> createState() =>
      _DeliveryProofScreenState();
}

class _DeliveryProofScreenState extends ConsumerState<DeliveryProofScreen> {
  late TabController _tabController;
  final ImagePicker _imagePicker = ImagePicker();

  // Signature form
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _recipientIdController = TextEditingController();
  String _selectedProofType = 'SIGNATURE';
  io.File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _recipientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Delivery Proof'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Proof Type Selector
              Text(
                'Proof Type',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Signature'),
                    selected: _selectedProofType == 'SIGNATURE',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedProofType = 'SIGNATURE');
                      }
                    },
                  ),
                  FilterChip(
                    label: const Text('Photo'),
                    selected: _selectedProofType == 'PHOTOGRAPH',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedProofType = 'PHOTOGRAPH');
                      }
                    },
                  ),
                  FilterChip(
                    label: const Text('ID Card'),
                    selected: _selectedProofType == 'ID_CARD',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedProofType = 'ID_CARD');
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recipient Information Form
              Text(
                'Recipient Information',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _recipientNameController,
                decoration: InputDecoration(
                  labelText: 'Recipient Full Name',
                  hintText: 'Enter recipient name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _recipientPhoneController,
                decoration: InputDecoration(
                  labelText: 'Recipient Phone',
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _recipientIdController,
                decoration: InputDecoration(
                  labelText: 'ID Number (Optional)',
                  hintText: 'Enter ID card number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Proof Capture Section
              Text(
                _selectedProofType == 'SIGNATURE'
                    ? 'Signature Pad'
                    : 'Photo Capture',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),

              if (_selectedProofType == 'SIGNATURE')
                _buildSignatureSection(context)
              else
                _buildPhotoSection(context),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitProof(context),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Submit Proof'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureSection(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Signature Pad',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Signature pad will be drawn here\n(Ready for signature_pad package integration)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Clear signature
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Capture signature
              },
              icon: const Icon(Icons.check),
              label: const Text('Capture'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Column(
      children: [
        if (_selectedImage != null)
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickPhoto(),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Retake'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _selectedImage = null);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ],
          )
        else
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No photo selected',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickPhoto(),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickPhotoFromGallery(),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('From Gallery'),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _pickPhoto() async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _selectedImage = io.File(image.path));
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = io.File(image.path));
    }
  }

  Future<void> _submitProof(BuildContext context) async {
    if (_recipientNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter recipient name')),
      );
      return;
    }

    if (_selectedProofType == 'PHOTOGRAPH' && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = ref.read(shipmentServiceProvider);

      String? dataBlobUrl;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        dataBlobUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      final request = CaptureDeliveryProofRequest(
        proofType: _selectedProofType,
        description: 'Delivery proof captured by driver',
        dataBlobUrl: dataBlobUrl,
        recipientName: _recipientNameController.text,
        recipientPhone: _recipientPhoneController.text,
        recipientIdNumber: _recipientIdController.text.isNotEmpty
            ? _recipientIdController.text
            : null,
      );

      await service.captureDeliveryProof(widget.shipmentId, request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proof submitted successfully')),
        );
        context.pop();
        ref.refresh(shipmentProvider(widget.shipmentId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
