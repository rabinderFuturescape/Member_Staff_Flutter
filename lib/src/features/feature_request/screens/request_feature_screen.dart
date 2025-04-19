import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/feature_request_provider.dart';
import '../models/feature_request.dart';
import '../widgets/feature_request_item.dart';
import '../widgets/feature_request_form.dart';
import '../../../widgets/app_text_field.dart';

/// Screen for requesting features.
class RequestFeatureScreen extends StatefulWidget {
  const RequestFeatureScreen({Key? key}) : super(key: key);

  @override
  State<RequestFeatureScreen> createState() => _RequestFeatureScreenState();
}

class _RequestFeatureScreenState extends State<RequestFeatureScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    // Load feature requests when the screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeatureRequestProvider>(context, listen: false)
          .loadFeatureRequests();
    });

    // Add listener to search controller for suggestions
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Called when the search text changes.
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        Provider.of<FeatureRequestProvider>(context, listen: false)
            .getSuggestions(_searchController.text);
        setState(() {
          _showSuggestions = true;
        });
      } else {
        Provider.of<FeatureRequestProvider>(context, listen: false)
            .clearSuggestions();
        setState(() {
          _showSuggestions = false;
        });
      }
    });
  }

  /// Handles selecting a suggestion.
  void _onSuggestionSelected(FeatureRequest suggestion) {
    _searchController.text = suggestion.featureTitle;
    setState(() {
      _showSuggestions = false;
    });
  }

  /// Handles submitting a new feature request.
  Future<void> _submitFeatureRequest() async {
    if (_searchController.text.isEmpty) return;

    final provider =
        Provider.of<FeatureRequestProvider>(context, listen: false);

    // Check if there are any suggestions that match exactly
    final exactMatch = provider.suggestions.any(
        (suggestion) => suggestion.featureTitle == _searchController.text);

    if (exactMatch) {
      // Find the matching suggestion
      final suggestion = provider.suggestions.firstWhere(
          (suggestion) => suggestion.featureTitle == _searchController.text);

      // Vote for the existing feature
      await provider.voteFeatureRequest(suggestion.id!);
      _searchController.clear();
      setState(() {
        _showSuggestions = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vote added to existing feature request'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show dialog to create a new feature request
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => FeatureRequestForm(
          initialTitle: _searchController.text,
          onSubmit: (title, description) async {
            final result = await provider.createFeatureRequest(
              featureTitle: title,
              description: description,
            );

            if (result != null && mounted) {
              Navigator.of(context).pop();
              _searchController.clear();
              setState(() {
                _showSuggestions = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature request submitted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request a Feature'),
      ),
      body: Consumer<FeatureRequestProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: 'Search for a feature',
                      hint: 'Type to search or request a new feature',
                      controller: _searchController,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _submitFeatureRequest,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _submitFeatureRequest,
                      child: const Text('Request Feature'),
                    ),
                  ],
                ),
              ),

              // Suggestions
              if (_showSuggestions && provider.suggestions.isNotEmpty)
                Container(
                  color: Colors.white,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = provider.suggestions[index];
                      return ListTile(
                        title: Text(suggestion.featureTitle),
                        subtitle: Text('${suggestion.votes} votes'),
                        onTap: () => _onSuggestionSelected(suggestion),
                        trailing: TextButton(
                          onPressed: () async {
                            await provider.voteFeatureRequest(suggestion.id!);
                            setState(() {
                              _showSuggestions = false;
                            });
                            _searchController.clear();
                          },
                          child: const Text('Vote'),
                        ),
                      );
                    },
                  ),
                ),

              // Feature request list
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                        ? Center(
                            child: Text(
                              'Error: ${provider.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        : provider.featureRequests.isEmpty
                            ? const Center(
                                child: Text('No feature requests yet'),
                              )
                            : ListView.builder(
                                itemCount: provider.featureRequests.length,
                                itemBuilder: (context, index) {
                                  final request =
                                      provider.featureRequests[index];
                                  return FeatureRequestItem(
                                    featureRequest: request,
                                    onVote: () async {
                                      await provider
                                          .voteFeatureRequest(request.id!);
                                    },
                                  );
                                },
                              ),
              ),
            ],
          );
        },
      ),
    );
  }
}
