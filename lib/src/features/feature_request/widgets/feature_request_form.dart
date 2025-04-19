import 'package:flutter/material.dart';
import '../../../widgets/app_text_field.dart';

/// Form for creating a new feature request.
class FeatureRequestForm extends StatefulWidget {
  final String initialTitle;
  final Function(String title, String? description) onSubmit;

  const FeatureRequestForm({
    Key? key,
    required this.initialTitle,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<FeatureRequestForm> createState() => _FeatureRequestFormState();
}

class _FeatureRequestFormState extends State<FeatureRequestForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Validates and submits the form.
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await widget.onSubmit(
          _titleController.text,
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request a New Feature'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Feature Title',
                hint: 'Enter a title for your feature request',
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description (Optional)',
                hint: 'Provide more details about your feature request',
                controller: _descriptionController,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Submit Request'),
        ),
      ],
    );
  }
}
