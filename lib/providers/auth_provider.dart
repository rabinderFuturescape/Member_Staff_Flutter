import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

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
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(Constants.userKey);
      final savedToken = prefs.getString(Constants.tokenKey);

      if (userData != null && savedToken != null) {
        _user = User.fromJson(json.decode(userData));
        _token = savedToken;
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(User user, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.userKey, json.encode(user.toJson()));
      await prefs.setString(Constants.tokenKey, token);

      _user = user;
      _token = token;
    } catch (e) {
      print('Error saving user data: $e');
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.userKey);
      await prefs.remove(Constants.tokenKey);

      _user = null;
      _token = null;
    } catch (e) {
      print('Error removing user data: $e');
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
}
