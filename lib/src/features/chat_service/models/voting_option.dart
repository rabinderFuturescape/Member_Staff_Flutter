import 'package:flutter/foundation.dart';

/// Model representing an option in a voting poll
class VotingOption {
  /// Unique identifier for the option
  final String id;
  
  /// ID of the poll this option belongs to
  final String pollId;
  
  /// Text of the option
  final String optionText;
  
  /// Number of votes for this option
  final int voteCount;
  
  /// Whether the current user has voted for this option
  final bool hasVoted;

  /// Constructor
  VotingOption({
    required this.id,
    required this.pollId,
    required this.optionText,
    this.voteCount = 0,
    this.hasVoted = false,
  });

  /// Create a VotingOption from a map
  factory VotingOption.fromMap(Map<String, dynamic> map, {bool hasVoted = false}) {
    return VotingOption(
      id: map['id'],
      pollId: map['poll_id'],
      optionText: map['option_text'],
      voteCount: map['vote_count'] ?? 0,
      hasVoted: hasVoted,
    );
  }

  /// Convert option to a map for sending to the API
  Map<String, dynamic> toMap() {
    return {
      'poll_id': pollId,
      'option_text': optionText,
    };
  }

  /// Create a copy of this option with updated fields
  VotingOption copyWith({
    String? id,
    String? pollId,
    String? optionText,
    int? voteCount,
    bool? hasVoted,
  }) {
    return VotingOption(
      id: id ?? this.id,
      pollId: pollId ?? this.pollId,
      optionText: optionText ?? this.optionText,
      voteCount: voteCount ?? this.voteCount,
      hasVoted: hasVoted ?? this.hasVoted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is VotingOption &&
        other.id == id &&
        other.pollId == pollId &&
        other.optionText == optionText;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        pollId.hashCode ^
        optionText.hashCode;
  }
}
