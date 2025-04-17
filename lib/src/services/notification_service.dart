import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule.dart';

/// Service class for handling notifications.
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  NotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  /// Initializes the notification service.
  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  /// Handles notification tap events.
  void _onNotificationTap(NotificationResponse notificationResponse) {
    // Handle notification tap based on the payload
    print('Notification tapped: ${notificationResponse.payload}');
  }

  /// Shows a notification for a schedule change.
  Future<void> showScheduleChangeNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check if notifications are enabled
    final bool enabled = await areNotificationsEnabled();
    if (!enabled) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'schedule_changes',
      'Schedule Changes',
      channelDescription: 'Notifications for staff schedule changes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// Shows a notification for a new time slot.
  Future<void> showNewTimeSlotNotification({
    required String staffName,
    required TimeSlot timeSlot,
  }) async {
    final String formattedDate = timeSlot.date;
    final String timeRange = '${timeSlot.startTime} - ${timeSlot.endTime}';

    await showScheduleChangeNotification(
      title: 'New Time Slot Added',
      body: '$staffName has a new time slot on $formattedDate at $timeRange',
      payload: 'timeSlot:${timeSlot.date}',
    );
  }

  /// Shows a notification for a removed time slot.
  Future<void> showRemovedTimeSlotNotification({
    required String staffName,
    required TimeSlot timeSlot,
  }) async {
    final String formattedDate = timeSlot.date;
    final String timeRange = '${timeSlot.startTime} - ${timeSlot.endTime}';

    await showScheduleChangeNotification(
      title: 'Time Slot Removed',
      body: '$staffName\'s time slot on $formattedDate at $timeRange has been removed',
      payload: 'timeSlot:${timeSlot.date}',
    );
  }

  /// Checks if notifications are enabled.
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  /// Enables or disables notifications.
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  /// Schedules a notification for an upcoming time slot.
  Future<void> scheduleTimeSlotReminder({
    required String staffName,
    required TimeSlot timeSlot,
    required int minutesBefore,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Check if notifications are enabled
    final bool enabled = await areNotificationsEnabled();
    if (!enabled) return;

    // Parse the date and time
    final List<String> dateParts = timeSlot.date.split('-');
    final List<String> timeParts = timeSlot.startTime.split(':');

    if (dateParts.length != 3 || timeParts.length != 2) {
      print('Invalid date or time format');
      return;
    }

    final int year = int.parse(dateParts[0]);
    final int month = int.parse(dateParts[1]);
    final int day = int.parse(dateParts[2]);
    final int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);

    final DateTime scheduledTime = DateTime(year, month, day, hour, minute);
    final DateTime reminderTime = scheduledTime.subtract(Duration(minutes: minutesBefore));

    // Don't schedule if the reminder time is in the past
    if (reminderTime.isBefore(DateTime.now())) {
      print('Reminder time is in the past');
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'schedule_reminders',
      'Schedule Reminders',
      channelDescription: 'Reminders for upcoming staff schedules',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Note: For proper timezone handling, you would need to add the timezone package
    // and use TZDateTime. For simplicity, we're using a regular scheduled notification.
    await _notificationsPlugin.schedule(
      timeSlot.hashCode,
      'Upcoming Appointment',
      'You have an appointment with $staffName in $minutesBefore minutes',
      reminderTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      payload: 'timeSlot:${timeSlot.date}',
    );
  }
}
