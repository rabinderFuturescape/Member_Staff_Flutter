import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../utils/constants.dart';

class OneSSOAuthService {
  static final OneSSOAuthService _instance = OneSSOAuthService._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // Singleton pattern
  factory OneSSOAuthService() {
    return _instance;
  }
  
  OneSSOAuthService._internal();
  
  /// Get the access token from secure storage
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: Constants.tokenKey);
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }
  
  /// Save the access token to secure storage
  Future<void> saveAccessToken(String token) async {
    try {
      await _secureStorage.write(key: Constants.tokenKey, value: token);
    } catch (e) {
      print('Error saving access token: $e');
    }
  }
  
  /// Check if the token is valid and not expired
  Future<bool> isTokenValid() async {
    try {
      final token = await getAccessToken();
      if (token == null) return false;
      
      // Check if token is expired
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }
  
  /// Get user roles from the token
  Future<List<String>> getUserRoles() async {
    try {
      final token = await getAccessToken();
      if (token == null) return [];
      
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      
      // Extract roles from the token
      if (decodedToken.containsKey('realm_access') && 
          decodedToken['realm_access'] is Map && 
          decodedToken['realm_access'].containsKey('roles')) {
        final roles = decodedToken['realm_access']['roles'];
        if (roles is List) {
          return roles.map((role) => role.toString()).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error getting user roles: $e');
      return [];
    }
  }
  
  /// Check if the user has a specific role
  Future<bool> hasRole(String role) async {
    final roles = await getUserRoles();
    return roles.contains(role);
  }
  
  /// Check if the user has committee role
  Future<bool> isCommitteeMember() async {
    return await hasRole('committee');
  }
  
  /// Get user information from the token
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final token = await getAccessToken();
      if (token == null) return null;
      
      return JwtDecoder.decode(token);
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }
  
  /// Refresh the token
  Future<bool> refreshToken() async {
    try {
      final token = await getAccessToken();
      if (token == null) return false;
      
      // Get the refresh token from secure storage
      final refreshToken = await _secureStorage.read(key: Constants.refreshTokenKey);
      if (refreshToken == null) return false;
      
      // Call the OneSSO token refresh endpoint
      final response = await http.post(
        Uri.parse('${Constants.keycloakBaseUrl}/realms/${Constants.keycloakRealm}/protocol/openid-connect/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'client_id': Constants.keycloakClientId,
          'refresh_token': refreshToken,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveAccessToken(data['access_token']);
        await _secureStorage.write(key: Constants.refreshTokenKey, value: data['refresh_token']);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }
  
  /// Clear all tokens
  Future<void> logout() async {
    try {
      await _secureStorage.delete(key: Constants.tokenKey);
      await _secureStorage.delete(key: Constants.refreshTokenKey);
    } catch (e) {
      print('Error during logout: $e');
    }
  }
  
  /// Get the authorization header for API requests
  Future<Map<String, String>> getAuthHeader() async {
    final token = await getAccessToken();
    if (token == null) return {};
    
    return {
      'Authorization': 'Bearer $token',
    };
  }
}
