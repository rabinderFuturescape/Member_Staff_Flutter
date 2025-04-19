import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_room.dart';
import '../providers/chat_provider.dart';
import '../utils/chat_constants.dart';

/// Page for creating a new chat room
class CreateRoomPage extends StatefulWidget {
  /// Constructor
  const CreateRoomPage({Key? key}) : super(key: key);

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  /// Controller for the room name input
  final TextEditingController _nameController = TextEditingController();
  
  /// Controller for the room description input
  final TextEditingController _descriptionController = TextEditingController();
  
  /// Selected room type
  ChatRoomType _roomType = ChatRoomType.group;
  
  /// Whether the form is being submitted
  bool _isSubmitting = false;

  /// Create a new room
  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final room = await context.read<ChatProvider>().createRoom(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        type: _roomType,
        participantIds: [], // Empty for now, could add user selection later
      );

      // Navigate back to chat list
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ChatConstants.roomCreatedSuccess),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ChatConstants.errorCreatingRoom),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ChatConstants.createRoomTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Room Name',
                hintText: ChatConstants.roomNamePlaceholder,
                border: OutlineInputBorder(),
              ),
              maxLength: ChatConstants.maxRoomNameLength,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a room name';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: ChatConstants.roomDescriptionPlaceholder,
                border: OutlineInputBorder(),
              ),
              maxLength: ChatConstants.maxRoomDescriptionLength,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 16.0),
            Text(
              'Room Type',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildRoomTypeSelector(),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _createRoom,
              child: _isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(ChatConstants.createRoomButtonLabel),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the room type selector
  Widget _buildRoomTypeSelector() {
    return Column(
      children: [
        RadioListTile<ChatRoomType>(
          title: Text('Direct Message'),
          subtitle: Text('Private conversation between two people'),
          value: ChatRoomType.direct,
          groupValue: _roomType,
          onChanged: (value) {
            setState(() {
              _roomType = value!;
            });
          },
        ),
        RadioListTile<ChatRoomType>(
          title: Text('Group Chat'),
          subtitle: Text('Private conversation with multiple people'),
          value: ChatRoomType.group,
          groupValue: _roomType,
          onChanged: (value) {
            setState(() {
              _roomType = value!;
            });
          },
        ),
        RadioListTile<ChatRoomType>(
          title: Text('Public Room'),
          subtitle: Text('Open discussion that anyone can join'),
          value: ChatRoomType.public,
          groupValue: _roomType,
          onChanged: (value) {
            setState(() {
              _roomType = value!;
            });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
