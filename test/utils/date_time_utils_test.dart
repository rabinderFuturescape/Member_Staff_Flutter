import 'package:flutter_test/flutter_test.dart';
import 'package:member_staff_app/src/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils', () {
    test('should validate date format correctly', () {
      expect(DateTimeUtils.isValidDateFormat('2023-05-15'), true);
      expect(DateTimeUtils.isValidDateFormat('2023-5-15'), false);
      expect(DateTimeUtils.isValidDateFormat('15-05-2023'), false);
      expect(DateTimeUtils.isValidDateFormat('2023/05/15'), false);
      expect(DateTimeUtils.isValidDateFormat('invalid'), false);
    });
    
    test('should validate time format correctly', () {
      expect(DateTimeUtils.isValidTimeFormat('09:00'), true);
      expect(DateTimeUtils.isValidTimeFormat('9:00'), false);
      expect(DateTimeUtils.isValidTimeFormat('09:0'), false);
      expect(DateTimeUtils.isValidTimeFormat('09:00:00'), false);
      expect(DateTimeUtils.isValidTimeFormat('invalid'), false);
    });
    
    test('should parse date correctly', () {
      final date = DateTimeUtils.parseDate('2023-05-15');
      expect(date.year, 2023);
      expect(date.month, 5);
      expect(date.day, 15);
    });
    
    test('should parse time correctly', () {
      final time = DateTimeUtils.parseTime('09:30');
      expect(time.hour, 9);
      expect(time.minute, 30);
    });
    
    test('should format date correctly', () {
      final date = DateTime(2023, 5, 15);
      expect(DateTimeUtils.formatDate(date), '2023-05-15');
    });
    
    test('should format time correctly', () {
      final time = DateTime(2023, 5, 15, 9, 30);
      expect(DateTimeUtils.formatTime(time), '09:30');
    });
    
    test('should check if a time is before another time', () {
      expect(DateTimeUtils.isTimeBefore('09:00', '10:00'), true);
      expect(DateTimeUtils.isTimeBefore('10:00', '09:00'), false);
      expect(DateTimeUtils.isTimeBefore('09:00', '09:00'), false);
    });
    
    test('should check if a time is after another time', () {
      expect(DateTimeUtils.isTimeAfter('10:00', '09:00'), true);
      expect(DateTimeUtils.isTimeAfter('09:00', '10:00'), false);
      expect(DateTimeUtils.isTimeAfter('09:00', '09:00'), false);
    });
    
    test('should calculate duration between times in minutes', () {
      expect(DateTimeUtils.getDurationInMinutes('09:00', '10:00'), 60);
      expect(DateTimeUtils.getDurationInMinutes('09:00', '09:30'), 30);
      expect(DateTimeUtils.getDurationInMinutes('09:00', '11:15'), 135);
    });
    
    test('should get current date in API format', () {
      final currentDate = DateTimeUtils.getCurrentDate();
      expect(DateTimeUtils.isValidDateFormat(currentDate), true);
    });
    
    test('should get current time in API format', () {
      final currentTime = DateTimeUtils.getCurrentTime();
      expect(DateTimeUtils.isValidTimeFormat(currentTime), true);
    });
    
    test('should format date for display', () {
      final displayDate = DateTimeUtils.formatDateForDisplay('2023-05-15');
      expect(displayDate.contains('2023'), true);
      expect(displayDate.contains('15'), true);
    });
    
    test('should format time for display', () {
      final displayTime = DateTimeUtils.formatTimeForDisplay('09:00');
      expect(displayTime.isNotEmpty, true);
    });
  });
}
