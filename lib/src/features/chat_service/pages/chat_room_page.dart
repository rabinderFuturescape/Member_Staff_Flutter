import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';
import '../models/voting_poll.dart';
import '../providers/keycloak_chat_provider.dart';
import '../utils/chat_constants.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/voting_poll_creation_widget.dart';
import '../widgets/voting_poll_widget.dart';

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

  /// Whether the user is a committee member
  bool _isCommitteeMember = false;

  /// Whether to show the poll creation form
  bool _showPollCreation = false;

  @override
  void initState() {
    super.initState();
    // Select the room
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<KeycloakChatProvider>();
      await provider.selectRoom(widget.roomId);

      // Load polls if it's a committee room
      final room = provider.selectedRoom;
      if (room != null && room.isCommitteeRoom) {
        await provider.loadPollsForRoom(widget.roomId);
      }

      // Check if user is a committee member
      final isCommittee = await provider.isCommitteeMember();
      setState(() {
        _isCommitteeMember = isCommittee;
      });
    });
  }

  /// Send a message
  Future<void> _sendMessage(String content) async {
    try {
      await context.read<KeycloakChatProvider>().sendMessage(content);
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
        await context.read<KeycloakChatProvider>().leaveRoom(roomId);
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

  /// Create a new poll
  void _togglePollCreation() {
    setState(() {
      _showPollCreation = !_showPollCreation;
    });
  }

  /// Refresh polls
  Future<void> _refreshPolls() async {
    final provider = context.read<KeycloakChatProvider>();
    await provider.loadPollsForRoom(widget.roomId);
    setState(() {
      _showPollCreation = false;
    });
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
    return Consumer<KeycloakChatProvider>(
      builder: (context, chatProvider, child) {
        final room = chatProvider.selectedRoom;
        final messages = chatProvider.messages;
        final polls = chatProvider.polls;
        final isLoading = chatProvider.loadingMessages;
        final isPollsLoading = chatProvider.loadingPolls;
        final error = chatProvider.messagesError;
        final pollsError = chatProvider.pollsError;

        final isCommitteeRoom = room?.isCommitteeRoom ?? false;
        final isCreator = room?.createdById == chatProvider.currentUser?.id;

        return Scaffold(
          appBar: AppBar(
            title: room != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.name),
                      if (room.topic != null)
                        Text(
                          room.topic!,
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                    ],
                  )
                : Text('Loading...'),
            actions: [
              if (room != null && isCommitteeRoom && _isCommitteeMember)
                IconButton(
                  icon: Icon(Icons.poll),
                  tooltip: 'Create Poll',
                  onPressed: _togglePollCreation,
                ),
              if (room != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'leave') {
                      _leaveRoom(context, room.id);
                    } else if (value == 'refresh_polls' && isCommitteeRoom) {
                      _refreshPolls();
                    }
                  },
                  itemBuilder: (context) => [
                    if (isCommitteeRoom)
                      PopupMenuItem(
                        value: 'refresh_polls',
                        child: Text('Refresh Polls'),
                      ),
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
              if (isCommitteeRoom) ...[
                _buildPollsSection(
                  polls: polls,
                  isLoading: isPollsLoading,
                  error: pollsError,
                  isCommitteeMember: _isCommitteeMember,
                  isCreator: isCreator,
                ),
              ],
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

  /// Build the polls section
  Widget _buildPollsSection({
    required List<VotingPoll> polls,
    required bool isLoading,
    required String? error,
    required bool isCommitteeMember,
    required bool isCreator,
  }) {
    if (_showPollCreation && isCommitteeMember) {
      return Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create New Poll',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: _togglePollCreation,
                ),
              ],
            ),
            SizedBox(height: 8.0),
            VotingPollCreationWidget(
              roomId: widget.roomId,
              onComplete: _refreshPolls,
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return Container(
        height: 100.0,
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Failed to load polls: $error',
              style: TextStyle(color: Colors.red),
            ),
            TextButton(
              onPressed: _refreshPolls,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (polls.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            isCommitteeMember
                ? 'No polls yet. Create one using the poll button in the app bar.'
                : 'No polls available in this room yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Polls',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...polls.map((poll) => VotingPollWidget(
                poll: poll,
                isCommitteeMember: isCommitteeMember,
                isCreator: poll.createdById == context.read<KeycloakChatProvider>().currentUser?.id,
              )),
        ],
      ),
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
              onPressed: () => context.read<KeycloakChatProvider>().selectRoom(widget.roomId),
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
