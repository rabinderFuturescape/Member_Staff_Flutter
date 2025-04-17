import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/token_manager.dart';
import '../exceptions/api_exception.dart';

/// Base API client that handles network requests with automatic token and context injection.
/// 
/// This class provides methods for making HTTP requests with automatic injection of:
/// - Authentication headers (Bearer token)
/// - Member context (member_id, unit_id, company_id)
class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();
  
  /// Makes a GET request with auth headers.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint').replace(
      queryParameters: queryParams,
    );
    
    final headers = await _getHeaders();
    
    try {
      final response = await _httpClient.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }
  
  /// Makes a POST request with auth headers and member context.
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders();
    final enrichedBody = await _enrichRequestBody(body ?? {});
    
    try {
      final response = await _httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode(enrichedBody),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }
  
  /// Makes a PUT request with auth headers and member context.
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders();
    final enrichedBody = await _enrichRequestBody(body ?? {});
    
    try {
      final response = await _httpClient.put(
        uri,
        headers: headers,
        body: jsonEncode(enrichedBody),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }
  
  /// Makes a DELETE request with auth headers and member context.
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    final headers = await _getHeaders();
    final enrichedBody = body != null ? await _enrichRequestBody(body) : null;
    
    try {
      final response = await _httpClient.delete(
        uri,
        headers: headers,
        body: enrichedBody != null ? jsonEncode(enrichedBody) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: $e');
    }
  }
  
  /// Gets the headers for API requests, including auth token.
  Future<Map<String, String>> _getHeaders() async {
    final authHeaders = await TokenManager.getAuthHeader();
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...authHeaders,
    };
  }
  
  /// Enriches the request body with member context.
  /// 
  /// This automatically injects member_id, unit_id, and company_id into all requests.
  Future<Map<String, dynamic>> _enrichRequestBody(Map<String, dynamic> body) async {
    final memberContext = await TokenManager.getMemberContext();
    
    // Only add context fields that aren't already in the body
    memberContext.forEach((key, value) {
      if (!body.containsKey(key)) {
        body[key] = value;
      }
    });
    
    return body;
  }
  
  /// Handles the API response, parsing JSON and checking for errors.
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException(
          message: 'Failed to parse response: $e',
          statusCode: response.statusCode,
        );
      }
    } else {
      Map<String, dynamic>? errorData;
      String errorMessage = 'Unknown error';
      
      try {
        errorData = jsonDecode(response.body);
        errorMessage = errorData?['message'] ?? errorData?['error'] ?? 'Unknown error';
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : 'Unknown error';
      }
      
      throw ApiException(
        message: errorMessage,
        statusCode: response.statusCode,
        data: errorData,
      );
    }
  }
}
