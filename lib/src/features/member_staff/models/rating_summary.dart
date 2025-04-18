class RatingSummary {
  final int staffId;
  final String staffType;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution;
  final List<RecentReview> recentReviews;

  RatingSummary({
    required this.staffId,
    required this.staffType,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    required this.recentReviews,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    // Parse rating distribution
    final Map<int, int> distribution = {};
    final Map<String, dynamic> jsonDistribution = json['rating_distribution'];
    jsonDistribution.forEach((key, value) {
      distribution[int.parse(key)] = value;
    });

    // Parse recent reviews
    final List<RecentReview> reviews = [];
    final List<dynamic> jsonReviews = json['recent_reviews'];
    for (var review in jsonReviews) {
      reviews.add(RecentReview.fromJson(review));
    }

    return RatingSummary(
      staffId: json['staff_id'],
      staffType: json['staff_type'],
      averageRating: json['average_rating'].toDouble(),
      totalRatings: json['total_ratings'],
      ratingDistribution: distribution,
      recentReviews: reviews,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert rating distribution to JSON
    final Map<String, dynamic> distributionJson = {};
    ratingDistribution.forEach((key, value) {
      distributionJson[key.toString()] = value;
    });

    return {
      'staff_id': staffId,
      'staff_type': staffType,
      'average_rating': averageRating,
      'total_ratings': totalRatings,
      'rating_distribution': distributionJson,
      'recent_reviews': recentReviews.map((review) => review.toJson()).toList(),
    };
  }
}

class RecentReview {
  final int rating;
  final String? feedback;
  final String memberName;
  final DateTime createdAt;

  RecentReview({
    required this.rating,
    this.feedback,
    required this.memberName,
    required this.createdAt,
  });

  factory RecentReview.fromJson(Map<String, dynamic> json) {
    return RecentReview(
      rating: json['rating'],
      feedback: json['feedback'],
      memberName: json['member_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'feedback': feedback,
      'member_name': memberName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
