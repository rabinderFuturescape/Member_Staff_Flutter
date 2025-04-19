import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/feature_request.dart';
import '../../../core/network/api_client.dart';
import '../../../core/exceptions/api_exception.dart';

/// Service for interacting with the feature request API.
class FeatureRequestApi {
  final ApiClient _apiClient;

  FeatureRequestApi({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  /// Fetches all feature requests.
  Future<List<FeatureRequest>> getFeatureRequests({
    String? sortBy = 'votes',
    String? sortOrder = 'desc',
    int? page = 1,
    int? perPage = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        'feature-requests',
        queryParams: {
          'sort_by': sortBy,
          'sort_order': sortOrder,
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      final List<dynamic> data = response['data'];
      return data.map((item) => FeatureRequest.fromJson(item)).toList();
    } catch (e) {
      throw ApiException(message: 'Failed to load feature requests: $e');
    }
  }

  /// Creates a new feature request.
  Future<FeatureRequest> createFeatureRequest({
    required String featureTitle,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post(
        'feature-requests',
        body: {
          'feature_title': featureTitle,
          if (description != null) 'description': description,
        },
      );

      return FeatureRequest.fromJson(response['data']);
    } catch (e) {
      throw ApiException(message: 'Failed to create feature request: $e');
    }
  }

  /// Upvotes an existing feature request.
  Future<FeatureRequest> voteFeatureRequest(int id) async {
    try {
      final response = await _apiClient.post(
        'feature-requests/$id/vote',
      );

      return FeatureRequest.fromJson(response['data']);
    } catch (e) {
      throw ApiException(message: 'Failed to vote for feature request: $e');
    }
  }

  /// Gets suggestions for feature requests based on a search term.
  Future<List<FeatureRequest>> getSuggestions(String query) async {
    if (query.length < 2) {
      return [];
    }

    try {
      final response = await _apiClient.get(
        'feature-requests/suggest',
        queryParams: {'q': query},
      );

      final List<dynamic> data = response['data'];
      return data.map((item) => FeatureRequest.fromJson(item)).toList();
    } catch (e) {
      throw ApiException(message: 'Failed to get suggestions: $e');
    }
  }
}
