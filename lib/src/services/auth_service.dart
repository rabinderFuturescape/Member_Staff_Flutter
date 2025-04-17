import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user.dart';

/// Service class for handling authentication.
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  
  final FlutterSecureStorage _secureStorage;
  
  AuthService({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();
  
  /// Authenticates a user with a token from the parent app.
  Future<AuthUser?> authenticateWithToken(String token) async {
    try {
      // Validate the token
      if (!_isValidToken(token)) {
        return null;
      }
      
      // Extract user information from the token
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      
      // Create the user object
      final user = AuthUser(
        id: decodedToken['sub'] ?? '',
        name: decodedToken['name'] ?? '',
        email: decodedToken['email'] ?? '',
        role: decodedToken['role'] ?? 'user',
        token: token,
      );
      
      // Save the token and user
      await _saveToken(token);
      await _saveUser(user);
      
      return user;
    } catch (e) {
      print('Error authenticating with token: $e');
      return null;
    }
  }
  
  /// Checks if a token is valid.
  bool _isValidToken(String token) {
    try {
      // Check if the token is expired
      if (JwtDecoder.isExpired(token)) {
        return false;
      }
      
      // Additional validation can be added here
      
      return true;
    } catch (e) {
      print('Error validating token: $e');
      return false;
    }
  }
  
  /// Saves the authentication token securely.
  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }
  
  /// Saves the user information.
  Future<void> _saveUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
  
  /// Gets the current authentication token.
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }
  
  /// Gets the current authenticated user.
  Future<AuthUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson == null) {
      return null;
    }
    
    try {
      final user = AuthUser.fromJson(jsonDecode(userJson));
      
      // Verify that the token is still valid
      final token = await getToken();
      if (token == null || token != user.token || !_isValidToken(token)) {
        await logout();
        return null;
      }
      
      return user;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  
  /// Checks if the user is authenticated.
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && _isValidToken(token);
  }
  
  /// Logs out the current user.
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
