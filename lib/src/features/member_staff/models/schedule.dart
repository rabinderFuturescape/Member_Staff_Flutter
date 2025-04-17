import 'time_slot.dart';

/// Model representing a staff member's schedule.
class Schedule {
  final String staffId;
  final List<TimeSlot> bookedSlots;
  
  Schedule({
    required this.staffId,
    required this.bookedSlots,
  });
  
  factory Schedule.fromJson(Map<String, dynamic> json) {
    final List<dynamic> slots = json['booked_slots'] ?? [];
    
    return Schedule(
      staffId: json['staff_id'],
      bookedSlots: slots.map((slot) => TimeSlot.fromJson(slot)).toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'booked_slots': bookedSlots.map((slot) => slot.toJson()).toList(),
    };
  }
  
  Schedule copyWith({
    String? staffId,
    List<TimeSlot>? bookedSlots,
  }) {
    return Schedule(
      staffId: staffId ?? this.staffId,
      bookedSlots: bookedSlots ?? this.bookedSlots,
    );
  }
  
  /// Gets all time slots for a specific date.
  List<TimeSlot> getSlotsForDate(DateTime date) {
    return bookedSlots.where((slot) => 
      slot.date.year == date.year && 
      slot.date.month == date.month && 
      slot.date.day == date.day
    ).toList();
  }
  
  /// Adds a time slot to the schedule.
  Schedule addTimeSlot(TimeSlot newSlot) {
    // Check for overlaps
    for (final slot in bookedSlots) {
      if (slot.overlaps(newSlot)) {
        throw Exception('Time slot overlaps with an existing slot');
      }
    }
    
    final updatedSlots = List<TimeSlot>.from(bookedSlots)..add(newSlot);
    return copyWith(bookedSlots: updatedSlots);
  }
  
  /// Removes a time slot from the schedule.
  Schedule removeTimeSlot(TimeSlot slotToRemove) {
    final updatedSlots = bookedSlots.where((slot) => 
      !(slot.date.year == slotToRemove.date.year && 
        slot.date.month == slotToRemove.date.month && 
        slot.date.day == slotToRemove.date.day && 
        slot.startTime == slotToRemove.startTime && 
        slot.endTime == slotToRemove.endTime)
    ).toList();
    
    return copyWith(bookedSlots: updatedSlots);
  }
  
  /// Updates a time slot in the schedule.
  Schedule updateTimeSlot(TimeSlot oldSlot, TimeSlot newSlot) {
    // First remove the old slot
    final tempSchedule = removeTimeSlot(oldSlot);
    
    // Then add the new slot (this will check for overlaps)
    return tempSchedule.addTimeSlot(newSlot);
  }
}
