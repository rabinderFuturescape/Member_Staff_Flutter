import 'dart:convert';

/// Model class representing a feature request.
class FeatureRequest {
  final int? id;
  final String featureTitle;
  final String? description;
  final int votes;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FeatureRequest({
    this.id,
    required this.featureTitle,
    this.description,
    this.votes = 1,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this FeatureRequest with the given fields replaced with the new values.
  FeatureRequest copyWith({
    int? id,
    String? featureTitle,
    String? description,
    int? votes,
    int? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeatureRequest(
      id: id ?? this.id,
      featureTitle: featureTitle ?? this.featureTitle,
      description: description ?? this.description,
      votes: votes ?? this.votes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Creates a FeatureRequest from a JSON map.
  factory FeatureRequest.fromJson(Map<String, dynamic> json) {
    return FeatureRequest(
      id: json['id'],
      featureTitle: json['feature_title'],
      description: json['description'],
      votes: json['votes'] ?? 1,
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Converts this FeatureRequest to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'feature_title': featureTitle,
      if (description != null) 'description': description,
      'votes': votes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'FeatureRequest(id: $id, featureTitle: $featureTitle, votes: $votes)';
  }
}
