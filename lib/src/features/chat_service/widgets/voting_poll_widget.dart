import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/voting_poll.dart';
import '../models/voting_option.dart';
import '../providers/keycloak_chat_provider.dart';

/// Widget for displaying a voting poll
class VotingPollWidget extends StatefulWidget {
  /// The poll to display
  final VotingPoll poll;
  
  /// Whether the user is a committee member
  final bool isCommitteeMember;
  
  /// Whether the user created this poll
  final bool isCreator;

  /// Constructor
  const VotingPollWidget({
    Key? key,
    required this.poll,
    required this.isCommitteeMember,
    required this.isCreator,
  }) : super(key: key);

  @override
  State<VotingPollWidget> createState() => _VotingPollWidgetState();
}

class _VotingPollWidgetState extends State<VotingPollWidget> {
  /// Whether the poll is being closed
  bool _isClosing = false;
  
  /// Whether a vote is being submitted
  bool _isVoting = false;
  
  /// The selected option ID
  String? _selectedOptionId;
  
  @override
  void initState() {
    super.initState();
    
    // Set initial selected option if user has already voted
    for (final option in widget.poll.options) {
      if (option.hasVoted) {
        _selectedOptionId = option.id;
        break;
      }
    }
  }

  /// Calculate the total number of votes
  int get _totalVotes {
    return widget.poll.options.fold(0, (sum, option) => sum + option.voteCount);
  }

  /// Calculate the percentage of votes for an option
  double _calculatePercentage(int voteCount) {
    if (_totalVotes == 0) return 0.0;
    return (voteCount / _totalVotes) * 100;
  }

  /// Format a percentage value
  String _formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Vote for an option
  Future<void> _vote(String optionId) async {
    if (_isVoting || !widget.poll.isActive) return;
    
    setState(() {
      _isVoting = true;
      _selectedOptionId = optionId;
    });

    try {
      final provider = Provider.of<KeycloakChatProvider>(context, listen: false);
      
      await provider.voteOnPoll(
        pollId: widget.poll.id,
        optionId: optionId,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to vote: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Reset selection on error
      setState(() {
        _selectedOptionId = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    }
  }

  /// Close the poll
  Future<void> _closePoll() async {
    if (_isClosing) return;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Close Poll'),
        content: Text('Are you sure you want to close this poll? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Close Poll'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isClosing = true;
    });

    try {
      final provider = Provider.of<KeycloakChatProvider>(context, listen: false);
      
      await provider.closePoll(widget.poll.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to close poll: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isClosing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVoted = _selectedOptionId != null;
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.poll, color: theme.primaryColor),
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    widget.poll.question,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.0),
            Row(
              children: [
                Icon(
                  widget.poll.isActive ? Icons.check_circle : Icons.cancel,
                  size: 16.0,
                  color: widget.poll.isActive ? Colors.green : Colors.red,
                ),
                SizedBox(width: 4.0),
                Text(
                  widget.poll.isActive ? 'Active' : 'Closed',
                  style: TextStyle(
                    color: widget.poll.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.poll.endsAt != null) ...[
                  SizedBox(width: 8.0),
                  Icon(Icons.access_time, size: 16.0),
                  SizedBox(width: 4.0),
                  Text(
                    'Ends ${_formatEndDate(widget.poll.endsAt!)}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                Spacer(),
                Text(
                  '$_totalVotes ${_totalVotes == 1 ? 'vote' : 'votes'}',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Divider(),
            ..._buildOptions(hasVoted),
            SizedBox(height: 8.0),
            if (widget.poll.isActive && widget.isCreator)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.close),
                  label: Text('Close Poll'),
                  onPressed: _isClosing ? null : _closePoll,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build the options list
  List<Widget> _buildOptions(bool hasVoted) {
    return widget.poll.options.map((option) {
      final percentage = _calculatePercentage(option.voteCount);
      final isSelected = _selectedOptionId == option.id;
      
      if (hasVoted || !widget.poll.isActive) {
        // Results view
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isSelected)
                    Icon(Icons.check_circle, color: Colors.green, size: 16.0),
                  SizedBox(width: isSelected ? 4.0 : 0.0),
                  Expanded(
                    child: Text(
                      option.optionText,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    '${option.voteCount} (${_formatPercentage(percentage)})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.0),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                color: isSelected ? Colors.green : Theme.of(context).primaryColor,
              ),
            ],
          ),
        );
      } else {
        // Voting view
        return RadioListTile<String>(
          title: Text(option.optionText),
          value: option.id,
          groupValue: _selectedOptionId,
          onChanged: _isVoting ? null : (value) => _vote(value!),
          activeColor: Theme.of(context).primaryColor,
          dense: true,
        );
      }
    }).toList();
  }

  /// Format the end date for display
  String _formatEndDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inDays > 0) {
      return 'in ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      return 'soon';
    }
  }
}
