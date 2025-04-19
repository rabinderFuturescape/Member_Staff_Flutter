/// Configuration for Strapi CMS
class CMSConfig {
  /// Base URL for the Strapi CMS API
  static const String baseUrl = 'http://localhost:1337';
  
  /// API token for authenticating with Strapi CMS
  static const String apiToken = 'your_strapi_api_token';
  
  /// API version
  static const String apiVersion = 'v1';
  
  /// Get the full API URL
  static String get apiUrl => '$baseUrl/api';
  
  /// Content types
  static const String contentTypePages = 'pages';
  static const String contentTypeFeatures = 'features';
  static const String contentTypeSettings = 'settings';
  static const String contentTypeStaff = 'staff-members';
  static const String contentTypeMembers = 'members';
  static const String contentTypeNotifications = 'notifications';
  static const String contentTypeFAQs = 'faqs';
  
  /// Image URL helper
  static String getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    
    if (imageUrl.startsWith('http')) {
      return imageUrl;
    }
    
    return '$baseUrl$imageUrl';
  }
}
