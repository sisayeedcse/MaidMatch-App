import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ProviderReviewsScreen extends StatefulWidget {
  final String providerId;
  final String providerName;

  const ProviderReviewsScreen({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  @override
  State<ProviderReviewsScreen> createState() => _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState extends State<ProviderReviewsScreen> {
  final ReviewService _reviewService = ReviewService();
  String _sortBy = 'recent'; // recent, highest, lowest

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("${widget.providerName}'s Reviews"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded),
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Most Recent'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'highest',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Highest Rating'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'lowest',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Lowest Rating'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Rating Summary Card
            FutureBuilder<Map<String, dynamic>>(
              future: _reviewService.getProviderRatingStats(widget.providerId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final stats = snapshot.data!;
                final averageRating = stats['averageRating'] as double;
                final totalReviews = stats['totalReviews'] as int;
                final breakdown = stats['ratingBreakdown'] as Map<int, int>;

                return _buildRatingSummaryCard(
                  averageRating,
                  totalReviews,
                  breakdown,
                );
              },
            ),

            const SizedBox(height: 16),

            // Reviews List
            StreamBuilder<List<ReviewModel>>(
              stream: _reviewService.getProviderReviewsStream(
                widget.providerId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                }

                List<ReviewModel> reviews = snapshot.data ?? [];

                if (reviews.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review_rounded,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Sort reviews
                reviews = _sortReviews(reviews);

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    return _buildReviewCard(reviews[index]);
                  },
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummaryCard(
    double averageRating,
    int totalReviews,
    Map<int, int> breakdown,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Average Rating Display
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFBBF24),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < averageRating.round()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFFBBF24),
                          size: 24,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalReviews reviews',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Rating Breakdown
              Expanded(
                flex: 3,
                child: Column(
                  children: List.generate(5, (index) {
                    final star = 5 - index;
                    final count = breakdown[star] ?? 0;
                    final percentage = totalReviews > 0
                        ? (count / totalReviews)
                        : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            '$star',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFBBF24),
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 24,
                            child: Text(
                              '$count',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Customer Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                child: Text(
                  review.customerName.isNotEmpty
                      ? review.customerName[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Customer Name and Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      review.formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating Stars
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBBF24).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${review.rating}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],

          if (review.isEdited) ...[
            const SizedBox(height: 8),
            Text(
              'Edited',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<ReviewModel> _sortReviews(List<ReviewModel> reviews) {
    final sorted = List<ReviewModel>.from(reviews);

    switch (_sortBy) {
      case 'highest':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest':
        sorted.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case 'recent':
      default:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return sorted;
  }
}
