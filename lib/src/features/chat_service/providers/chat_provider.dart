import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api/chat_api.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/chat_user.dart';

/// Provider for chat state management
class ChatProvider extends ChangeNotifier {
  /// API service for chat functionality
  final ChatApi _chatApi;
  
  /// List of chat rooms
  List<ChatRoom> _rooms = [];
  
  /// Currently selected room
  ChatRoom? _selectedRoom;
  
  /// Messages in the selected room
  List<ChatMessage> _messages = [];
  
  /// Current user
  ChatUser? _currentUser;
  
  /// Loading state for rooms
  bool _loadingRooms = false;
  
  /// Loading state for messages
  bool _loadingMessages = false;
  
  /// Error message for rooms
  String? _roomsError;
  
  /// Error message for messages
  String? _messagesError;
  
  /// Subscription for room updates
  StreamSubscription<List<ChatRoom>>? _roomsSubscription;
  
  /// Subscription for message updates
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;

  /// Constructor
  ChatProvider({
    required SupabaseClient supabase,
    required String currentUserId,
  }) : _chatApi = ChatApi(
          supabase: supabase,
          currentUserId: currentUserId,
        );

  /// Get all rooms
  List<ChatRoom> get rooms => _rooms;
  
  /// Get selected room
  ChatRoom? get selectedRoom => _selectedRoom;
  
  /// Get messages in selected room
  List<ChatMessage> get messages => _messages;
  
  /// Get current user
  ChatUser? get currentUser => _currentUser;
  
  /// Check if rooms are loading
  bool get loadingRooms => _loadingRooms;
  
  /// Check if messages are loading
  bool get loadingMessages => _loadingMessages;
  
  /// Get error message for rooms
  String? get roomsError => _roomsError;
  
  /// Get error message for messages
  String? get messagesError => _messagesError;

  /// Initialize the provider
  Future<void> initialize() async {
    await _loadCurrentUser();
    await _loadRooms();
  }

  /// Load the current user
  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _chatApi.getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading current user: $e');
    }
  }

  /// Load all rooms
  Future<void> _loadRooms() async {
    _loadingRooms = true;
    _roomsError = null;
    notifyListeners();

    try {
      _rooms = await _chatApi.getRooms();
      _subscribeToRooms();
      _loadingRooms = false;
      notifyListeners();
    } catch (e) {
      _loadingRooms = false;
      _roomsError = 'Failed to load chat rooms: $e';
      notifyListeners();
      debugPrint('Error loading rooms: $e');
    }
  }

  /// Subscribe to room updates
  void _subscribeToRooms() {
    _roomsSubscription?.cancel();
    _roomsSubscription = _chatApi.subscribeToRooms().listen(
      (updatedRooms) {
        _rooms = updatedRooms;
        
        // Update selected room if it's in the updated list
        if (_selectedRoom != null) {
          final updatedRoom = _rooms.firstWhere(
            (room) => room.id == _selectedRoom!.id,
            orElse: () => _selectedRoom!,
          );
          _selectedRoom = updatedRoom;
        }
        
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error in rooms subscription: $error');
      },
    );
  }

  /// Select a room and load its messages
  Future<void> selectRoom(String roomId) async {
    final room = _rooms.firstWhere((room) => room.id == roomId);
    _selectedRoom = room;
    notifyListeners();
    
    await _loadMessages(roomId);
  }

  /// Load messages for a room
  Future<void> _loadMessages(String roomId) async {
    _loadingMessages = true;
    _messagesError = null;
    _messages = [];
    notifyListeners();

    try {
      _messages = await _chatApi.getMessages(roomId);
      _subscribeToMessages(roomId);
      _loadingMessages = false;
      notifyListeners();
    } catch (e) {
      _loadingMessages = false;
      _messagesError = 'Failed to load messages: $e';
      notifyListeners();
      debugPrint('Error loading messages: $e');
    }
  }

  /// Subscribe to message updates
  void _subscribeToMessages(String roomId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatApi.subscribeToMessages(roomId).listen(
      (updatedMessages) {
        _messages = updatedMessages;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error in messages subscription: $error');
      },
    );
  }

  /// Send a message
  Future<void> sendMessage(String content) async {
    if (_selectedRoom == null) return;
    
    try {
      await _chatApi.sendMessage(
        roomId: _selectedRoom!.id,
        content: content,
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  /// Create a new room
  Future<ChatRoom> createRoom({
    required String name,
    String? description,
    required ChatRoomType type,
    required List<String> participantIds,
  }) async {
    try {
      final room = await _chatApi.createRoom(
        name: name,
        description: description,
        type: type,
        participantIds: participantIds,
      );
      
      // Refresh rooms list
      await _loadRooms();
      
      return room;
    } catch (e) {
      debugPrint('Error creating room: $e');
      rethrow;
    }
  }

  /// Join a room
  Future<void> joinRoom(String roomId) async {
    try {
      await _chatApi.joinRoom(roomId);
      await _loadRooms();
    } catch (e) {
      debugPrint('Error joining room: $e');
      rethrow;
    }
  }

  /// Leave a room
  Future<void> leaveRoom(String roomId) async {
    try {
      await _chatApi.leaveRoom(roomId);
      
      // If the current room is being left, clear selection
      if (_selectedRoom?.id == roomId) {
        _selectedRoom = null;
        _messages = [];
        _messagesSubscription?.cancel();
      }
      
      await _loadRooms();
    } catch (e) {
      debugPrint('Error leaving room: $e');
      rethrow;
    }
  }

  /// Clean up resources
  @override
  void dispose() {
    _roomsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
