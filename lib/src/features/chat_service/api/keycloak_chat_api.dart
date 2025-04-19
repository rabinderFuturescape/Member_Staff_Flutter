import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/chat_user.dart';
import '../services/chat_auth_service.dart';
import '../utils/chat_constants.dart';

/// API service for chat functionality with Keycloak authentication
class KeycloakChatApi {
  /// Supabase client instance
  final SupabaseClient _supabase;
  
  /// Chat authentication service
  final ChatAuthService _authService;
  
  /// API base URL
  final String _baseUrl;
  
  /// Current user ID
  String? _currentUserId;
  
  /// Constructor
  KeycloakChatApi({
    required SupabaseClient supabase,
    required ChatAuthService authService,
    String baseUrl = 'https://api.oneapp.in/api',
  })  : _supabase = supabase,
        _authService = authService,
        _baseUrl = baseUrl;
  
  /// Initialize the API with the current user ID
  Future<void> initialize() async {
    _currentUserId = await _authService.getCurrentUserId();
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }
    
    // Initialize Supabase authentication with the OneSSO token
    await _authService.initializeSupabaseAuth();
  }
  
  /// Get the current user ID
  String get currentUserId {
    if (_currentUserId == null) {
      throw Exception('API not initialized. Call initialize() first.');
    }
    return _currentUserId!;
  }
  
  /// Get all chat rooms for the current user
  Future<List<ChatRoom>> getRooms() async {
    await _refreshTokenIfNeeded();
    
    final response = await _supabase
        .from('chat_room_participants')
        .select('room_id, chat_rooms(*)')
        .eq('user_id', currentUserId);

    final rooms = response.map((item) {
      final roomData = item['chat_rooms'] as Map<String, dynamic>;
      
      // Get participant IDs for this room
      final participantIds = _getParticipantIds(roomData['id']);
      
      return ChatRoom.fromMap({
        ...roomData,
        'participant_ids': participantIds,
      });
    }).toList();

    return rooms as List<ChatRoom>;
  }

  /// Get a specific chat room by ID
  Future<ChatRoom> getRoomById(String roomId) async {
    await _refreshTokenIfNeeded();
    
    final response = await _supabase
        .from('chat_rooms')
        .select()
        .eq('id', roomId)
        .single();

    // Get participant IDs for this room
    final participantIds = await _getParticipantIds(roomId);
    
    return ChatRoom.fromMap({
      ...response,
      'participant_ids': participantIds,
    });
  }

  /// Create a new chat room
  Future<ChatRoom> createRoom({
    required String name,
    String? description,
    required ChatRoomType type,
    required List<String> participantIds,
  }) async {
    await _refreshTokenIfNeeded();
    
    // First create the room
    final roomResponse = await _supabase.from('chat_rooms').insert({
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'created_by_id': currentUserId,
    }).select().single();

    final roomId = roomResponse['id'];

    // Then add all participants (including the creator)
    final allParticipants = [...participantIds, currentUserId];
    
    for (final userId in allParticipants) {
      await _supabase.from('chat_room_participants').insert({
        'room_id': roomId,
        'user_id': userId,
      });
    }

    return ChatRoom.fromMap({
      ...roomResponse,
      'participant_ids': allParticipants,
    });
  }

  /// Get messages for a specific room
  Future<List<ChatMessage>> getMessages(String roomId) async {
    await _refreshTokenIfNeeded();
    
    final response = await _supabase
        .from('chat_messages')
        .select('*, profiles:sender_id(username)')
        .eq('room_id', roomId)
        .order('created_at');

    return response.map((item) {
      final profileData = item['profiles'] as Map<String, dynamic>;
      
      return ChatMessage.fromMap(
        map: {
          ...item,
          'sender_username': profileData['username'],
        },
        currentUserId: currentUserId,
      );
    }).toList() as List<ChatMessage>;
  }

  /// Send a message to a room
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String content,
  }) async {
    await _refreshTokenIfNeeded();
    
    final response = await _supabase.from('chat_messages').insert({
      'room_id': roomId,
      'sender_id': currentUserId,
      'content': content,
    }).select('*, profiles:sender_id(username)').single();

    final profileData = response['profiles'] as Map<String, dynamic>;
    
    // Update the last message in the room
    await _supabase.from('chat_rooms').update({
      'last_message_content': content,
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', roomId);

    return ChatMessage.fromMap(
      map: {
        ...response,
        'sender_username': profileData['username'],
      },
      currentUserId: currentUserId,
    );
  }

  /// Get user profile by ID
  Future<ChatUser> getUserById(String userId) async {
    await _refreshTokenIfNeeded();
    
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return ChatUser.fromMap(response);
  }

  /// Get current user profile
  Future<ChatUser> getCurrentUser() async {
    return getUserById(currentUserId);
  }

  /// Join a room
  Future<void> joinRoom(String roomId) async {
    await _refreshTokenIfNeeded();
    
    await _supabase.from('chat_room_participants').insert({
      'room_id': roomId,
      'user_id': currentUserId,
    });
  }

  /// Leave a room
  Future<void> leaveRoom(String roomId) async {
    await _refreshTokenIfNeeded();
    
    await _supabase
        .from('chat_room_participants')
        .delete()
        .eq('room_id', roomId)
        .eq('user_id', currentUserId);
  }

  /// Subscribe to messages in a room
  Stream<List<ChatMessage>> subscribeToMessages(String roomId) {
    // Refresh token before subscribing
    _refreshTokenIfNeeded();
    
    return _supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at')
        .map((items) {
          return items.map((item) {
            return ChatMessage.fromMap(
              map: item,
              currentUserId: currentUserId,
            );
          }).toList();
        });
  }

  /// Subscribe to room updates
  Stream<List<ChatRoom>> subscribeToRooms() {
    // Refresh token before subscribing
    _refreshTokenIfNeeded();
    
    return _supabase
        .from('chat_room_participants')
        .stream(primaryKey: ['room_id', 'user_id'])
        .eq('user_id', currentUserId)
        .map((items) async {
          final rooms = <ChatRoom>[];
          for (final item in items) {
            final roomId = item['room_id'];
            try {
              final room = await getRoomById(roomId);
              rooms.add(room);
            } catch (e) {
              // Skip rooms that couldn't be loaded
            }
          }
          return rooms;
        })
        .asyncMap((event) async => await event);
  }

  /// Helper method to get participant IDs for a room
  Future<List<String>> _getParticipantIds(String roomId) async {
    final response = await _supabase
        .from('chat_room_participants')
        .select('user_id')
        .eq('room_id', roomId);

    return response.map((item) => item['user_id'] as String).toList();
  }
  
  /// Refresh the token if needed
  Future<void> _refreshTokenIfNeeded() async {
    final refreshed = await _authService.refreshTokenIfNeeded();
    if (!refreshed) {
      throw Exception(ChatConstants.errorTokenExpired);
    }
  }
  
  /// Create a user profile in Supabase if it doesn't exist
  Future<void> createUserProfileIfNeeded() async {
    try {
      // Get the current user from Keycloak
      final keycloakUser = await _authService.getCurrentUser();
      if (keycloakUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Check if the user profile exists in Supabase
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUserId)
          .maybeSingle();
      
      if (response == null) {
        // Create the user profile in Supabase
        await _supabase.from('profiles').insert({
          'id': currentUserId,
          'username': keycloakUser.username,
          'display_name': keycloakUser.displayName,
          'avatar_url': keycloakUser.avatarUrl,
        });
      }
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }
}
