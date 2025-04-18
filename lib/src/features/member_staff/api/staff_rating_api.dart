import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/staff_rating.dart';
import '../models/rating_summary.dart';
import '../../core/api/api_client.dart';
import '../../core/auth/auth_service.dart';

class StaffRatingApi {
  final ApiClient _apiClient;
  final AuthService _authService;

  StaffRatingApi({
    required ApiClient apiClient,
    required AuthService authService,
  })  : _apiClient = apiClient,
        _authService = authService;

  /// Submit a rating for a staff member
  Future<StaffRating> submitRating({
    required int staffId,
    required String staffType,
    required int rating,
    String? feedback,
  }) async {
    try {
      final memberId = await _authService.getCurrentMemberId();
      
      final response = await _apiClient.post(
        '/staff/rating',
        body: {
          'member_id': memberId,
          'staff_id': staffId,
          'staff_type': staffType,
          'rating': rating,
          'feedback': feedback,
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return StaffRating.fromJson(data['rating']);
      } else if (response.statusCode == 422) {
        // Handle validation errors
        final data = json.decode(response.body);
        if (data.containsKey('existing_rating')) {
          throw Exception('You have already rated this staff member in the last month.');
        } else {
          throw Exception('Validation error: ${data['errors']}');
        }
      } else {
        throw Exception('Failed to submit rating: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to submit rating: $e');
    }
  }

  /// Get rating summary for a staff member
  Future<RatingSummary> getRatingSummary({
    required int staffId,
    required String staffType,
  }) async {
    try {
      final response = await _apiClient.get(
        '/staff/$staffId/ratings?staff_type=$staffType',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RatingSummary.fromJson(data);
      } else {
        throw Exception('Failed to get rating summary: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get rating summary: $e');
    }
  }
}
