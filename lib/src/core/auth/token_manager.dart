import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Manages authentication tokens and provides methods to extract user information.
/// 
/// This class handles the secure storage, retrieval, and decoding of JWT tokens
/// received from the parent OneApp. It provides convenient methods to access
/// member context information that needs to be included in API requests.
class TokenManager {
  static final _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  
  /// Cache for decoded token to avoid repeated decoding
  static Map<String, dynamic>? _cachedDecodedToken;
  
  /// Retrieves the auth token from secure storage.
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  /// Saves the auth token to secure storage.
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _cachedDecodedToken = null; // Clear cache when setting new token
  }
  
  /// Removes the auth token from secure storage.
  static Future<void> clearAuthToken() async {
    await _storage.delete(key: _tokenKey);
    _cachedDecodedToken = null;
  }
  
  /// Decodes the JWT token and returns its payload.
  /// 
  /// Uses caching to avoid repeated decoding of the same token.
  static Future<Map<String, dynamic>?> getDecodedToken() async {
    if (_cachedDecodedToken != null) {
      return _cachedDecodedToken;
    }
    
    final token = await getAuthToken();
    if (token == null) return null;
    
    try {
      _cachedDecodedToken = JwtDecoder.decode(token);
      return _cachedDecodedToken;
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }
  
  /// Checks if the current token is valid and not expired.
  static Future<bool> isTokenValid() async {
    final token = await getAuthToken();
    if (token == null) return false;
    
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }
  
  /// Gets the company ID from the token.
  static Future<String?> getCompanyId() async {
    final tokenData = await getDecodedToken();
    return tokenData?['company_id']?.toString();
  }
  
  /// Gets the member ID from the token.
  static Future<String?> getMemberId() async {
    final tokenData = await getDecodedToken();
    return tokenData?['member_id']?.toString();
  }
  
  /// Gets the unit ID from the token.
  static Future<String?> getUnitId() async {
    final tokenData = await getDecodedToken();
    return tokenData?['unit_id']?.toString();
  }
  
  /// Gets the user/member name from the token.
  static Future<String?> getUserName() async {
    final tokenData = await getDecodedToken();
    return tokenData?['member_name'] ?? tokenData?['username'];
  }
  
  /// Gets the unit number from the token.
  static Future<String?> getUnitNumber() async {
    final tokenData = await getDecodedToken();
    return tokenData?['unit_number']?.toString();
  }
  
  /// Gets the authorization header for API requests.
  static Future<Map<String, String>> getAuthHeader() async {
    final token = await getAuthToken();
    if (token == null) return {};
    
    return {
      'Authorization': 'Bearer $token',
    };
  }
  
  /// Gets the member context as a map for API requests.
  /// 
  /// This includes member_id, unit_id, and company_id.
  static Future<Map<String, dynamic>> getMemberContext() async {
    final memberId = await getMemberId();
    final unitId = await getUnitId();
    final companyId = await getCompanyId();
    
    final Map<String, dynamic> context = {};
    
    if (memberId != null) context['member_id'] = memberId;
    if (unitId != null) context['unit_id'] = unitId;
    if (companyId != null) context['company_id'] = companyId;
    
    return context;
  }
}
