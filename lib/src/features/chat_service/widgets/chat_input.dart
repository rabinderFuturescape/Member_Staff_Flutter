import 'package:flutter/material.dart';
import '../utils/chat_constants.dart';

/// Widget for chat message input
class ChatInput extends StatefulWidget {
  /// Callback when a message is sent
  final Function(String) onSendMessage;
  
  /// Constructor
  const ChatInput({
    Key? key,
    required this.onSendMessage,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  /// Controller for the text input
  final TextEditingController _controller = TextEditingController();
  
  /// Focus node for the text input
  final FocusNode _focusNode = FocusNode();
  
  /// Whether the input is empty
  bool _isEmpty = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  /// Handle text changes
  void _onTextChanged() {
    setState(() {
      _isEmpty = _controller.text.trim().isEmpty;
    });
  }

  /// Send the message
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3.0,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ChatConstants.messageInputPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(
                  ChatConstants.messageInputRadius,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: ChatConstants.messageInputPlaceholder,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 8.0,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          SizedBox(width: 8.0),
          AnimatedOpacity(
            opacity: _isEmpty ? 0.5 : 1.0,
            duration: Duration(milliseconds: 200),
            child: IconButton(
              icon: Icon(Icons.send_rounded),
              color: ChatConstants.primaryColor,
              onPressed: _isEmpty ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
