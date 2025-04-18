import 'package:flutter/foundation.dart';
import '../api/staff_rating_api.dart';
import '../models/staff_rating.dart';
import '../models/rating_summary.dart';

class StaffRatingProvider with ChangeNotifier {
  final StaffRatingApi _api;
  
  bool _isLoading = false;
  String? _error;
  Map<String, RatingSummary> _ratingSummaries = {};

  StaffRatingProvider({required StaffRatingApi api}) : _api = api;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get the rating summary for a staff member
  /// Returns cached data if available, otherwise fetches from API
  Future<RatingSummary> getRatingSummary({
    required int staffId,
    required String staffType,
    bool forceRefresh = false,
  }) async {
    final key = '${staffType}_$staffId';
    
    // Return cached data if available and not forcing refresh
    if (!forceRefresh && _ratingSummaries.containsKey(key)) {
      return _ratingSummaries[key]!;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final summary = await _api.getRatingSummary(staffId: staffId, staffType: staffType);
      _ratingSummaries[key] = summary;
      return summary;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submit a rating for a staff member
  Future<StaffRating> submitRating({
    required int staffId,
    required String staffType,
    required int rating,
    String? feedback,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _api.submitRating(
        staffId: staffId,
        staffType: staffType,
        rating: rating,
        feedback: feedback,
      );
      
      // Invalidate cache for this staff
      final key = '${staffType}_$staffId';
      _ratingSummaries.remove(key);
      
      return result;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear any cached data
  void clearCache() {
    _ratingSummaries.clear();
    notifyListeners();
  }
}
