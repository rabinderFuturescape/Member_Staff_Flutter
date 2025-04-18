import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/member.dart';

/// Service for handling authentication and user context
class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _baseUrl = 'https://api.oneapp.in/api';
  
  /// Get the current authenticated member
  Future<Member> getCurrentMember() async {
    // First try to get from secure storage
    final memberJson = await _storage.read(key: 'current_member');
    
    if (memberJson != null) {
      return Member.fromJson(jsonDecode(memberJson));
    }
    
    // If not in storage, fetch from API
    final token = await getAuthToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$_baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final member = Member.fromJson(jsonDecode(response.body));
      
      // Save to secure storage for future use
      await _storage.write(
        key: 'current_member',
        value: jsonEncode(member.toJson()),
      );
      
      return member;
    } else {
      throw Exception('Failed to get member details');
    }
  }
  
  /// Get the authentication token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  /// Set the authentication token
  Future<void> setAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  /// Clear authentication data
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'current_member');
  }
}
