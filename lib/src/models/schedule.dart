import '../utils/date_time_utils.dart';

/// Model class representing a time slot in a schedule.
class TimeSlot {
  final String date;
  final String startTime;
  final String endTime;
  final bool isBooked;

  TimeSlot({
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isBooked = true,
  }) {
    // Validate date and time formats
    if (!DateTimeUtils.isValidDateFormat(date)) {
      throw FormatException('Invalid date format: $date. Expected format: yyyy-MM-dd');
    }
    if (!DateTimeUtils.isValidTimeFormat(startTime)) {
      throw FormatException('Invalid start time format: $startTime. Expected format: HH:mm');
    }
    if (!DateTimeUtils.isValidTimeFormat(endTime)) {
      throw FormatException('Invalid end time format: $endTime. Expected format: HH:mm');
    }

    // Validate that end time is after start time
    if (!DateTimeUtils.isTimeAfter(endTime, startTime)) {
      throw ArgumentError('End time must be after start time');
    }
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      isBooked: json['is_booked'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'is_booked': isBooked,
    };
  }

  /// Creates a copy of this TimeSlot with the given fields replaced with the new values.
  TimeSlot copyWith({
    String? date,
    String? startTime,
    String? endTime,
    bool? isBooked,
  }) {
    return TimeSlot(
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBooked: isBooked ?? this.isBooked,
    );
  }

  /// Checks if this time slot overlaps with another time slot.
  bool overlaps(TimeSlot other) {
    if (date != other.date) return false;

    // Check for overlap using DateTimeUtils
    return !DateTimeUtils.isTimeAfter(startTime, other.endTime) &&
           !DateTimeUtils.isTimeAfter(other.startTime, endTime);
  }

  /// Gets the duration of this time slot in minutes.
  int get durationInMinutes => DateTimeUtils.getDurationInMinutes(startTime, endTime);

  /// Gets the formatted date for display.
  String get formattedDate => DateTimeUtils.formatDateForDisplay(date);

  /// Gets the formatted start time for display.
  String get formattedStartTime => DateTimeUtils.formatTimeForDisplay(startTime);

  /// Gets the formatted end time for display.
  String get formattedEndTime => DateTimeUtils.formatTimeForDisplay(endTime);

  /// Gets the formatted time range for display.
  String get formattedTimeRange => '$formattedStartTime - $formattedEndTime';

  @override
  String toString() => 'TimeSlot(date: $date, startTime: $startTime, endTime: $endTime, isBooked: $isBooked)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeSlot &&
        other.date == date &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.isBooked == isBooked;
  }

  @override
  int get hashCode => date.hashCode ^ startTime.hashCode ^ endTime.hashCode ^ isBooked.hashCode;
}

/// Model class representing a staff schedule.
class Schedule {
  final List<TimeSlot> bookedSlots;

  Schedule({
    required this.bookedSlots,
  });

  /// Creates an empty schedule.
  factory Schedule.empty() => Schedule(bookedSlots: []);

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

  /// Updates a time slot in the schedule.
  /// Returns true if the slot was updated successfully, false if it wasn't found or the update would cause an overlap.
  bool updateTimeSlot(TimeSlot oldSlot, TimeSlot newSlot) {
    // Find the index of the old slot
    int index = -1;
    for (int i = 0; i < bookedSlots.length; i++) {
      final slot = bookedSlots[i];
      if (slot.date == oldSlot.date &&
          slot.startTime == oldSlot.startTime &&
          slot.endTime == oldSlot.endTime) {
        index = i;
        break;
      }
    }

    // If the old slot wasn't found, return false
    if (index == -1) {
      return false;
    }

    // Remove the old slot temporarily
    bookedSlots.removeAt(index);

    // Check if the new slot would overlap with any existing slots
    for (final slot in bookedSlots) {
      if (slot.overlaps(newSlot)) {
        // Put the old slot back and return false
        bookedSlots.insert(index, oldSlot);
        return false;
      }
    }

    // No overlaps, add the new slot
    bookedSlots.insert(index, newSlot);
    return true;
  }

  /// Gets all booked slots for a specific date.
  List<TimeSlot> getBookedSlotsForDate(String date) {
    return bookedSlots.where((slot) => slot.date == date).toList();
  }

  /// Gets all booked slots for a date range.
  List<TimeSlot> getBookedSlotsForDateRange(String startDate, String endDate) {
    return bookedSlots.where((slot) {
      return slot.date.compareTo(startDate) >= 0 && slot.date.compareTo(endDate) <= 0;
    }).toList();
  }

  /// Checks if a specific date and time is available (not booked).
  bool isAvailable(String date, String time) {
    return !bookedSlots.any((slot) {
      return slot.date == date &&
             !DateTimeUtils.isTimeAfter(time, slot.endTime) &&
             !DateTimeUtils.isTimeAfter(slot.startTime, time);
    });
  }

  /// Gets all dates that have booked slots.
  List<String> get bookedDates {
    final dates = bookedSlots.map((slot) => slot.date).toSet().toList();
    dates.sort();
    return dates;
  }

  /// Gets the total number of booked slots.
  int get totalBookedSlots => bookedSlots.length;

  /// Gets the total duration of all booked slots in minutes.
  int get totalDurationInMinutes {
    return bookedSlots.fold(0, (sum, slot) => sum + slot.durationInMinutes);
  }

  @override
  String toString() => 'Schedule(bookedSlots: $bookedSlots)';
}
