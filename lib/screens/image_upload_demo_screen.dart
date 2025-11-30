import 'package:flutter/material.dart';
import '../widgets/image_upload_widget.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Example screen demonstrating image upload functionality
/// This can be used for profile photo upload or portfolio management
class ImageUploadDemoScreen extends StatefulWidget {
  const ImageUploadDemoScreen({super.key});

  @override
  State<ImageUploadDemoScreen> createState() => _ImageUploadDemoScreenState();
}

class _ImageUploadDemoScreenState extends State<ImageUploadDemoScreen> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  String? _profilePhotoUrl;
  List<String> _portfolioImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserImages();
  }

  /// Load existing user images
  Future<void> _loadUserImages() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Load profile photo from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _profilePhotoUrl = userDoc.data()?['photoURL'];
          });
        }

        // Load portfolio images from Storage
        final portfolioUrls = await _storageService.getPortfolioImages(
          currentUser.uid,
        );
        setState(() {
          _portfolioImages = portfolioUrls;
        });
      }
    } catch (e) {
      print('Error loading images: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Handle profile photo upload
  Future<void> _onProfilePhotoUploaded(String downloadUrl) async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      // Update Firestore with new photo URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'photoURL': downloadUrl});

      // Update Firebase Auth profile
      await _authService.updateUserProfile(photoURL: downloadUrl);

      setState(() {
        _profilePhotoUrl = downloadUrl;
      });
    }
  }

  /// Handle portfolio image upload
  void _onPortfolioImageUploaded(String downloadUrl) {
    setState(() {
      _portfolioImages.add(downloadUrl);
    });
  }

  /// Delete portfolio image
  Future<void> _deletePortfolioImage(String imageUrl) async {
    try {
      await _storageService.deleteImage(imageUrl);
      setState(() {
        _portfolioImages.remove(imageUrl);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Upload Demo'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photo Section
                  const Text(
                    'Profile Photo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ImageUploadWidget(
                    initialImageUrl: _profilePhotoUrl,
                    onImageUploaded: _onProfilePhotoUploaded,
                    uploadType: 'profile',
                  ),
                  const SizedBox(height: 32),

                  // Portfolio Images Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Portfolio Images',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_portfolioImages.length} images',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Add new portfolio image
                  ImageUploadWidget(
                    onImageUploaded: _onPortfolioImageUploaded,
                    uploadType: 'portfolio',
                  ),
                  const SizedBox(height: 20),

                  // Display existing portfolio images
                  if (_portfolioImages.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                      itemCount: _portfolioImages.length,
                      itemBuilder: (context, index) {
                        final imageUrl = _portfolioImages[index];
                        return Stack(
                          children: [
                            ClipRRectImage.network(
                              imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            // Delete button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Material(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  onTap: () =>
                                      _showDeleteConfirmation(imageUrl),
                                  borderRadius: BorderRadius.circular(20),
                                  child: const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  const SizedBox(height: 32),

                  // Document Upload Example
                  const Text(
                    'Verification Documents',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Upload NID, Police Clearance, or NGO Certificate',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ImageUploadWidget(
                    onImageUploaded: (url) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Document uploaded successfully'),
                        ),
                      );
                    },
                    uploadType: 'document',
                    documentType: 'nid',
                  ),
                ],
              ),
            ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePortfolioImage(imageUrl);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for ClipRRect
class ClipRRectImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;

  const ClipRRectImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    required this.fit,
  });

  static Widget network(
    String url, {
    required double width,
    required double height,
    required BoxFit fit,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
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
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.error, color: Colors.red),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return network(url, width: width, height: height, fit: fit);
  }
}
