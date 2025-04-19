import 'package:flutter/foundation.dart';

/// Types of chat rooms
enum ChatRoomType {
  /// One-to-one direct message
  direct,
  
  /// Group chat with multiple participants
  group,
  
  /// Public discussion room
  public
}

/// Model representing a chat room
class ChatRoom {
  /// Unique identifier for the room
  final String id;
  
  /// Name of the room
  final String name;
  
  /// Description of the room
  final String? description;
  
  /// Type of the room (direct, group, public)
  final ChatRoomType type;
  
  /// ID of the user who created the room
  final String createdById;
  
  /// Timestamp when the room was created
  final DateTime createdAt;
  
  /// Last message in the room (for preview)
  final String? lastMessageContent;
  
  /// Timestamp of the last message
  final DateTime? lastMessageAt;
  
  /// Number of unread messages
  final int unreadCount;
  
  /// List of participant IDs
  final List<String> participantIds;

  /// Constructor
  ChatRoom({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.createdById,
    required this.createdAt,
    this.lastMessageContent,
    this.lastMessageAt,
    this.unreadCount = 0,
    required this.participantIds,
  });

  /// Create a ChatRoom from a map
  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      type: ChatRoomType.values.firstWhere(
        (e) => e.toString() == 'ChatRoomType.${map['type']}',
        orElse: () => ChatRoomType.group,
      ),
      createdById: map['created_by_id'],
      createdAt: DateTime.parse(map['created_at']),
      lastMessageContent: map['last_message_content'],
      lastMessageAt: map['last_message_at'] != null
          ? DateTime.parse(map['last_message_at'])
          : null,
      unreadCount: map['unread_count'] ?? 0,
      participantIds: List<String>.from(map['participant_ids'] ?? []),
    );
  }

  /// Convert room to a map for sending to the API
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
    };
  }

  /// Create a copy of this room with updated fields
  ChatRoom copyWith({
    String? id,
    String? name,
    String? description,
    ChatRoomType? type,
    String? createdById,
    DateTime? createdAt,
    String? lastMessageContent,
    DateTime? lastMessageAt,
    int? unreadCount,
    List<String>? participantIds,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      createdById: createdById ?? this.createdById,
      createdAt: createdAt ?? this.createdAt,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      participantIds: participantIds ?? this.participantIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ChatRoom &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.createdById == createdById;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        createdById.hashCode;
  }
}
