import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

/// Widget for image upload with preview and progress
class ImageUploadWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String) onImageUploaded;
  final String uploadType; // 'profile', 'portfolio', 'document'
  final String? documentType; // For document uploads

  const ImageUploadWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageUploaded,
    required this.uploadType,
    this.documentType,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  /// Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  /// Take photo with camera
  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        await _uploadImage();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  /// Upload image to Firebase Storage
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      _showErrorSnackBar('User not authenticated');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      String downloadUrl;

      switch (widget.uploadType) {
        case 'profile':
          downloadUrl = await _storageService.uploadProfilePhoto(
            userId: currentUser.uid,
            imageFile: _selectedImage!,
          );
          break;

        case 'portfolio':
          downloadUrl = await _storageService.uploadPortfolioImage(
            providerId: currentUser.uid,
            imageFile: _selectedImage!,
          );
          break;

        case 'document':
          if (widget.documentType == null) {
            throw Exception('Document type is required');
          }
          downloadUrl = await _storageService.uploadVerificationDocument(
            userId: currentUser.uid,
            documentFile: _selectedImage!,
            documentType: widget.documentType!,
          );
          break;

        default:
          throw Exception('Invalid upload type');
      }

      setState(() {
        _imageUrl = downloadUrl;
        _isUploading = false;
        _uploadProgress = 1.0;
      });

      widget.onImageUploaded(downloadUrl);

      _showSuccessSnackBar('Image uploaded successfully');
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      _showErrorSnackBar('Upload failed: $e');
    }
  }

  /// Show image source selection dialog
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF6366F1),
              ),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF6366F1)),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          // Image preview
          if (_imageUrl != null || _selectedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      _imageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
            ),

          // Upload button (center)
          if (_imageUrl == null && _selectedImage == null && !_isUploading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload Image',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            ),

          // Upload progress indicator
          if (_isUploading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _uploadProgress > 0 ? _uploadProgress : null,
                    strokeWidth: 6,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Uploading... ${(_uploadProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Change/Upload button (bottom right)
          if (!_isUploading)
            Positioned(
              bottom: 12,
              right: 12,
              child: Material(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(30),
                elevation: 4,
                child: InkWell(
                  onTap: _showImageSourceDialog,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _imageUrl == null && _selectedImage == null
                          ? Icons.add_photo_alternate
                          : Icons.edit,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
