import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_user.dart';
import '../providers/keycloak_chat_provider.dart';

/// Search delegate for finding and selecting members
class MemberSearchDelegate extends SearchDelegate<List<ChatUser>> {
  /// List of already selected members
  final List<ChatUser> selectedMembers;
  
  /// Constructor
  MemberSearchDelegate({
    this.selectedMembers = const [],
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, selectedMembers);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  /// Build the search results list
  Widget _buildSearchResults(BuildContext context) {
    final provider = Provider.of<KeycloakChatProvider>(context, listen: false);
    
    if (query.length < 2) {
      return Center(
        child: Text('Enter at least 2 characters to search'),
      );
    }
    
    // Trigger search
    provider.searchMembers(query);
    
    return Consumer<KeycloakChatProvider>(
      builder: (context, provider, child) {
        final results = provider.searchResults;
        
        if (results.isEmpty) {
          return Center(
            child: Text('No members found for "$query"'),
          );
        }
        
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final member = results[index];
            final isSelected = selectedMembers.any((m) => m.id == member.id);
            
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: member.avatarUrl != null
                    ? null
                    : Text(member.username.substring(0, 1).toUpperCase()),
                backgroundImage: member.avatarUrl != null
                    ? NetworkImage(member.avatarUrl!)
                    : null,
              ),
              title: Text(member.displayName ?? member.username),
              subtitle: Text(member.username),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                // Toggle selection
                if (isSelected) {
                  selectedMembers.removeWhere((m) => m.id == member.id);
                } else {
                  selectedMembers.add(member);
                }
                
                // Refresh the UI
                close(context, selectedMembers);
              },
            );
          },
        );
      },
    );
  }
}
