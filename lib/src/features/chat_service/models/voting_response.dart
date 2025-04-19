import 'package:flutter/foundation.dart';

/// Model representing a user's vote on a poll option
class VotingResponse {
  /// Unique identifier for the response
  final String id;
  
  /// ID of the poll this response belongs to
  final String pollId;
  
  /// ID of the option that was selected
  final String optionId;
  
  /// ID of the user who voted
  final String userId;
  
  /// Timestamp when the vote was cast
  final DateTime createdAt;

  /// Constructor
  VotingResponse({
    required this.id,
    required this.pollId,
    required this.optionId,
    required this.userId,
    required this.createdAt,
  });

  /// Create a VotingResponse from a map
  factory VotingResponse.fromMap(Map<String, dynamic> map) {
    return VotingResponse(
      id: map['id'],
      pollId: map['poll_id'],
      optionId: map['option_id'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  /// Convert response to a map for sending to the API
  Map<String, dynamic> toMap() {
    return {
      'poll_id': pollId,
      'option_id': optionId,
      'user_id': userId,
    };
  }

  /// Create a copy of this response with updated fields
  VotingResponse copyWith({
    String? id,
    String? pollId,
    String? optionId,
    String? userId,
    DateTime? createdAt,
  }) {
    return VotingResponse(
      id: id ?? this.id,
      pollId: pollId ?? this.pollId,
      optionId: optionId ?? this.optionId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is VotingResponse &&
        other.id == id &&
        other.pollId == pollId &&
        other.optionId == optionId &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        pollId.hashCode ^
        optionId.hashCode ^
        userId.hashCode;
  }
}
