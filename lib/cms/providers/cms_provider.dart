import 'package:flutter/material.dart';
import '../models/cms_models.dart';
import '../services/cms_service.dart';

/// Provider for managing CMS data
class CMSProvider extends ChangeNotifier {
  /// CMS service
  final CMSService _cmsService = CMSService();

  /// Pages
  List<CMSPage> _pages = [];

  /// Features
  List<CMSFeature> _features = [];

  /// Settings
  CMSSettings? _settings;

  /// Notifications
  List<CMSNotification> _notifications = [];

  /// FAQs
  List<CMSFAQ> _faqs = [];

  /// FAQ categories
  List<String> _faqCategories = [];

  /// Loading state
  bool _isLoading = false;

  /// Error message
  String? _errorMessage;

  /// Get pages
  List<CMSPage> get pages => _pages;

  /// Get features
  List<CMSFeature> get features => _features;

  /// Get settings
  CMSSettings? get settings => _settings;

  /// Get notifications
  List<CMSNotification> get notifications => _notifications;

  /// Get unread notifications
  List<CMSNotification> get unreadNotifications =>
      _notifications.where((notification) => !notification.isRead).toList();

  /// Get FAQs
  List<CMSFAQ> get faqs => _faqs;

  /// Get FAQ categories
  List<String> get faqCategories => _faqCategories;

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get error message
  String? get errorMessage => _errorMessage;

  /// Initialize the CMS provider
  Future<void> initialize() async {
    await Future.wait([
      loadSettings(),
      loadFeatures(),
    ]);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Load pages
  Future<void> loadPages() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      _pages = await _cmsService.getPages(
        filters: {
          'isPublished': {
            '\$eq': true,
          },
        },
      );
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to load pages: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load page by slug
  Future<CMSPage?> loadPageBySlug(String slug) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final page = await _cmsService.getPageBySlug(slug);
      return page;
    } catch (e) {
      _setErrorMessage('Failed to load page: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Load features
  Future<void> loadFeatures() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      _features = await _cmsService.getFeatures(
        filters: {
          'isEnabled': {
            '\$eq': true,
          },
        },
      );
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to load features: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load settings
  Future<void> loadSettings() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      _settings = await _cmsService.getSettings();
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to load settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load notifications for a user
  Future<void> loadNotifications({
    required String userId,
    List<String>? roles,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      _notifications = await _cmsService.getNotifications(
        userId: userId,
        roles: roles,
      );
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to load notifications: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Mark a notification as read
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final success = await _cmsService.markNotificationAsRead(notificationId);

      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          final notification = _notifications[index];
          _notifications[index] = CMSNotification(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            icon: notification.icon,
            action: notification.action,
            actionData: notification.actionData,
            isRead: true,
            targetUserIds: notification.targetUserIds,
            targetRoles: notification.targetRoles,
            createdAt: notification.createdAt,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      _setErrorMessage('Failed to mark notification as read: $e');
      return false;
    }
  }

  /// Load FAQs
  Future<void> loadFAQs({String? category}) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      _faqs = await _cmsService.getFAQs(
        category: category,
        isPublished: true,
      );
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to load FAQs: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load FAQ categories
  Future<void> loadFAQCategories() async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      _faqCategories = await _cmsService.getFAQCategories();
      notifyListeners();
    } catch (e) {
      _setErrorMessage('Failed to load FAQ categories: $e');
    } finally {
      _setLoading(false);
    }
  }
}
