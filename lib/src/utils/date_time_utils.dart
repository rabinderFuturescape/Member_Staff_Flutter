import 'package:intl/intl.dart';

/// Utility class for date and time operations.
class DateTimeUtils {
  /// Date format for API communication (yyyy-MM-dd).
  static final DateFormat apiDateFormat = DateFormat('yyyy-MM-dd');
  
  /// Time format for API communication (HH:mm).
  static final DateFormat apiTimeFormat = DateFormat('HH:mm');
  
  /// Display date format (EEEE, MMMM d, yyyy).
  static final DateFormat displayDateFormat = DateFormat('EEEE, MMMM d, yyyy');
  
  /// Display time format (h:mm a).
  static final DateFormat displayTimeFormat = DateFormat('h:mm a');
  
  /// Validates if a string is in the correct date format (yyyy-MM-dd).
  static bool isValidDateFormat(String date) {
    try {
      apiDateFormat.parseStrict(date);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Validates if a string is in the correct time format (HH:mm).
  static bool isValidTimeFormat(String time) {
    try {
      apiTimeFormat.parseStrict(time);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Converts a date string to a DateTime object.
  static DateTime parseDate(String date) {
    return apiDateFormat.parseStrict(date);
  }
  
  /// Converts a time string to a DateTime object (using today's date).
  static DateTime parseTime(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
  
  /// Formats a DateTime object to a date string (yyyy-MM-dd).
  static String formatDate(DateTime date) {
    return apiDateFormat.format(date);
  }
  
  /// Formats a DateTime object to a time string (HH:mm).
  static String formatTime(DateTime time) {
    return apiTimeFormat.format(time);
  }
  
  /// Formats a date string for display (EEEE, MMMM d, yyyy).
  static String formatDateForDisplay(String date) {
    final dateTime = parseDate(date);
    return displayDateFormat.format(dateTime);
  }
  
  /// Formats a time string for display (h:mm a).
  static String formatTimeForDisplay(String time) {
    final dateTime = parseTime(time);
    return displayTimeFormat.format(dateTime);
  }
  
  /// Checks if a time is before another time.
  static bool isTimeBefore(String time1, String time2) {
    final dateTime1 = parseTime(time1);
    final dateTime2 = parseTime(time2);
    return dateTime1.isBefore(dateTime2);
  }
  
  /// Checks if a time is after another time.
  static bool isTimeAfter(String time1, String time2) {
    final dateTime1 = parseTime(time1);
    final dateTime2 = parseTime(time2);
    return dateTime1.isAfter(dateTime2);
  }
  
  /// Calculates the duration between two times in minutes.
  static int getDurationInMinutes(String startTime, String endTime) {
    final start = parseTime(startTime);
    final end = parseTime(endTime);
    return end.difference(start).inMinutes;
  }
  
  /// Gets the current date in API format (yyyy-MM-dd).
  static String getCurrentDate() {
    return formatDate(DateTime.now());
  }
  
  /// Gets the current time in API format (HH:mm).
  static String getCurrentTime() {
    return formatTime(DateTime.now());
  }
}
