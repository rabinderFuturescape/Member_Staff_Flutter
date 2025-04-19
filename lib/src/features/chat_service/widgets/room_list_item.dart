import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/chat_room.dart';

/// Widget for displaying a chat room in a list
class RoomListItem extends StatelessWidget {
  /// The room to display
  final ChatRoom room;

  /// Callback when the room is tapped
  final VoidCallback onTap;

  /// Constructor
  const RoomListItem({
    Key? key,
    required this.room,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: _buildAvatar(),
      title: Text(
        room.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: room.lastMessageContent != null
          ? Text(
              room.lastMessageContent!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              'No messages yet',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (room.lastMessageAt != null)
            Text(
              timeago.format(room.lastMessageAt!, locale: 'en_short'),
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey[600],
              ),
            ),
          SizedBox(height: 4.0),
          if (room.unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                room.unreadCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build the avatar for the room
  Widget _buildAvatar() {
    final roomType = room.type;

    IconData iconData;
    Color backgroundColor;

    switch (roomType) {
      case ChatRoomType.direct:
        iconData = Icons.person;
        backgroundColor = Colors.blue;
        break;
      case ChatRoomType.group:
        iconData = Icons.group;
        backgroundColor = Colors.green;
        break;
      case ChatRoomType.public:
        iconData = Icons.public;
        backgroundColor = Colors.orange;
        break;
      case ChatRoomType.committee:
        iconData = Icons.people_alt;
        backgroundColor = Colors.purple;
        break;
    }

    return CircleAvatar(
      backgroundColor: backgroundColor,
      child: Icon(
        iconData,
        color: Colors.white,
      ),
    );
  }
}
