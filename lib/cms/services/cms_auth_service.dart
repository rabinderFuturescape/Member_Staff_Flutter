import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../config/cms_config.dart';
import '../../src/providers/auth_provider.dart';

/// Service for handling CMS authentication
class CMSAuthService {
  /// Secure storage for tokens
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  /// Key for storing the CMS token
  static const String _cmsTokenKey = 'cms_token';
  
  /// Get the CMS token
  Future<String?> getCMSToken() async {
    return await _secureStorage.read(key: _cmsTokenKey);
  }
  
  /// Save the CMS token
  Future<void> saveCMSToken(String token) async {
    await _secureStorage.write(key: _cmsTokenKey, value: token);
  }
  
  /// Delete the CMS token
  Future<void> deleteCMSToken() async {
    await _secureStorage.delete(key: _cmsTokenKey);
  }
  
  /// Check if the CMS token is valid
  bool isCMSTokenValid(String token) {
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      
      // Check if token is expired
      final DateTime expirationDate = DateTime.fromMillisecondsSinceEpoch(
        decodedToken['exp'] * 1000,
      );
      
      return DateTime.now().isBefore(expirationDate);
    } catch (e) {
      return false;
    }
  }
  
  /// Get the headers for CMS API requests
  Future<Map<String, String>> getHeaders() async {
    final String? cmsToken = await getCMSToken();
    
    if (cmsToken != null && isCMSTokenValid(cmsToken)) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $cmsToken',
      };
    }
    
    // Use the default API token if no user token is available
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${CMSConfig.apiToken}',
    };
  }
  
  /// Authenticate with the CMS using the app auth token
  Future<bool> authenticateWithAppToken(String appToken) async {
    try {
      // In a real implementation, you would exchange the app token for a CMS token
      // by making a request to your backend or Strapi
      
      // For demonstration purposes, we'll just use the app token as the CMS token
      await saveCMSToken(appToken);
      
      return true;
    } catch (e) {
      print('Error authenticating with app token: $e');
      return false;
    }
  }
  
  /// Sync user roles with CMS
  Future<bool> syncUserRoles(AuthProvider authProvider) async {
    try {
      if (!authProvider.isAuthenticated) {
        return false;
      }
      
      final user = authProvider.currentUser;
      if (user == null) {
        return false;
      }
      
      // In a real implementation, you would sync the user roles with the CMS
      // by making a request to your backend or Strapi
      
      return true;
    } catch (e) {
      print('Error syncing user roles: $e');
      return false;
    }
  }
  
  /// Logout from CMS
  Future<void> logout() async {
    await deleteCMSToken();
  }
}
