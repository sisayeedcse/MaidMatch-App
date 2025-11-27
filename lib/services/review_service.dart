import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../models/booking_model.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reviews';

  // Create a new review
  Future<void> createReview({
    required String bookingId,
    required String customerId,
    required String providerId,
    required int rating,
    required String comment,
    required String customerName,
  }) async {
    try {
      // Validate rating
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      // Check if booking exists and is completed
      final bookingDoc = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .get();
      if (!bookingDoc.exists) {
        throw Exception('Booking not found');
      }

      final booking = BookingModel.fromFirestore(bookingDoc);
      if (booking.status != 'completed') {
        throw Exception('Can only review completed bookings');
      }

      if (booking.customerId != customerId) {
        throw Exception('Only the customer can review this booking');
      }

      // Check if review already exists
      final existingReview = await getReviewByBooking(bookingId);
      if (existingReview != null) {
        throw Exception('Review already exists for this booking');
      }

      // Create review
      final reviewId = _firestore.collection(_collection).doc().id;
      final review = ReviewModel(
        reviewId: reviewId,
        bookingId: bookingId,
        customerId: customerId,
        providerId: providerId,
        rating: rating,
        comment: comment,
        customerName: customerName,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(reviewId)
          .set(review.toFirestore());

      // Update provider's average rating
      await _updateProviderRating(providerId);
    } catch (e) {
      print('Error creating review: $e');
      rethrow;
    }
  }

  // Get all reviews for a provider
  Stream<List<ReviewModel>> getProviderReviewsStream(String providerId) {
    return _firestore
        .collection(_collection)
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReviewModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Get reviews for a provider (one-time fetch)
  Future<List<ReviewModel>> getProviderReviews(String providerId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting provider reviews: $e');
      return [];
    }
  }

  // Get review by booking ID
  Future<ReviewModel?> getReviewByBooking(String bookingId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return ReviewModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting review by booking: $e');
      return null;
    }
  }

  // Update an existing review
  Future<void> updateReview({
    required String reviewId,
    required String customerId,
    required int rating,
    required String comment,
  }) async {
    try {
      // Validate rating
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      // Get existing review
      final reviewDoc = await _firestore
          .collection(_collection)
          .doc(reviewId)
          .get();
      if (!reviewDoc.exists) {
        throw Exception('Review not found');
      }

      final review = ReviewModel.fromFirestore(reviewDoc);

      // Check if user is the owner
      if (review.customerId != customerId) {
        throw Exception('You can only edit your own reviews');
      }

      // Check if review was created within 24 hours (editable window)
      final hoursSinceCreation = DateTime.now()
          .difference(review.createdAt)
          .inHours;
      if (hoursSinceCreation > 24) {
        throw Exception('Reviews can only be edited within 24 hours');
      }

      // Update review
      await _firestore.collection(_collection).doc(reviewId).update({
        'rating': rating,
        'comment': comment,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Update provider's average rating
      await _updateProviderRating(review.providerId);
    } catch (e) {
      print('Error updating review: $e');
      rethrow;
    }
  }

  // Delete a review
  Future<void> deleteReview({
    required String reviewId,
    required String customerId,
  }) async {
    try {
      // Get existing review
      final reviewDoc = await _firestore
          .collection(_collection)
          .doc(reviewId)
          .get();
      if (!reviewDoc.exists) {
        throw Exception('Review not found');
      }

      final review = ReviewModel.fromFirestore(reviewDoc);

      // Check if user is the owner
      if (review.customerId != customerId) {
        throw Exception('You can only delete your own reviews');
      }

      // Delete review
      await _firestore.collection(_collection).doc(reviewId).delete();

      // Update provider's average rating
      await _updateProviderRating(review.providerId);
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }

  // Get average rating for a provider
  Future<Map<String, dynamic>> getProviderRatingStats(String providerId) async {
    try {
      final reviews = await getProviderReviews(providerId);

      if (reviews.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingBreakdown': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        };
      }

      // Calculate average
      final totalRating = reviews.fold<int>(
        0,
        (sum, review) => sum + review.rating,
      );
      final averageRating = totalRating / reviews.length;

      // Calculate rating breakdown
      final ratingBreakdown = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      for (var review in reviews) {
        ratingBreakdown[review.rating] =
            (ratingBreakdown[review.rating] ?? 0) + 1;
      }

      return {
        'averageRating': double.parse(averageRating.toStringAsFixed(1)),
        'totalReviews': reviews.length,
        'ratingBreakdown': ratingBreakdown,
      };
    } catch (e) {
      print('Error getting provider rating stats: $e');
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingBreakdown': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      };
    }
  }

  // Check if user can review a booking
  Future<bool> canUserReview({
    required String bookingId,
    required String customerId,
  }) async {
    try {
      // Check if booking exists and is completed
      final bookingDoc = await _firestore
          .collection('bookings')
          .doc(bookingId)
          .get();
      if (!bookingDoc.exists) {
        return false;
      }

      final booking = BookingModel.fromFirestore(bookingDoc);
      if (booking.status != 'completed') {
        return false;
      }

      if (booking.customerId != customerId) {
        return false;
      }

      // Check if review already exists
      final existingReview = await getReviewByBooking(bookingId);
      return existingReview == null;
    } catch (e) {
      print('Error checking if user can review: $e');
      return false;
    }
  }

  // Private method to update provider's average rating in users collection
  Future<void> _updateProviderRating(String providerId) async {
    try {
      final stats = await getProviderRatingStats(providerId);

      await _firestore.collection('users').doc(providerId).update({
        'averageRating': stats['averageRating'],
        'totalReviews': stats['totalReviews'],
      });
    } catch (e) {
      print('Error updating provider rating: $e');
      // Don't rethrow - this is a background update
    }
  }

  // Get recent reviews (for homepage or general display)
  Future<List<ReviewModel>> getRecentReviews({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting recent reviews: $e');
      return [];
    }
  }

  // Get top-rated providers
  Future<List<Map<String, dynamic>>> getTopRatedProviders({
    int limit = 5,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'provider')
          .where('totalReviews', isGreaterThan: 0)
          .orderBy('totalReviews')
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'providerId': doc.id,
          'name': data['name'] ?? 'Unknown',
          'averageRating': data['averageRating'] ?? 0.0,
          'totalReviews': data['totalReviews'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error getting top-rated providers: $e');
      return [];
    }
  }
}
