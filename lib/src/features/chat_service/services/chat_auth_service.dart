import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../services/onessoauth_service.dart';
import '../models/chat_user.dart';
import '../utils/chat_constants.dart';

/// Service for handling authentication in the chat service
class ChatAuthService {
  /// OneSSO authentication service
  final OneSSOAuthService _oneSSOAuthService;
  
  /// Secure storage for tokens
  final FlutterSecureStorage _secureStorage;
  
  /// Constructor
  ChatAuthService({
    OneSSOAuthService? oneSSOAuthService,
    FlutterSecureStorage? secureStorage,
  }) : _oneSSOAuthService = oneSSOAuthService ?? OneSSOAuthService(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();
  
  /// Get the current user from the token
  Future<ChatUser?> getCurrentUser() async {
    try {
      // Get user info from token
      final userInfo = await _oneSSOAuthService.getUserInfo();
      if (userInfo == null) return null;
      
      // Create chat user from token data
      return ChatUser(
        id: userInfo['sub'] ?? '',
        username: userInfo['preferred_username'] ?? userInfo['email'] ?? 'Unknown',
        displayName: userInfo['name'],
        avatarUrl: userInfo['picture'],
        isOnline: true,
        lastActive: DateTime.now(),
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
  
  /// Get the current user ID
  Future<String?> getCurrentUserId() async {
    try {
      final userInfo = await _oneSSOAuthService.getUserInfo();
      return userInfo?['sub'];
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }
  
  /// Get the authorization header for API requests
  Future<Map<String, String>> getAuthHeader() async {
    return await _oneSSOAuthService.getAuthHeader();
  }
  
  /// Check if the user is authenticated
  Future<bool> isAuthenticated() async {
    return await _oneSSOAuthService.isTokenValid();
  }
  
  /// Get user roles from the token
  Future<List<String>> getUserRoles() async {
    return await _oneSSOAuthService.getUserRoles();
  }
  
  /// Check if the user has a specific role
  Future<bool> hasRole(String role) async {
    return await _oneSSOAuthService.hasRole(role);
  }
  
  /// Refresh the token if needed
  Future<bool> refreshTokenIfNeeded() async {
    try {
      final token = await _oneSSOAuthService.getAccessToken();
      if (token == null) return false;
      
      // Check if token is expired or about to expire (within 5 minutes)
      final decodedToken = JwtDecoder.decode(token);
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
      final now = DateTime.now();
      
      if (expiryDate.difference(now).inMinutes <= 5) {
        // Token is about to expire, refresh it
        return await _oneSSOAuthService.refreshToken();
      }
      
      return true;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }
  
  /// Initialize Supabase authentication with the OneSSO token
  Future<bool> initializeSupabaseAuth() async {
    try {
      final token = await _oneSSOAuthService.getAccessToken();
      if (token == null) return false;
      
      // Here you would typically exchange the OneSSO token for a Supabase token
      // or set up Supabase to validate the OneSSO token
      
      // For now, we'll just store the token for Supabase to use
      await _secureStorage.write(key: ChatConstants.supabaseTokenKey, value: token);
      
      return true;
    } catch (e) {
      print('Error initializing Supabase auth: $e');
      return false;
    }
  }
}
