class StaffRating {
  final int id;
  final int memberId;
  final int staffId;
  final String staffType;
  final int rating;
  final String? feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  StaffRating({
    required this.id,
    required this.memberId,
    required this.staffId,
    required this.staffType,
    required this.rating,
    this.feedback,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StaffRating.fromJson(Map<String, dynamic> json) {
    return StaffRating(
      id: json['id'],
      memberId: json['member_id'],
      staffId: json['staff_id'],
      staffType: json['staff_type'],
      rating: json['rating'],
      feedback: json['feedback'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'staff_id': staffId,
      'staff_type': staffType,
      'rating': rating,
      'feedback': feedback,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
