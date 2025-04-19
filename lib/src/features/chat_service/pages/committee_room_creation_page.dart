import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_user.dart';
import '../providers/keycloak_chat_provider.dart';
import '../utils/chat_constants.dart';
import '../widgets/member_search_delegate.dart';

/// Page for creating a committee chat room
class CommitteeRoomCreationPage extends StatefulWidget {
  /// Constructor
  const CommitteeRoomCreationPage({Key? key}) : super(key: key);

  @override
  State<CommitteeRoomCreationPage> createState() => _CommitteeRoomCreationPageState();
}

class _CommitteeRoomCreationPageState extends State<CommitteeRoomCreationPage> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  /// Controller for the room name input
  final TextEditingController _nameController = TextEditingController();
  
  /// Controller for the room description input
  final TextEditingController _descriptionController = TextEditingController();
  
  /// Controller for the room topic input
  final TextEditingController _topicController = TextEditingController();
  
  /// Selected members for the room
  final List<ChatUser> _selectedMembers = [];
  
  /// Whether to invite all members
  bool _inviteAllMembers = false;
  
  /// Whether the form is being submitted
  bool _isSubmitting = false;

  /// Open the member search dialog
  Future<void> _openMemberSearch() async {
    final selectedMembers = await showSearch<List<ChatUser>>(
      context: context,
      delegate: MemberSearchDelegate(selectedMembers: List.from(_selectedMembers)),
    );
    
    if (selectedMembers != null) {
      setState(() {
        _selectedMembers.clear();
        _selectedMembers.addAll(selectedMembers);
      });
    }
  }

  /// Create a committee room
  Future<void> _createCommitteeRoom() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedMembers.isEmpty && !_inviteAllMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one member or invite all members'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = Provider.of<KeycloakChatProvider>(context, listen: false);
      
      // Get participant IDs
      final participantIds = _inviteAllMembers
          ? [] // Empty means all members in the API
          : _selectedMembers.map((member) => member.id).toList();
      
      await provider.createCommitteeRoom(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        topic: _topicController.text.trim().isNotEmpty
            ? _topicController.text.trim()
            : null,
        participantIds: participantIds,
      );

      // Navigate back to chat list
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Committee room created successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create committee room: $e'),
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
        title: Text('Create Committee Room'),
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
                hintText: 'Enter committee room name',
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
                hintText: 'Enter room description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLength: ChatConstants.maxRoomDescriptionLength,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: 'Topic',
                hintText: 'Enter discussion topic (optional)',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 16.0),
            Text(
              'Invite Members',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SwitchListTile(
              title: Text('Invite All Members'),
              subtitle: Text('All society members will be added to this room'),
              value: _inviteAllMembers,
              onChanged: (value) {
                setState(() {
                  _inviteAllMembers = value;
                });
              },
            ),
            if (!_inviteAllMembers) ...[
              OutlinedButton.icon(
                icon: Icon(Icons.search),
                label: Text('Search and Select Members'),
                onPressed: _openMemberSearch,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
              SizedBox(height: 8.0),
              _buildSelectedMembersList(),
            ],
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _createCommitteeRoom,
              child: _isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Create Committee Room'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the list of selected members
  Widget _buildSelectedMembersList() {
    if (_selectedMembers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No members selected',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Selected Members (${_selectedMembers.length}):',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: _selectedMembers.map((member) {
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: Colors.blue,
                child: member.avatarUrl != null
                    ? null
                    : Text(member.username.substring(0, 1).toUpperCase()),
                backgroundImage: member.avatarUrl != null
                    ? NetworkImage(member.avatarUrl!)
                    : null,
              ),
              label: Text(member.displayName ?? member.username),
              deleteIcon: Icon(Icons.close, size: 18.0),
              onDeleted: () {
                setState(() {
                  _selectedMembers.remove(member);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _topicController.dispose();
    super.dispose();
  }
}
