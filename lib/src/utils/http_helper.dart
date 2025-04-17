import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exception.dart';
import '../services/auth_service.dart';

/// Helper class for making HTTP requests with authentication and error handling.
class HttpHelper {
  final http.Client _client;
  final AuthService _authService;

  HttpHelper({
    http.Client? client,
    AuthService? authService,
  })  : _client = client ?? http.Client(),
        _authService = authService ?? AuthService();

  /// Makes a GET request to the specified URL.
  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    final requestHeaders = await _prepareHeaders(headers);
    final response = await _client.get(Uri.parse(url), headers: requestHeaders);
    return _handleResponse(response, url);
  }

  /// Makes a POST request to the specified URL.
  Future<dynamic> post(String url, {Map<String, String>? headers, dynamic body}) async {
    final requestHeaders = await _prepareHeaders(headers);
    final enrichedBody = await _enrichRequestBody(body);
    final response = await _client.post(
      Uri.parse(url),
      headers: requestHeaders,
      body: enrichedBody is String ? enrichedBody : jsonEncode(enrichedBody),
    );
    return _handleResponse(response, url);
  }

  /// Makes a PUT request to the specified URL.
  Future<dynamic> put(String url, {Map<String, String>? headers, dynamic body}) async {
    final requestHeaders = await _prepareHeaders(headers);
    final enrichedBody = await _enrichRequestBody(body);
    final response = await _client.put(
      Uri.parse(url),
      headers: requestHeaders,
      body: enrichedBody is String ? enrichedBody : jsonEncode(enrichedBody),
    );
    return _handleResponse(response, url);
  }

  /// Makes a DELETE request to the specified URL.
  Future<dynamic> delete(String url, {Map<String, String>? headers, dynamic body}) async {
    final requestHeaders = await _prepareHeaders(headers);
    final enrichedBody = await _enrichRequestBody(body);
    final response = await _client.delete(
      Uri.parse(url),
      headers: requestHeaders,
      body: enrichedBody is String ? enrichedBody : (enrichedBody != null ? jsonEncode(enrichedBody) : null),
    );
    return _handleResponse(response, url);
  }

  /// Prepares the headers for a request, including authentication.
  Future<Map<String, String>> _prepareHeaders(Map<String, String>? headers) async {
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authentication token if available
    final token = await _authService.getToken();
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    // Add custom headers
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    return requestHeaders;
  }

  /// Enriches the request body with member context information.
  Future<dynamic> _enrichRequestBody(dynamic body) async {
    if (body == null) {
      body = {};
    }

    // If body is a string, try to parse it as JSON
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (e) {
        // If it's not valid JSON, return it as is
        return body;
      }
    }

    // If body is not a Map, we can't enrich it
    if (body is! Map) {
      return body;
    }

    // Convert to a mutable map if it's not already
    final Map<String, dynamic> enrichedBody = Map<String, dynamic>.from(body);

    // Add member context if not already present
    if (!enrichedBody.containsKey('member_id')) {
      final memberId = await _authService.getMemberId();
      if (memberId != null) {
        enrichedBody['member_id'] = memberId;
      }
    }

    if (!enrichedBody.containsKey('unit_id')) {
      final unitId = await _authService.getUnitId();
      if (unitId != null) {
        enrichedBody['unit_id'] = unitId;
      }
    }

    if (!enrichedBody.containsKey('company_id')) {
      final companyId = await _authService.getCompanyId();
      if (companyId != null) {
        enrichedBody['company_id'] = companyId;
      }
    }

    return enrichedBody;
  }

  /// Handles the response from an HTTP request.
  dynamic _handleResponse(http.Response response, String url) {
    final statusCode = response.statusCode;
    final reasonPhrase = response.reasonPhrase;

    if (statusCode >= 200 && statusCode < 300) {
      // Success
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else if (statusCode == 401) {
      // Unauthorized
      throw ApiException(
        message: 'Unauthorized: ${reasonPhrase ?? "Authentication required"}',
        statusCode: statusCode,
        endpoint: url,
      );
    } else if (statusCode == 403) {
      // Forbidden
      throw ApiException(
        message: 'Forbidden: ${reasonPhrase ?? "Access denied"}',
        statusCode: statusCode,
        endpoint: url,
      );
    } else if (statusCode == 404) {
      // Not Found
      throw ApiException(
        message: 'Not Found: ${reasonPhrase ?? "Resource not found"}',
        statusCode: statusCode,
        endpoint: url,
      );
    } else {
      // Other errors
      String errorMessage;
      dynamic errorData;

      try {
        errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : 'Unknown error';
        errorData = null;
      }

      throw ApiException(
        message: errorMessage,
        statusCode: statusCode,
        endpoint: url,
        data: errorData,
      );
    }
  }
}
