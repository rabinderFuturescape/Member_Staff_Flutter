import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/rating_summary.dart';
import '../providers/staff_rating_provider.dart';
import 'package:provider/provider.dart';

class StaffRatingSummary extends StatefulWidget {
  final int staffId;
  final String staffType;
  final VoidCallback? onRatePressed;

  const StaffRatingSummary({
    Key? key,
    required this.staffId,
    required this.staffType,
    this.onRatePressed,
  }) : super(key: key);

  @override
  _StaffRatingSummaryState createState() => _StaffRatingSummaryState();
}

class _StaffRatingSummaryState extends State<StaffRatingSummary> {
  late Future<RatingSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _loadRatingSummary();
  }

  void _loadRatingSummary() {
    final ratingProvider = Provider.of<StaffRatingProvider>(context, listen: false);
    _summaryFuture = ratingProvider.getRatingSummary(
      staffId: widget.staffId,
      staffType: widget.staffType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RatingSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        } else if (snapshot.hasData) {
          return _buildSummaryCard(snapshot.data!);
        } else {
          return _buildEmptyState();
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 8),
            Text(
              'Failed to load ratings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadRatingSummary();
                });
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_border, color: Colors.amber, size: 48),
            SizedBox(height: 8),
            Text(
              'No ratings yet',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: widget.onRatePressed,
              child: Text('Be the first to rate'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(RatingSummary summary) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rating & Reviews',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${summary.totalRatings} ${summary.totalRatings == 1 ? 'review' : 'reviews'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: widget.onRatePressed,
                  child: Text('Rate'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  summary.averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingBarIndicator(
                      rating: summary.averageRating,
                      itemBuilder: (context, index) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 24.0,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Average rating',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildRatingDistribution(summary.ratingDistribution),
            if (summary.recentReviews.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Recent Reviews',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              ...summary.recentReviews.map((review) => _buildReviewItem(review)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingDistribution(Map<int, int> distribution) {
    final totalRatings = distribution.values.fold<int>(0, (sum, count) => sum + count);
    if (totalRatings == 0) return SizedBox.shrink();

    return Column(
      children: List.generate(5, (index) {
        final rating = 5 - index;
        final count = distribution[rating] ?? 0;
        final percentage = totalRatings > 0 ? count / totalRatings : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Text(
                '$rating',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '$count',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewItem(RecentReview review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(
                  review.memberName.substring(0, 1).toUpperCase(),
                ),
                radius: 16,
              ),
              SizedBox(width: 8),
              Text(
                review.memberName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          RatingBarIndicator(
            rating: review.rating.toDouble(),
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            itemCount: 5,
            itemSize: 16.0,
          ),
          if (review.feedback != null && review.feedback!.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              review.feedback!,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
          Divider(),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
