import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

/// Service for handling OneSSO (Keycloak) authentication
class OneSSOAuthService {
  /// Secure storage for tokens
  final FlutterSecureStorage _secureStorage;
  
  /// Base URL for Keycloak
  final String _baseUrl;
  
  /// Realm name
  final String _realm;
  
  /// Client ID
  final String _clientId;
  
  /// Access token key in secure storage
  static const String _accessTokenKey = 'onessoAccessToken';
  
  /// Refresh token key in secure storage
  static const String _refreshTokenKey = 'onessoRefreshToken';
  
  /// Constructor
  OneSSOAuthService({
    FlutterSecureStorage? secureStorage,
    String baseUrl = 'https://sso.oneapp.in',
    String realm = 'oneapp',
    String clientId = 'member-staff-app',
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _baseUrl = baseUrl,
       _realm = realm,
       _clientId = clientId;
  
  /// Get the access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }
  
  /// Get the refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }
  
  /// Save tokens to secure storage
  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  /// Clear tokens from secure storage
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
  
  /// Check if the token is valid
  Future<bool> isTokenValid() async {
    final token = await getAccessToken();
    if (token == null) return false;
    
    try {
      final decodedToken = JwtDecoder.decode(token);
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
      return expiryDate.isAfter(DateTime.now());
    } catch (e) {
      return false;
    }
  }
  
  /// Refresh the token
  Future<bool> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/realms/$_realm/protocol/openid-connect/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': _clientId,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        return true;
      }
      
      // If refresh token is invalid, clear tokens
      if (response.statusCode == 400 || response.statusCode == 401) {
        await clearTokens();
      }
      
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }
  
  /// Get user info from the token
  Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await getAccessToken();
    if (token == null) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/realms/$_realm/protocol/openid-connect/userinfo'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      
      // If token is invalid, try to refresh
      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          return await getUserInfo();
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }
  
  /// Get user roles from the token
  Future<List<String>> getUserRoles() async {
    final token = await getAccessToken();
    if (token == null) return [];
    
    try {
      final decodedToken = JwtDecoder.decode(token);
      final resourceAccess = decodedToken['resource_access'];
      
      if (resourceAccess != null && resourceAccess[_clientId] != null) {
        final roles = resourceAccess[_clientId]['roles'];
        if (roles != null) {
          return List<String>.from(roles);
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
  
  /// Get the authorization header for API requests
  Future<Map<String, String>> getAuthHeader() async {
    final token = await getAccessToken();
    if (token == null) return {};
    
    return {
      'Authorization': 'Bearer $token',
    };
  }
  
  /// Set tokens from parent app
  Future<void> setTokensFromParentApp({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
