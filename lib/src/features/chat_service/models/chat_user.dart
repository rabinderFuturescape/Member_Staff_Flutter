import 'package:flutter/foundation.dart';

/// Model representing a chat user
class ChatUser {
  /// Unique identifier for the user
  final String id;
  
  /// Username of the user
  final String username;
  
  /// Display name of the user
  final String? displayName;
  
  /// Avatar URL of the user
  final String? avatarUrl;
  
  /// Whether the user is online
  final bool isOnline;
  
  /// Timestamp when the user was last active
  final DateTime? lastActive;
  
  /// Constructor
  ChatUser({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.isOnline = false,
    this.lastActive,
  });

  /// Create a ChatUser from a map
  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
      id: map['id'],
      username: map['username'],
      displayName: map['display_name'],
      avatarUrl: map['avatar_url'],
      isOnline: map['is_online'] ?? false,
      lastActive: map['last_active'] != null
          ? DateTime.parse(map['last_active'])
          : null,
    );
  }

  /// Convert user to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
      'last_active': lastActive?.toIso8601String(),
    };
  }

  /// Create a copy of this user with updated fields
  ChatUser copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    bool? isOnline,
    DateTime? lastActive,
  }) {
    return ChatUser(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ChatUser &&
        other.id == id &&
        other.username == username;
  }

  @override
  int get hashCode {
    return id.hashCode ^ username.hashCode;
  }
}
