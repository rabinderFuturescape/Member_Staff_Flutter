/// Model class representing a time slot in a schedule.
class TimeSlot {
  final String date;
  final String startTime;
  final String endTime;

  TimeSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  /// Checks if this time slot overlaps with another time slot.
  bool overlaps(TimeSlot other) {
    if (date != other.date) return false;
    
    // Convert times to comparable format (assuming 24-hour format)
    final thisStart = startTime;
    final thisEnd = endTime;
    final otherStart = other.startTime;
    final otherEnd = other.endTime;
    
    // Check for overlap
    return (thisStart < otherEnd && thisEnd > otherStart);
  }
}

/// Model class representing a staff schedule.
class Schedule {
  final List<TimeSlot> bookedSlots;

  Schedule({
    required this.bookedSlots,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final List<dynamic> slots = json['booked_slots'] ?? [];
    return Schedule(
      bookedSlots: slots.map((slot) => TimeSlot.fromJson(slot)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booked_slots': bookedSlots.map((slot) => slot.toJson()).toList(),
    };
  }

  /// Adds a new time slot to the schedule if it doesn't overlap with existing slots.
  /// Returns true if the slot was added successfully, false otherwise.
  bool addTimeSlot(TimeSlot newSlot) {
    // Check for overlaps
    for (final slot in bookedSlots) {
      if (slot.overlaps(newSlot)) {
        return false;
      }
    }
    
    // No overlaps, add the slot
    bookedSlots.add(newSlot);
    return true;
  }

  /// Removes a time slot from the schedule.
  /// Returns true if the slot was removed successfully, false if it wasn't found.
  bool removeTimeSlot(TimeSlot slotToRemove) {
    for (int i = 0; i < bookedSlots.length; i++) {
      final slot = bookedSlots[i];
      if (slot.date == slotToRemove.date &&
          slot.startTime == slotToRemove.startTime &&
          slot.endTime == slotToRemove.endTime) {
        bookedSlots.removeAt(i);
        return true;
      }
    }
    return false;
  }

  /// Gets all booked slots for a specific date.
  List<TimeSlot> getBookedSlotsForDate(String date) {
    return bookedSlots.where((slot) => slot.date == date).toList();
  }
}
