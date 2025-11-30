import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// Service for handling Firebase Storage operations
/// Manages image uploads for user profiles, provider portfolios, and documents
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload user profile photo
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfilePhoto({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final String fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child('profiles/$fileName');

      // Upload file
      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading profile photo: $e');
      rethrow;
    }
  }

  /// Upload provider portfolio image
  /// Returns the download URL of the uploaded image
  Future<String> uploadPortfolioImage({
    required String providerId,
    required File imageFile,
  }) async {
    try {
      final String fileName =
          'portfolio_${providerId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child(
        'portfolios/$providerId/$fileName',
      );

      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'providerId': providerId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading portfolio image: $e');
      rethrow;
    }
  }

  /// Upload verification document (NID, Police Clearance, etc.)
  /// Returns the download URL of the uploaded document
  Future<String> uploadVerificationDocument({
    required String userId,
    required File documentFile,
    required String
    documentType, // 'nid', 'police_clearance', 'ngo_certificate'
  }) async {
    try {
      final String extension = path.extension(documentFile.path);
      final String fileName =
          '${documentType}_${userId}_${DateTime.now().millisecondsSinceEpoch}$extension';
      final Reference storageRef = _storage.ref().child(
        'documents/$userId/$fileName',
      );

      // Determine content type
      String contentType = 'application/pdf';
      if (extension.toLowerCase() == '.jpg' ||
          extension.toLowerCase() == '.jpeg') {
        contentType = 'image/jpeg';
      } else if (extension.toLowerCase() == '.png') {
        contentType = 'image/png';
      }

      final UploadTask uploadTask = storageRef.putFile(
        documentFile,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'userId': userId,
            'documentType': documentType,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadURL = await snapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading document: $e');
      rethrow;
    }
  }

  /// Upload image with progress tracking
  /// Returns a stream of upload progress (0.0 to 1.0) and final download URL
  Stream<double> uploadImageWithProgress({
    required String userId,
    required File imageFile,
    required String folder, // 'profiles', 'portfolios', etc.
  }) async* {
    try {
      final String fileName =
          '${folder}_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child('$folder/$fileName');

      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Listen to upload progress
      await for (final TaskSnapshot snapshot in uploadTask.snapshotEvents) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        yield progress;
      }
    } catch (e) {
      print('Error uploading image with progress: $e');
      rethrow;
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
      print('Image deleted successfully');
    } catch (e) {
      print('Error deleting image: $e');
      rethrow;
    }
  }

  /// Get list of provider portfolio images
  Future<List<String>> getPortfolioImages(String providerId) async {
    try {
      final Reference portfolioRef = _storage.ref().child(
        'portfolios/$providerId',
      );
      final ListResult result = await portfolioRef.listAll();

      final List<String> imageUrls = [];
      for (var item in result.items) {
        final String url = await item.getDownloadURL();
        imageUrls.add(url);
      }

      return imageUrls;
    } catch (e) {
      print('Error getting portfolio images: $e');
      return [];
    }
  }

  /// Delete all images in a folder (useful when deleting user account)
  Future<void> deleteUserImages(String userId) async {
    try {
      // Delete profile images
      final Reference profileRef = _storage.ref().child('profiles');
      final ListResult profileResult = await profileRef.listAll();

      for (var item in profileResult.items) {
        if (item.name.contains(userId)) {
          await item.delete();
        }
      }

      // Delete portfolio images
      final Reference portfolioRef = _storage.ref().child('portfolios/$userId');
      final ListResult portfolioResult = await portfolioRef.listAll();

      for (var item in portfolioResult.items) {
        await item.delete();
      }

      // Delete documents
      final Reference docsRef = _storage.ref().child('documents/$userId');
      final ListResult docsResult = await docsRef.listAll();

      for (var item in docsResult.items) {
        await item.delete();
      }

      print('All user images deleted successfully');
    } catch (e) {
      print('Error deleting user images: $e');
      rethrow;
    }
  }
}
