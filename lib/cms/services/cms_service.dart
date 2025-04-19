import 'package:strapi_sdk/strapi_sdk.dart';
import '../config/cms_config.dart';
import '../models/cms_models.dart';

/// Service for interacting with the Strapi CMS
class CMSService {
  /// Strapi SDK client
  late final StrapiClient _client;
  
  /// Create a new CMS service
  CMSService() {
    _client = StrapiClient(
      baseUrl: CMSConfig.baseUrl,
      apiToken: CMSConfig.apiToken,
    );
  }
  
  /// Get all pages
  Future<List<CMSPage>> getPages({
    Map<String, dynamic>? filters,
    String? sort,
    int? page,
    int? pageSize,
  }) async {
    try {
      final response = await _client.find(
        contentType: CMSConfig.contentTypePages,
        filters: filters,
        sort: sort,
        page: page,
        pageSize: pageSize,
        populate: ['featuredImage'],
      );
      
      final List<dynamic> data = response.data ?? [];
      return data.map((item) => CMSPage.fromJson(item)).toList();
    } catch (e) {
      print('Error getting pages: $e');
      return [];
    }
  }
  
  /// Get a page by slug
  Future<CMSPage?> getPageBySlug(String slug) async {
    try {
      final response = await _client.find(
        contentType: CMSConfig.contentTypePages,
        filters: {
          'slug': {
            '\$eq': slug,
          },
        },
        populate: ['featuredImage'],
      );
      
      final List<dynamic> data = response.data ?? [];
      if (data.isEmpty) {
        return null;
      }
      
      return CMSPage.fromJson(data.first);
    } catch (e) {
      print('Error getting page by slug: $e');
      return null;
    }
  }
  
  /// Get all features
  Future<List<CMSFeature>> getFeatures({
    Map<String, dynamic>? filters,
    String? sort,
    int? page,
    int? pageSize,
  }) async {
    try {
      final response = await _client.find(
        contentType: CMSConfig.contentTypeFeatures,
        filters: filters,
        sort: sort ?? 'order:asc',
        page: page,
        pageSize: pageSize,
      );
      
      final List<dynamic> data = response.data ?? [];
      return data.map((item) => CMSFeature.fromJson(item)).toList();
    } catch (e) {
      print('Error getting features: $e');
      return [];
    }
  }
  
  /// Get settings
  Future<CMSSettings?> getSettings() async {
    try {
      final response = await _client.findOne(
        contentType: CMSConfig.contentTypeSettings,
        id: 1, // Assuming there's only one settings record
        populate: ['appLogo'],
      );
      
      if (response.data == null) {
        return null;
      }
      
      return CMSSettings.fromJson(response.data!);
    } catch (e) {
      print('Error getting settings: $e');
      return null;
    }
  }
  
  /// Get notifications for a user
  Future<List<CMSNotification>> getNotifications({
    required String userId,
    List<String>? roles,
    bool? isRead,
    int? page,
    int? pageSize,
  }) async {
    try {
      final filters = {
        '\$or': [
          {
            'targetUserIds': {
              '\$contains': userId,
            },
          },
          if (roles != null && roles.isNotEmpty)
            {
              'targetRoles': {
                '\$containsAny': roles,
              },
            },
        ],
      };
      
      if (isRead != null) {
        filters['isRead'] = {
          '\$eq': isRead,
        };
      }
      
      final response = await _client.find(
        contentType: CMSConfig.contentTypeNotifications,
        filters: filters,
        sort: 'createdAt:desc',
        page: page,
        pageSize: pageSize,
      );
      
      final List<dynamic> data = response.data ?? [];
      return data.map((item) => CMSNotification.fromJson(item)).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }
  
  /// Mark a notification as read
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      await _client.update(
        contentType: CMSConfig.contentTypeNotifications,
        id: notificationId,
        data: {
          'isRead': true,
        },
      );
      
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
  
  /// Get FAQs
  Future<List<CMSFAQ>> getFAQs({
    String? category,
    bool? isPublished,
    String? sort,
    int? page,
    int? pageSize,
  }) async {
    try {
      final filters = <String, dynamic>{};
      
      if (category != null) {
        filters['category'] = {
          '\$eq': category,
        };
      }
      
      if (isPublished != null) {
        filters['isPublished'] = {
          '\$eq': isPublished,
        };
      }
      
      final response = await _client.find(
        contentType: CMSConfig.contentTypeFAQs,
        filters: filters,
        sort: sort ?? 'order:asc',
        page: page,
        pageSize: pageSize,
      );
      
      final List<dynamic> data = response.data ?? [];
      return data.map((item) => CMSFAQ.fromJson(item)).toList();
    } catch (e) {
      print('Error getting FAQs: $e');
      return [];
    }
  }
  
  /// Get FAQ categories
  Future<List<String>> getFAQCategories() async {
    try {
      final response = await _client.find(
        contentType: CMSConfig.contentTypeFAQs,
        fields: ['category'],
        groupBy: ['category'],
      );
      
      final List<dynamic> data = response.data ?? [];
      return data
          .map((item) => item['attributes']['category'] as String)
          .toSet()
          .toList();
    } catch (e) {
      print('Error getting FAQ categories: $e');
      return [];
    }
  }
}
