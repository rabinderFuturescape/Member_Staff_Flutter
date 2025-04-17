import 'package:flutter_test/flutter_test.dart';
import 'package:member_staff_app/src/models/schedule.dart';

void main() {
  group('Schedule', () {
    test('should create an empty schedule', () {
      final schedule = Schedule.empty();
      expect(schedule.bookedSlots, isEmpty);
    });
    
    test('should add a time slot to the schedule', () {
      final schedule = Schedule.empty();
      final slot = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final result = schedule.addTimeSlot(slot);
      
      expect(result, true);
      expect(schedule.bookedSlots.length, 1);
      expect(schedule.bookedSlots.first.date, '2023-05-15');
      expect(schedule.bookedSlots.first.startTime, '09:00');
      expect(schedule.bookedSlots.first.endTime, '10:00');
    });
    
    test('should not add overlapping time slots', () {
      final schedule = Schedule.empty();
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
      
      final result1 = schedule.addTimeSlot(slot1);
      final result2 = schedule.addTimeSlot(slot2);
      
      expect(result1, true);
      expect(result2, false);
      expect(schedule.bookedSlots.length, 1);
    });
    
    test('should remove a time slot from the schedule', () {
      final schedule = Schedule.empty();
      final slot = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      schedule.addTimeSlot(slot);
      final result = schedule.removeTimeSlot(slot);
      
      expect(result, true);
      expect(schedule.bookedSlots, isEmpty);
    });
    
    test('should return false when removing a non-existent time slot', () {
      final schedule = Schedule.empty();
      final slot = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final result = schedule.removeTimeSlot(slot);
      
      expect(result, false);
    });
    
    test('should update a time slot in the schedule', () {
      final schedule = Schedule.empty();
      final oldSlot = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final newSlot = TimeSlot(
        date: '2023-05-15',
        startTime: '10:00',
        endTime: '11:00',
      );
      
      schedule.addTimeSlot(oldSlot);
      final result = schedule.updateTimeSlot(oldSlot, newSlot);
      
      expect(result, true);
      expect(schedule.bookedSlots.length, 1);
      expect(schedule.bookedSlots.first.startTime, '10:00');
      expect(schedule.bookedSlots.first.endTime, '11:00');
    });
    
    test('should not update to an overlapping time slot', () {
      final schedule = Schedule.empty();
      final slot1 = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final slot2 = TimeSlot(
        date: '2023-05-15',
        startTime: '11:00',
        endTime: '12:00',
      );
      
      final newSlot = TimeSlot(
        date: '2023-05-15',
        startTime: '08:00',
        endTime: '11:30',
      );
      
      schedule.addTimeSlot(slot1);
      schedule.addTimeSlot(slot2);
      
      final result = schedule.updateTimeSlot(slot1, newSlot);
      
      expect(result, false);
      expect(schedule.bookedSlots.length, 2);
      expect(schedule.bookedSlots.first.startTime, '09:00');
    });
    
    test('should get booked slots for a specific date', () {
      final schedule = Schedule.empty();
      final slot1 = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final slot2 = TimeSlot(
        date: '2023-05-15',
        startTime: '11:00',
        endTime: '12:00',
      );
      
      final slot3 = TimeSlot(
        date: '2023-05-16',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      schedule.addTimeSlot(slot1);
      schedule.addTimeSlot(slot2);
      schedule.addTimeSlot(slot3);
      
      final slotsForDate = schedule.getBookedSlotsForDate('2023-05-15');
      
      expect(slotsForDate.length, 2);
      expect(slotsForDate[0].date, '2023-05-15');
      expect(slotsForDate[1].date, '2023-05-15');
    });
    
    test('should get booked slots for a date range', () {
      final schedule = Schedule.empty();
      final slot1 = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final slot2 = TimeSlot(
        date: '2023-05-16',
        startTime: '11:00',
        endTime: '12:00',
      );
      
      final slot3 = TimeSlot(
        date: '2023-05-17',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final slot4 = TimeSlot(
        date: '2023-05-18',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      schedule.addTimeSlot(slot1);
      schedule.addTimeSlot(slot2);
      schedule.addTimeSlot(slot3);
      schedule.addTimeSlot(slot4);
      
      final slotsForRange = schedule.getBookedSlotsForDateRange('2023-05-16', '2023-05-17');
      
      expect(slotsForRange.length, 2);
      expect(slotsForRange[0].date, '2023-05-16');
      expect(slotsForRange[1].date, '2023-05-17');
    });
    
    test('should check if a specific date and time is available', () {
      final schedule = Schedule.empty();
      final slot = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '11:00',
      );
      
      schedule.addTimeSlot(slot);
      
      expect(schedule.isAvailable('2023-05-15', '08:00'), true);
      expect(schedule.isAvailable('2023-05-15', '09:30'), false);
      expect(schedule.isAvailable('2023-05-15', '11:00'), true);
      expect(schedule.isAvailable('2023-05-16', '09:30'), true);
    });
    
    test('should get all booked dates', () {
      final schedule = Schedule.empty();
      final slot1 = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final slot2 = TimeSlot(
        date: '2023-05-15',
        startTime: '11:00',
        endTime: '12:00',
      );
      
      final slot3 = TimeSlot(
        date: '2023-05-16',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      schedule.addTimeSlot(slot1);
      schedule.addTimeSlot(slot2);
      schedule.addTimeSlot(slot3);
      
      final bookedDates = schedule.bookedDates;
      
      expect(bookedDates.length, 2);
      expect(bookedDates[0], '2023-05-15');
      expect(bookedDates[1], '2023-05-16');
    });
    
    test('should get total number of booked slots', () {
      final schedule = Schedule.empty();
      final slot1 = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final slot2 = TimeSlot(
        date: '2023-05-15',
        startTime: '11:00',
        endTime: '12:00',
      );
      
      schedule.addTimeSlot(slot1);
      schedule.addTimeSlot(slot2);
      
      expect(schedule.totalBookedSlots, 2);
    });
    
    test('should get total duration of all booked slots in minutes', () {
      final schedule = Schedule.empty();
      final slot1 = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final slot2 = TimeSlot(
        date: '2023-05-15',
        startTime: '11:00',
        endTime: '12:30',
      );
      
      schedule.addTimeSlot(slot1);
      schedule.addTimeSlot(slot2);
      
      expect(schedule.totalDurationInMinutes, 150); // 60 + 90 minutes
    });
    
    test('should correctly convert to and from JSON', () {
      final schedule = Schedule.empty();
      final slot1 = TimeSlot(
        date: '2023-05-15',
        startTime: '09:00',
        endTime: '10:00',
      );
      
      final slot2 = TimeSlot(
        date: '2023-05-16',
        startTime: '11:00',
        endTime: '12:00',
      );
      
      schedule.addTimeSlot(slot1);
      schedule.addTimeSlot(slot2);
      
      final json = schedule.toJson();
      final fromJson = Schedule.fromJson(json);
      
      expect(fromJson.bookedSlots.length, 2);
      expect(fromJson.bookedSlots[0].date, '2023-05-15');
      expect(fromJson.bookedSlots[0].startTime, '09:00');
      expect(fromJson.bookedSlots[1].date, '2023-05-16');
      expect(fromJson.bookedSlots[1].startTime, '11:00');
    });
  });
}
