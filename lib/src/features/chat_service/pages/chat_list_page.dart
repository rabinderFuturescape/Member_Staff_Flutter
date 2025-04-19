import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_room.dart';
import '../providers/chat_provider.dart';
import '../utils/chat_constants.dart';
import '../widgets/room_list_item.dart';
import 'chat_room_page.dart';
import 'create_room_page.dart';

/// Page displaying the list of chat rooms
class ChatListPage extends StatefulWidget {
  /// Constructor
  const ChatListPage({Key? key}) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    // Initialize the chat provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().initialize();
    });
  }

  /// Navigate to the chat room page
  void _navigateToChatRoom(BuildContext context, String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(roomId: roomId),
      ),
    );
  }

  /// Navigate to the create room page
  void _navigateToCreateRoom(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRoomPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ChatConstants.chatListTitle),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.loadingRooms) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (chatProvider.roomsError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    chatProvider.roomsError!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => chatProvider.initialize(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final rooms = chatProvider.rooms;

          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ChatConstants.noRoomsPlaceholder,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => _navigateToCreateRoom(context),
                    child: Text('Create a Room'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return RoomListItem(
                room: room,
                onTap: () => _navigateToChatRoom(context, room.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateRoom(context),
        child: Icon(Icons.add),
        tooltip: 'Create a new chat room',
      ),
    );
  }
}
