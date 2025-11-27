import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String bookingId;
  final String customerId;
  final String providerId;
  final int rating; // 1-5 stars
  final String comment;
  final String customerName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.reviewId,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.rating,
    required this.comment,
    required this.customerName,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert Firestore document to ReviewModel
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      reviewId: data['reviewId'] ?? doc.id,
      bookingId: data['bookingId'] ?? '',
      customerId: data['customerId'] ?? '',
      providerId: data['providerId'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      customerName: data['customerName'] ?? 'Anonymous',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert ReviewModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'reviewId': reviewId,
      'bookingId': bookingId,
      'customerId': customerId,
      'providerId': providerId,
      'rating': rating,
      'comment': comment,
      'customerName': customerName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create a copy with updated fields
  ReviewModel copyWith({
    String? reviewId,
    String? bookingId,
    String? customerId,
    String? providerId,
    int? rating,
    String? comment,
    String? customerName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      reviewId: reviewId ?? this.reviewId,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      customerName: customerName ?? this.customerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  // Check if review was edited
  bool get isEdited => updatedAt != null && updatedAt!.isAfter(createdAt);

  @override
  String toString() {
    return 'ReviewModel(reviewId: $reviewId, providerId: $providerId, rating: $rating, comment: $comment)';
  }
}
