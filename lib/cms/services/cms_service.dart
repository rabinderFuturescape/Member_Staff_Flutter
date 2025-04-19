import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/cms_config.dart';
import '../models/cms_models.dart';
import 'cms_auth_service.dart';
import 'cms_cache_service.dart';

/// Service for interacting with the Strapi CMS
class CMSService {
  /// Authentication service
  final CMSAuthService _authService = CMSAuthService();

  /// Cache service
  final CMSCacheService _cacheService = CMSCacheService();

  /// Base URL for the Strapi CMS API
  final String _baseUrl = CMSConfig.baseUrl;

  /// API token for the Strapi CMS API
  final String _apiToken = CMSConfig.apiToken;

  /// Initialize the CMS service
  Future<void> initialize() async {
    await _cacheService.initialize();
  }

  /// Get all pages
  Future<List<CMSPage>> getPages({
    Map<String, dynamic>? filters,
    String? sort,
    int? page,
    int? pageSize,
    bool forceRefresh = false,
  }) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedPages = _cacheService.getCachedPages();
      if (cachedPages != null) {
        return cachedPages;
      }
    }

    try {
      // Get headers with authentication token
      final headers = await _authService.getHeaders();

      // Build the URL
      final url = '$_baseUrl/api/${CMSConfig.contentTypePages}';

      // Build the query parameters
      final queryParams = <String, dynamic>{};
      if (filters != null) queryParams['filters'] = filters;
      if (sort != null) queryParams['sort'] = sort;
      if (page != null) queryParams['pagination[page]'] = page.toString();
      if (pageSize != null) queryParams['pagination[pageSize]'] = pageSize.toString();
      queryParams['populate'] = 'featuredImage';

      // Make the HTTP request
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load pages: ${response.statusCode}');
      }

      // Parse the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'] ?? [];
      final pages = data.map((item) => CMSPage.fromJson(item)).toList();

      // Cache the pages
      await _cacheService.cachePages(pages);

      return pages;
    } catch (e) {
      print('Error getting pages: $e');

      // Try to return cached data even if it's expired
      final cachedPages = _cacheService.getCachedPages();
      if (cachedPages != null) {
        return cachedPages;
      }

      return [];
    }
  }

  /// Get a page by slug
  Future<CMSPage?> getPageBySlug(String slug, {bool forceRefresh = false}) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedPage = _cacheService.getCachedPageBySlug(slug);
      if (cachedPage != null) {
        return cachedPage;
      }
    }

    try {
      // Get headers with authentication token
      final headers = await _authService.getHeaders();

      // Build the URL
      final url = '$_baseUrl/api/${CMSConfig.contentTypePages}';

      // Build the query parameters
      final queryParams = <String, dynamic>{
        'filters[slug][\$eq]': slug,
        'populate': 'featuredImage',
      };

      // Make the HTTP request
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load page: ${response.statusCode}');
      }

      // Parse the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'] ?? [];

      if (data.isEmpty) {
        return null;
      }

      final page = CMSPage.fromJson(data.first);

      // Cache the page
      await _cacheService.cachePageBySlug(slug, page);

      return page;
    } catch (e) {
      print('Error getting page by slug: $e');

      // Try to return cached data even if it's expired
      final cachedPage = _cacheService.getCachedPageBySlug(slug);
      if (cachedPage != null) {
        return cachedPage;
      }

      return null;
    }
  }

  /// Get all features
  Future<List<CMSFeature>> getFeatures({
    Map<String, dynamic>? filters,
    String? sort,
    int? page,
    int? pageSize,
    bool forceRefresh = false,
  }) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedFeatures = _cacheService.getCachedFeatures();
      if (cachedFeatures != null) {
        return cachedFeatures;
      }
    }

    try {
      // Get headers with authentication token
      final headers = await _authService.getHeaders();

      // Build the URL
      final url = '$_baseUrl/api/${CMSConfig.contentTypeFeatures}';

      // Build the query parameters
      final queryParams = <String, dynamic>{};
      if (filters != null) {
        filters.forEach((key, value) {
          queryParams['filters[$key][\$eq]'] = value.toString();
        });
      }
      if (sort != null) queryParams['sort'] = sort;
      if (page != null) queryParams['pagination[page]'] = page.toString();
      if (pageSize != null) queryParams['pagination[pageSize]'] = pageSize.toString();

      // Make the HTTP request
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load features: ${response.statusCode}');
      }

      // Parse the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'] ?? [];
      final features = data.map((item) => CMSFeature.fromJson(item)).toList();

      // Cache the features
      await _cacheService.cacheFeatures(features);

      return features;
    } catch (e) {
      print('Error getting features: $e');

      // Try to return cached data even if it's expired
      final cachedFeatures = _cacheService.getCachedFeatures();
      if (cachedFeatures != null) {
        return cachedFeatures;
      }

      return [];
    }
  }

  /// Get settings
  Future<CMSSettings?> getSettings({bool forceRefresh = false}) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedSettings = _cacheService.getCachedSettings();
      if (cachedSettings != null) {
        return cachedSettings;
      }
    }

    try {
      // Get headers with authentication token
      final headers = await _authService.getHeaders();

      // Build the URL
      final url = '$_baseUrl/api/${CMSConfig.contentTypeSettings}/1'; // Assuming there's only one settings record

      // Build the query parameters
      final queryParams = <String, dynamic>{
        'populate': 'appLogo',
      };

      // Make the HTTP request
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load settings: ${response.statusCode}');
      }

      // Parse the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final Map<String, dynamic>? data = responseData['data'];

      if (data == null) {
        return null;
      }

      final settings = CMSSettings.fromJson(data);

      // Cache the settings
      await _cacheService.cacheSettings(settings);

      return settings;
    } catch (e) {
      print('Error getting settings: $e');

      // Try to return cached data even if it's expired
      final cachedSettings = _cacheService.getCachedSettings();
      if (cachedSettings != null) {
        return cachedSettings;
      }

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
    bool forceRefresh = false,
  }) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedNotifications = _cacheService.getCachedNotifications();
      if (cachedNotifications != null) {
        return cachedNotifications;
      }
    }

    try {
      // Get headers with authentication token
      final headers = await _authService.getHeaders();

      // Build the URL
      final url = '$_baseUrl/api/${CMSConfig.contentTypeNotifications}';

      // Build the query parameters
      final queryParams = <String, dynamic>{
        'sort': 'createdAt:desc',
      };

      // Add filters for user ID and roles
      queryParams['filters[\$or][0][targetUserIds][\$contains]'] = userId;

      if (roles != null && roles.isNotEmpty) {
        for (int i = 0; i < roles.length; i++) {
          queryParams['filters[\$or][1][targetRoles][\$containsAny][$i]'] = roles[i];
        }
      }

      // Add filter for read status
      if (isRead != null) {
        queryParams['filters[isRead][\$eq]'] = isRead.toString();
      }

      // Add pagination
      if (page != null) queryParams['pagination[page]'] = page.toString();
      if (pageSize != null) queryParams['pagination[pageSize]'] = pageSize.toString();

      // Make the HTTP request
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }

      // Parse the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'] ?? [];
      final notifications = data.map((item) => CMSNotification.fromJson(item)).toList();

      // Cache the notifications
      await _cacheService.cacheNotifications(notifications);

      return notifications;
    } catch (e) {
      print('Error getting notifications: $e');

      // Try to return cached data even if it's expired
      final cachedNotifications = _cacheService.getCachedNotifications();
      if (cachedNotifications != null) {
        return cachedNotifications;
      }

      return [];
    }
  }

  /// Mark a notification as read
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      // Get headers with authentication token
      final headers = await _authService.getHeaders();

      // Build the URL
      final url = '$_baseUrl/api/${CMSConfig.contentTypeNotifications}/$notificationId';

      // Build the request body
      final body = jsonEncode({
        'data': {
          'isRead': true,
        },
      });

      // Make the HTTP request
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read: ${response.statusCode}');
      }

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
    bool forceRefresh = false,
  }) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedFAQs = _cacheService.getCachedFAQs();
      if (cachedFAQs != null) {
        return cachedFAQs;
      }
    }

    try {
      // Get headers with authentication token
      final headers = await _authService.getHeaders();

      // Build the URL
      final url = '$_baseUrl/api/${CMSConfig.contentTypeFAQs}';

      // Build the query parameters
      final queryParams = <String, dynamic>{
        'sort': sort ?? 'order:asc',
      };

      // Add filters
      if (category != null) {
        queryParams['filters[category][\$eq]'] = category;
      }

      if (isPublished != null) {
        queryParams['filters[isPublished][\$eq]'] = isPublished.toString();
      }

      // Add pagination
      if (page != null) queryParams['pagination[page]'] = page.toString();
      if (pageSize != null) queryParams['pagination[pageSize]'] = pageSize.toString();

      // Make the HTTP request
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load FAQs: ${response.statusCode}');
      }

      // Parse the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'] ?? [];
      final faqs = data.map((item) => CMSFAQ.fromJson(item)).toList();

      // Cache the FAQs
      await _cacheService.cacheFAQs(faqs);

      return faqs;
    } catch (e) {
      print('Error getting FAQs: $e');

      // Try to return cached data even if it's expired
      final cachedFAQs = _cacheService.getCachedFAQs();
      if (cachedFAQs != null) {
        return cachedFAQs;
      }

      return [];
    }
  }

  /// Get FAQ categories
  Future<List<String>> getFAQCategories({bool forceRefresh = false}) async {
    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cachedCategories = _cacheService.getCachedFAQCategories();
      if (cachedCategories != null) {
        return cachedCategories;
      }
    }

    try {
      // Get headers with authentication token
      final headers = await _authService.getHeaders();

      // Build the URL
      final url = '$_baseUrl/api/${CMSConfig.contentTypeFAQs}';

      // Build the query parameters
      final queryParams = <String, dynamic>{
        'fields': 'category',
      };

      // Make the HTTP request
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: queryParams),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load FAQ categories: ${response.statusCode}');
      }

      // Parse the response
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final List<dynamic> data = responseData['data'] ?? [];

      // Extract unique categories
      final Set<String> categories = {};
      for (final item in data) {
        final category = item['attributes']['category'] as String?;
        if (category != null) {
          categories.add(category);
        }
      }

      final categoryList = categories.toList();

      // Cache the categories
      await _cacheService.cacheFAQCategories(categoryList);

      return categoryList;
    } catch (e) {
      print('Error getting FAQ categories: $e');

      // Try to return cached data even if it's expired
      final cachedCategories = _cacheService.getCachedFAQCategories();
      if (cachedCategories != null) {
        return cachedCategories;
      }

      return [];
    }
  }
}
