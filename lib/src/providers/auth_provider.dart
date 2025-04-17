import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';

/// Provider class for managing authentication state.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  AuthUser? _user;
  bool _isLoading = false;
  String? _error;
  
  AuthProvider({
    AuthService? authService,
  }) : _authService = authService ?? AuthService();
  
  /// The current authenticated user.
  AuthUser? get user => _user;
  
  /// Whether authentication is in progress.
  bool get isLoading => _isLoading;
  
  /// The current authentication error, if any.
  String? get error => _error;
  
  /// Whether the user is authenticated.
  bool get isAuthenticated => _user != null;
  
  /// Initializes the provider by checking for an existing authenticated user.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _user = await _authService.getCurrentUser();
    } catch (e) {
      _error = 'Failed to initialize authentication: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Authenticates a user with a token from the parent app.
  Future<bool> authenticateWithToken(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final user = await _authService.authenticateWithToken(token);
      
      if (user != null) {
        _user = user;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid or expired token';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Authentication failed: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Logs out the current user.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _authService.logout();
      _user = null;
    } catch (e) {
      _error = 'Logout failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Clears the current error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
