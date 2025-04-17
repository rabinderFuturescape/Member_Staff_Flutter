import 'package:flutter_test/flutter_test.dart';
import 'package:member_staff_app/src/models/schedule.dart';
import 'package:member_staff_app/src/utils/date_time_utils.dart';

void main() {
  group('TimeSlot', () {
    test('should create a valid TimeSlot', () {
      final timeSlot = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      expect(timeSlot.date, '2023-05-15');
      expect(timeSlot.startTime, '09:00');
      expect(timeSlot.endTime, '10:00');
      expect(timeSlot.isBooked, true);
    });
    
    test('should throw FormatException for invalid date format', () {
      expect(() => TimeSlot(
        date: '15-05-2023', // Invalid format, should be yyyy-MM-dd
        startTime: '09:00',
        endTime: '10:00',
      ), throwsA(isA<FormatException>()));
    });
    
    test('should throw FormatException for invalid time format', () {
      expect(() => TimeSlot(
        date: '2023-05-15',
        startTime: '9:00', // Invalid format, should be HH:mm
        endTime: '10:00',
      ), throwsA(isA<FormatException>()));
      
      expect(() => TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10', // Invalid format, should be HH:mm
      ), throwsA(isA<FormatException>()));
    });
    
    test('should throw ArgumentError if end time is before start time', () {
      expect(() => TimeSlot(
        date: '2023-05-15',
        startTime: '10:00',
        endTime: '09:00', // End time before start time
      ), throwsA(isA<ArgumentError>()));
    });
    
    test('should correctly detect overlapping time slots', () {
      final slot1 = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '11:00',
      );
      
      final slot2 = TimeSlot(
        date: '2023-05-15',
        startTime: '10:00',
        endTime: '12:00',
      );
      
      final slot3 = TimeSlot(
        date: '2023-05-15',
        startTime: '11:00',
        endTime: '13:00',
      );
      
      final slot4 = TimeSlot(
        date: '2023-05-16', // Different date
        startTime: '09:00',
        endTime: '11:00',
      );
      
      // Slots on the same date with overlapping times
      expect(slot1.overlaps(slot2), true);
      expect(slot2.overlaps(slot1), true);
      
      // Slots on the same date with non-overlapping times
      expect(slot1.overlaps(slot3), false);
      expect(slot3.overlaps(slot1), false);
      
      // Slots on different dates
      expect(slot1.overlaps(slot4), false);
      expect(slot4.overlaps(slot1), false);
    });
    
    test('should correctly calculate duration in minutes', () {
      final slot1 = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final slot2 = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '09:30',
      );
      
      expect(slot1.durationInMinutes, 60);
      expect(slot2.durationInMinutes, 30);
    });
    
    test('should correctly format date and time for display', () {
      final slot = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      // Note: The exact format depends on the locale, so we're just checking that formatting happens
      expect(slot.formattedDate.contains('2023'), true);
      expect(slot.formattedStartTime.isNotEmpty, true);
      expect(slot.formattedEndTime.isNotEmpty, true);
      expect(slot.formattedTimeRange.contains('-'), true);
    });
    
    test('should correctly convert to and from JSON', () {
      final slot = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
        isBooked: true,
      );
      
      final json = slot.toJson();
      final fromJson = TimeSlot.fromJson(json);
      
      expect(fromJson.date, slot.date);
      expect(fromJson.startTime, slot.startTime);
      expect(fromJson.endTime, slot.endTime);
      expect(fromJson.isBooked, slot.isBooked);
    });
    
    test('should create a copy with updated values', () {
      final slot = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final copy = slot.copyWith(
        date: '2023-05-16',
        startTime: '10:00',
      );
      
      expect(copy.date, '2023-05-16');
      expect(copy.startTime, '10:00');
      expect(copy.endTime, '10:00'); // Unchanged
      expect(copy.isBooked, true); // Unchanged
    });
  });
}
