import 'package:flutter/foundation.dart';

/// Model representing a chat message
class ChatMessage {
  /// Unique identifier for the message
  final String id;
  
  /// ID of the room this message belongs to
  final String roomId;
  
  /// ID of the user who sent the message
  final String senderId;
  
  /// Username of the sender
  final String senderUsername;
  
  /// Content of the message
  final String content;
  
  /// Timestamp when the message was created
  final DateTime createdAt;
  
  /// Whether the message was sent by the current user
  final bool isMine;

  /// Constructor
  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderUsername,
    required this.content,
    required this.createdAt,
    required this.isMine,
  });

  /// Create a ChatMessage from a map
  factory ChatMessage.fromMap({
    required Map<String, dynamic> map,
    required String currentUserId,
  }) {
    return ChatMessage(
      id: map['id'],
      roomId: map['room_id'],
      senderId: map['sender_id'],
      senderUsername: map['sender_username'] ?? 'Unknown',
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      isMine: currentUserId == map['sender_id'],
    );
  }

  /// Convert message to a map for sending to the API
  Map<String, dynamic> toMap() {
    return {
      'room_id': roomId,
      'content': content,
    };
  }

  /// Create a copy of this message with updated fields
  ChatMessage copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? senderUsername,
    String? content,
    DateTime? createdAt,
    bool? isMine,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ChatMessage &&
        other.id == id &&
        other.roomId == roomId &&
        other.senderId == senderId &&
        other.content == content &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        roomId.hashCode ^
        senderId.hashCode ^
        content.hashCode ^
        createdAt.hashCode;
  }
}
