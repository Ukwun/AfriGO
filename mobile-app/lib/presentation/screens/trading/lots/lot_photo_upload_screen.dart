import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../data/services/lot_service.dart';

/// Lot Photo Upload Screen
/// Allows sellers to upload multiple product photos
/// Photos stored in cloud storage with backend references
///
/// Features:
/// - Camera and gallery support
/// - Multiple photo upload
/// - Photo preview
/// - Real API calls to backend
/// - All buttons functional and clickable
/// - Real-time upload progress

class LotPhotoUploadScreen extends ConsumerStatefulWidget {
  final String lotId;

  const LotPhotoUploadScreen({
    super.key,
    required this.lotId,
  });

  @override
  ConsumerState<LotPhotoUploadScreen> createState() =>
      _LotPhotoUploadScreenState();
}

class _LotPhotoUploadScreenState extends ConsumerState<LotPhotoUploadScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final List<File> _selectedPhotos = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  /// Pick photo from gallery
  Future<void> _pickPhotoFromGallery() async {
    try {
      final photo = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (photo != null) {
        setState(() => _selectedPhotos.add(File(photo.path)));
        print('📸 Photo selected: ${photo.name}');
      }
    } catch (e) {
      print('❌ Error picking photo: $e');
    }
  }

  /// Take photo with camera
  Future<void> _takePhoto() async {
    try {
      final photo = await _imagePicker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() => _selectedPhotos.add(File(photo.path)));
        print('📷 Photo taken and added');
      }
    } catch (e) {
      print('❌ Error taking photo: $e');
    }
  }

  /// Remove selected photo
  void _removePhoto(int index) {
    setState(() => _selectedPhotos.removeAt(index));
    print('🗑️  Photo removed');
  }

  /// Upload all photos
  Future<void> _uploadPhotos() async {
    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️  Please select at least one photo')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final lotService = LotService();

      print('📤 Uploading ${_selectedPhotos.length} photos...');

      for (int i = 0; i < _selectedPhotos.length; i++) {
        final photo = _selectedPhotos[i];
        print('   Uploading photo ${i + 1}/${_selectedPhotos.length}');

        await lotService.uploadLotPhoto(
          lotId: widget.lotId,
          photoFile: photo,
          photoIndex: i,
        );

        // Update progress
        setState(() => _uploadProgress = ((i + 1) / _selectedPhotos.length));
      }

      print('✅ All photos uploaded successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Photos uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        context.go('/trading/lot-qr-display/${widget.lotId}');
      }
    } catch (e) {
      print('❌ Photo Upload Failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Lot Photos'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              _buildHeaderCard(context),
              const SizedBox(height: 24),

              // Photo selection section
              _buildPhotoSelectionSection(context),
              const SizedBox(height: 24),

              // Selected photos preview
              if (_selectedPhotos.isNotEmpty) ...[
                _buildPhotosPreview(context),
                const SizedBox(height: 24),
              ],

              // Upload progress
              if (_isUploading) ...[
                _buildUploadProgressSection(context),
                const SizedBox(height: 24),
              ],

              // Info section
              _buildInfoSection(context),
              const SizedBox(height: 24),

              // Action buttons
              _buildActionButtons(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      key: const Key('photo_upload_header'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_library, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Lot Photos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add product photos for quality verification',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Lot ID: ${widget.lotId}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSelectionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Photos',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                key: const Key('take_photo_button'),
                icon: const Icon(Icons.camera_alt),
                label: const Text('TAKE PHOTO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: _isUploading ? null : _takePhoto,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                key: const Key('gallery_button'),
                icon: const Icon(Icons.image),
                label: const Text('GALLERY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                onPressed: _isUploading ? null : _pickPhotoFromGallery,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotosPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Photos (${_selectedPhotos.length})',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          key: const Key('photos_grid'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _selectedPhotos.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
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
                  child: InkWell(
                    key: Key('remove_photo_$index'),
                    onTap: () => _removePhoto(index),
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
            );
          },
        ),
      ],
    );
  }

  Widget _buildUploadProgressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Progress',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          key: const Key('upload_progress_card'),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: Colors.blue.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Uploading...'),
                  Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _uploadProgress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation(Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      key: const Key('photo_requirements_info'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photo Requirements',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '✓ Clear, well-lit photos\n'
            '✓ Include product samples\n'
            '✓ Show packaging/containers\n'
            '✓ Minimum 2 photos recommended\n'
            '✓ Maximum 10MB per photo\n'
            '✓ Photos stored permanently with lot',
            style: TextStyle(fontSize: 12, color: Colors.amber.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            key: const Key('upload_photos_button'),
            icon: const Icon(Icons.cloud_upload),
            label: _isUploading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Text('UPLOAD PHOTOS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: _isUploading
                ? null
                : (_selectedPhotos.isEmpty ? null : _uploadPhotos),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('skip_button'),
            icon: const Icon(Icons.skip_next),
            label: const Text('SKIP FOR NOW'),
            onPressed: _isUploading
                ? null
                : () => context.go('/trading/lot-qr-display/${widget.lotId}'),
          ),
        ),
      ],
    );
  }
}
