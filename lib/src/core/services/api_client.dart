import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// API client for making HTTP requests
class ApiClient {
  final String baseUrl;
  final AuthService _authService = AuthService();
  
  ApiClient({
    this.baseUrl = 'https://api.oneapp.in/api',
  });
  
  /// Make a GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final token = await _authService.getAuthToken();
    final uri = Uri.parse('$baseUrl/$endpoint').replace(
      queryParameters: queryParams,
    );
    
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    return _handleResponse(response);
  }
  
  /// Make a POST request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final token = await _authService.getAuthToken();
    final uri = Uri.parse('$baseUrl/$endpoint');
    
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    
    return _handleResponse(response);
  }
  
  /// Make a PUT request
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final token = await _authService.getAuthToken();
    final uri = Uri.parse('$baseUrl/$endpoint');
    
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    
    return _handleResponse(response);
  }
  
  /// Make a DELETE request
  Future<dynamic> delete(String endpoint) async {
    final token = await _authService.getAuthToken();
    final uri = Uri.parse('$baseUrl/$endpoint');
    
    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    return _handleResponse(response);
  }
  
  /// Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Unknown error');
      } catch (e) {
        throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    }
  }
}
