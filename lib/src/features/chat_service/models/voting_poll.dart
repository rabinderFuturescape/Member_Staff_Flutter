import 'package:flutter/foundation.dart';
import 'voting_option.dart';

/// Model representing a voting poll in a chat room
class VotingPoll {
  /// Unique identifier for the poll
  final String id;
  
  /// ID of the room this poll belongs to
  final String roomId;
  
  /// ID of the user who created the poll
  final String createdById;
  
  /// Question being asked in the poll
  final String question;
  
  /// Whether the poll is active
  final bool isActive;
  
  /// Timestamp when the poll was created
  final DateTime createdAt;
  
  /// Timestamp when the poll ends (optional)
  final DateTime? endsAt;
  
  /// Options available for voting
  final List<VotingOption> options;

  /// Constructor
  VotingPoll({
    required this.id,
    required this.roomId,
    required this.createdById,
    required this.question,
    required this.isActive,
    required this.createdAt,
    this.endsAt,
    required this.options,
  });

  /// Create a VotingPoll from a map
  factory VotingPoll.fromMap(Map<String, dynamic> map, List<VotingOption> options) {
    return VotingPoll(
      id: map['id'],
      roomId: map['room_id'],
      createdById: map['created_by_id'],
      question: map['question'],
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      endsAt: map['ends_at'] != null ? DateTime.parse(map['ends_at']) : null,
      options: options,
    );
  }

  /// Convert poll to a map for sending to the API
  Map<String, dynamic> toMap() {
    return {
      'room_id': roomId,
      'question': question,
      'is_active': isActive,
      'ends_at': endsAt?.toIso8601String(),
    };
  }

  /// Create a copy of this poll with updated fields
  VotingPoll copyWith({
    String? id,
    String? roomId,
    String? createdById,
    String? question,
    bool? isActive,
    DateTime? createdAt,
    DateTime? endsAt,
    List<VotingOption>? options,
  }) {
    return VotingPoll(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      createdById: createdById ?? this.createdById,
      question: question ?? this.question,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      endsAt: endsAt ?? this.endsAt,
      options: options ?? this.options,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is VotingPoll &&
        other.id == id &&
        other.roomId == roomId &&
        other.question == question;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roomId.hashCode ^
        question.hashCode;
  }
}
