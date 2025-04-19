import 'package:flutter/material.dart';

/// Constants for the chat service feature
class ChatConstants {
  /// Private constructor to prevent instantiation
  ChatConstants._();

  /// Routes
  static const String chatListRoute = '/chat';
  static const String chatRoomRoute = '/chat/room';
  static const String createRoomRoute = '/chat/create';

  /// Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color myMessageColor = Color(0xFFE3F2FD);
  static const Color otherMessageColor = Color(0xFFFFFFFF);

  /// Sizes
  static const double messageBubbleRadius = 16.0;
  static const double messageBubblePadding = 12.0;
  static const double messageInputHeight = 60.0;
  static const double messageInputRadius = 24.0;
  static const double messageInputPadding = 8.0;

  /// Durations
  static const Duration messageAnimationDuration = Duration(milliseconds: 300);
  static const Duration typingIndicatorDuration = Duration(milliseconds: 500);

  /// Limits
  static const int maxMessageLength = 1000;
  static const int maxRoomNameLength = 50;
  static const int maxRoomDescriptionLength = 200;

  /// Error messages
  static const String errorLoadingRooms = 'Failed to load chat rooms';
  static const String errorLoadingMessages = 'Failed to load messages';
  static const String errorSendingMessage = 'Failed to send message';
  static const String errorCreatingRoom = 'Failed to create chat room';
  static const String errorJoiningRoom = 'Failed to join chat room';
  static const String errorLeavingRoom = 'Failed to leave chat room';
  static const String errorAuthentication = 'Authentication failed';
  static const String errorTokenExpired = 'Your session has expired. Please log in again.';

  /// Success messages
  static const String roomCreatedSuccess = 'Chat room created successfully';
  static const String roomJoinedSuccess = 'Joined chat room successfully';
  static const String roomLeftSuccess = 'Left chat room successfully';

  /// Placeholders
  static const String messageInputPlaceholder = 'Type a message...';
  static const String roomNamePlaceholder = 'Enter room name';
  static const String roomDescriptionPlaceholder = 'Enter room description (optional)';
  static const String noRoomsPlaceholder = 'No chat rooms yet';
  static const String noMessagesPlaceholder = 'No messages yet';

  /// Button labels
  static const String sendButtonLabel = 'Send';
  static const String createRoomButtonLabel = 'Create Room';
  static const String joinRoomButtonLabel = 'Join';
  static const String leaveRoomButtonLabel = 'Leave';
  static const String loginButtonLabel = 'Login';
  static const String retryButtonLabel = 'Retry';

  /// Screen titles
  static const String chatListTitle = 'Chats';
  static const String createRoomTitle = 'Create Chat Room';

  /// Authentication
  static const String supabaseTokenKey = 'supabase_token';
  static const String chatUserKey = 'chat_user';

  /// Supabase Configuration
  // These would typically come from environment variables or a config file
  static const String supabaseUrl = 'https://your-supabase-url.supabase.co';
  static const String supabaseAnonKey = 'your-supabase-anon-key';

  /// OneSSO Integration
  static const String oneSSOLoginRoute = '/onessoLogin';
  static const String oneSSOCallbackRoute = '/onessoCallback';
}
