import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../providers/chat_provider.dart';
import '../utils/chat_constants.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

/// Page for a chat room
class ChatRoomPage extends StatefulWidget {
  /// ID of the room to display
  final String roomId;
  
  /// Constructor
  const ChatRoomPage({
    Key? key,
    required this.roomId,
  }) : super(key: key);

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  /// Scroll controller for the messages list
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Select the room
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().selectRoom(widget.roomId);
    });
  }

  /// Send a message
  Future<void> _sendMessage(String content) async {
    try {
      await context.read<ChatProvider>().sendMessage(content);
      // Scroll to bottom after sending
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ChatConstants.errorSendingMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Leave the room
  Future<void> _leaveRoom(BuildContext context, String roomId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Room'),
        content: Text('Are you sure you want to leave this chat room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Leave'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<ChatProvider>().leaveRoom(roomId);
        Navigator.pop(context); // Go back to chat list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ChatConstants.roomLeftSuccess),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ChatConstants.errorLeavingRoom),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Scroll to the bottom of the messages list
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final room = chatProvider.selectedRoom;
        final messages = chatProvider.messages;
        final isLoading = chatProvider.loadingMessages;
        final error = chatProvider.messagesError;

        return Scaffold(
          appBar: AppBar(
            title: room != null
                ? Text(room.name)
                : Text('Loading...'),
            actions: [
              if (room != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'leave') {
                      _leaveRoom(context, room.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'leave',
                      child: Text(ChatConstants.leaveRoomButtonLabel),
                    ),
                  ],
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: _buildMessagesList(
                  isLoading: isLoading,
                  error: error,
                  messages: messages,
                ),
              ),
              ChatInput(
                onSendMessage: _sendMessage,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build the messages list
  Widget _buildMessagesList({
    required bool isLoading,
    required String? error,
    required List<ChatMessage> messages,
  }) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              error,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => context.read<ChatProvider>().selectRoom(widget.roomId),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (messages.isEmpty) {
      return Center(
        child: Text(
          ChatConstants.noMessagesPlaceholder,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // Scroll to bottom when messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatBubble(message: message);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
