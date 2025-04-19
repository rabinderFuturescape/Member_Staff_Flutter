import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/chat_message.dart';
import '../utils/chat_constants.dart';

/// Widget for displaying a chat message bubble
class ChatBubble extends StatelessWidget {
  /// The message to display
  final ChatMessage message;
  
  /// Constructor
  const ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 4.0,
          horizontal: 8.0,
        ),
        padding: EdgeInsets.all(ChatConstants.messageBubblePadding),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isMine
              ? ChatConstants.myMessageColor
              : ChatConstants.otherMessageColor,
          borderRadius: BorderRadius.circular(ChatConstants.messageBubbleRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2.0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message.senderUsername,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.0),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                timeago.format(message.createdAt, locale: 'en_short'),
                style: TextStyle(
                  fontSize: 10.0,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
