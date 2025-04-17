import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';
import '../models/schedule.dart';

/// Provider class for managing notifications.
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  bool _isInitialized = false;
  bool _notificationsEnabled = true;

  NotificationProvider({
    NotificationService? notificationService,
  }) : _notificationService = notificationService ?? NotificationService();

  /// Whether notifications are enabled.
  bool get notificationsEnabled => _notificationsEnabled;

  /// Initializes the provider.
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _notificationService.initialize();
    _notificationsEnabled = await _notificationService.areNotificationsEnabled();
    _isInitialized = true;
    notifyListeners();
  }

  /// Enables or disables notifications.
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _notificationService.setNotificationsEnabled(enabled);
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  /// Shows a notification for a new time slot.
  Future<void> notifyNewTimeSlot({
    required String staffName,
    required TimeSlot timeSlot,
  }) async {
    if (!_notificationsEnabled) return;

    await _notificationService.showNewTimeSlotNotification(
      staffName: staffName,
      timeSlot: timeSlot,
    );
  }

  /// Shows a notification for a removed time slot.
  Future<void> notifyRemovedTimeSlot({
    required String staffName,
    required TimeSlot timeSlot,
  }) async {
    if (!_notificationsEnabled) return;

    await _notificationService.showRemovedTimeSlotNotification(
      staffName: staffName,
      timeSlot: timeSlot,
    );
  }

  /// Schedules a reminder for an upcoming time slot.
  Future<void> scheduleReminder({
    required String staffName,
    required TimeSlot timeSlot,
    required int minutesBefore,
  }) async {
    if (!_notificationsEnabled) return;

    await _notificationService.scheduleTimeSlotReminder(
      staffName: staffName,
      timeSlot: timeSlot,
      minutesBefore: minutesBefore,
    );
  }
}
