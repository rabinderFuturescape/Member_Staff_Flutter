import 'package:flutter/foundation.dart';
import '../api/feature_request_api.dart';
import '../models/feature_request.dart';

/// Provider for managing feature request state.
class FeatureRequestProvider with ChangeNotifier {
  final FeatureRequestApi _api;
  
  List<FeatureRequest> _featureRequests = [];
  List<FeatureRequest> _suggestions = [];
  bool _isLoading = false;
  String? _error;
  
  /// Constructor
  FeatureRequestProvider({
    required FeatureRequestApi api,
  }) : _api = api;
  
  /// Getters
  List<FeatureRequest> get featureRequests => _featureRequests;
  List<FeatureRequest> get suggestions => _suggestions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Loads all feature requests.
  Future<void> loadFeatureRequests({
    String? sortBy = 'votes',
    String? sortOrder = 'desc',
    int? page = 1,
    int? perPage = 10,
  }) async {
    _setLoading(true);
    
    try {
      final requests = await _api.getFeatureRequests(
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        perPage: perPage,
      );
      
      _featureRequests = requests;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  /// Creates a new feature request.
  Future<FeatureRequest?> createFeatureRequest({
    required String featureTitle,
    String? description,
  }) async {
    _setLoading(true);
    
    try {
      final request = await _api.createFeatureRequest(
        featureTitle: featureTitle,
        description: description,
      );
      
      // Add to the list if it's not already there
      if (!_featureRequests.any((r) => r.id == request.id)) {
        _featureRequests = [request, ..._featureRequests];
      }
      
      _error = null;
      return request;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Upvotes an existing feature request.
  Future<bool> voteFeatureRequest(int id) async {
    _setLoading(true);
    
    try {
      final updatedRequest = await _api.voteFeatureRequest(id);
      
      // Update the list
      _featureRequests = _featureRequests.map((request) {
        if (request.id == id) {
          return updatedRequest;
        }
        return request;
      }).toList();
      
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Gets suggestions for feature requests based on a search term.
  Future<void> getSuggestions(String query) async {
    if (query.length < 2) {
      _suggestions = [];
      notifyListeners();
      return;
    }
    
    try {
      final suggestions = await _api.getSuggestions(query);
      _suggestions = suggestions;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }
  
  /// Clears suggestions.
  void clearSuggestions() {
    _suggestions = [];
    notifyListeners();
  }
  
  /// Sets the loading state and notifies listeners.
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
