import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/keycloak_chat_provider.dart';

/// Widget for creating a voting poll
class VotingPollCreationWidget extends StatefulWidget {
  /// ID of the room where the poll will be created
  final String roomId;
  
  /// Callback when poll creation is complete
  final VoidCallback? onComplete;

  /// Constructor
  const VotingPollCreationWidget({
    Key? key,
    required this.roomId,
    this.onComplete,
  }) : super(key: key);

  @override
  State<VotingPollCreationWidget> createState() => _VotingPollCreationWidgetState();
}

class _VotingPollCreationWidgetState extends State<VotingPollCreationWidget> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  /// Controller for the poll question input
  final TextEditingController _questionController = TextEditingController();
  
  /// List of option controllers
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  
  /// Whether the poll has an end date
  bool _hasEndDate = false;
  
  /// Selected end date
  DateTime? _endDate;
  
  /// Selected end time
  TimeOfDay? _endTime;
  
  /// Whether the form is being submitted
  bool _isSubmitting = false;

  /// Add a new option field
  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  /// Remove an option field
  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return; // Minimum 2 options
    
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  /// Pick end date
  Future<void> _pickEndDate() async {
    final initialDate = _endDate ?? DateTime.now().add(Duration(days: 1));
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(Duration(days: 365));
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
      
      // Pick time after date is selected
      await _pickEndTime();
    }
  }

  /// Pick end time
  Future<void> _pickEndTime() async {
    final initialTime = _endTime ?? TimeOfDay.now();
    
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (pickedTime != null) {
      setState(() {
        _endTime = pickedTime;
      });
    }
  }

  /// Get the combined end date and time
  DateTime? get _combinedEndDateTime {
    if (!_hasEndDate || _endDate == null || _endTime == null) return null;
    
    return DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
  }

  /// Format the end date and time for display
  String get _formattedEndDateTime {
    if (_endDate == null || _endTime == null) return 'Not set';
    
    final date = '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
    final time = '${_endTime!.hour}:${_endTime!.minute.toString().padLeft(2, '0')}';
    
    return '$date at $time';
  }

  /// Create the poll
  Future<void> _createPoll() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = Provider.of<KeycloakChatProvider>(context, listen: false);
      
      // Get non-empty options
      final options = _optionControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      
      if (options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please provide at least 2 options'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      await provider.createPoll(
        roomId: widget.roomId,
        question: _questionController.text.trim(),
        options: options,
        endsAt: _combinedEndDateTime,
      );

      // Call the completion callback
      widget.onComplete?.call();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Poll created successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create poll: $e'),
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a Poll',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _questionController,
            decoration: InputDecoration(
              labelText: 'Question',
              hintText: 'Enter your poll question',
              border: OutlineInputBorder(),
            ),
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a question';
              }
              return null;
            },
          ),
          SizedBox(height: 16.0),
          Text(
            'Options',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          ..._buildOptionFields(),
          SizedBox(height: 8.0),
          OutlinedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add Option'),
            onPressed: _addOption,
          ),
          SizedBox(height: 16.0),
          SwitchListTile(
            title: Text('Set End Date/Time'),
            subtitle: Text(_hasEndDate
                ? 'Poll ends on $_formattedEndDateTime'
                : 'Poll will remain active until manually closed'),
            value: _hasEndDate,
            onChanged: (value) {
              setState(() {
                _hasEndDate = value;
                if (value && _endDate == null) {
                  _pickEndDate();
                }
              });
            },
          ),
          if (_hasEndDate)
            OutlinedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text('Change End Date/Time'),
              onPressed: _pickEndDate,
            ),
          SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _createPoll,
            child: _isSubmitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('Create Poll'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the option input fields
  List<Widget> _buildOptionFields() {
    return List.generate(_optionControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _optionControllers[index],
                decoration: InputDecoration(
                  labelText: 'Option ${index + 1}',
                  hintText: 'Enter option ${index + 1}',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (index < 2 && (value == null || value.trim().isEmpty)) {
                    return 'Please enter at least 2 options';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 8.0),
            IconButton(
              icon: Icon(Icons.remove_circle_outline),
              onPressed: _optionControllers.length > 2
                  ? () => _removeOption(index)
                  : null,
              color: Colors.red,
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
