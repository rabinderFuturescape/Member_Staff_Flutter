import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../models/user_model.dart';
import '../utils/constants.dart';
import '../services/onessoauth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  final OneSSOAuthService _oneSSOAuthService = OneSSOAuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  bool get isCommitteeMember => _user?.role == 'committee';

  AuthProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get token from OneSSO service
      _token = await _oneSSOAuthService.getAccessToken();

      if (_token != null) {
        // Check if token is valid
        if (await _oneSSOAuthService.isTokenValid()) {
          // Get user info from token
          final userInfo = await _oneSSOAuthService.getUserInfo();
          if (userInfo != null) {
            // Create user object from token data
            _user = User(
              id: userInfo['sub'] ?? '',
              name: userInfo['name'] ?? '',
              email: userInfo['email'] ?? '',
              role: await _oneSSOAuthService.isCommitteeMember() ? 'committee' : 'member',
            );

            // Save user data to shared preferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(Constants.userKey, json.encode(_user!.toJson()));
          }
        } else {
          // Token is invalid or expired, try to refresh it
          final refreshed = await _oneSSOAuthService.refreshToken();
          if (refreshed) {
            // Reload user data after successful refresh
            await _loadUserData();
            return;
          } else {
            // Clear invalid token
            _token = null;
            _user = null;
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      _token = null;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String token, {String? refreshToken}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Save the token using OneSSO service
      await _oneSSOAuthService.saveAccessToken(token);

      // Save refresh token if provided
      if (refreshToken != null) {
        await _secureStorage.write(key: Constants.refreshTokenKey, value: refreshToken);
      }

      // Get user info from token
      final userInfo = await _oneSSOAuthService.getUserInfo();
      if (userInfo != null) {
        // Create user object from token data
        _user = User(
          id: userInfo['sub'] ?? '',
          name: userInfo['name'] ?? '',
          email: userInfo['email'] ?? '',
          role: await _oneSSOAuthService.isCommitteeMember() ? 'committee' : 'member',
        );

        // Save user data to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(Constants.userKey, json.encode(_user!.toJson()));
      }

      _token = token;
    } catch (e) {
      print('Error during login: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear tokens using OneSSO service
      await _oneSSOAuthService.logout();

      // Clear user data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.userKey);

      _user = null;
      _token = null;
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Update user data in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.userKey, json.encode(user.toJson()));

      _user = user;
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to handle token received from OneSSO
  Future<bool> handleSSOToken(String token, {String? refreshToken}) async {
    try {
      // Save the token
      await login(token, refreshToken: refreshToken);
      return true;
    } catch (e) {
      print('Error handling SSO token: $e');
      return false;
    }
  }

  // Check if the user has committee role
  Future<bool> hasCommitteeRole() async {
    return await _oneSSOAuthService.isCommitteeMember();
  }
}
