/// Model representing a time slot in a staff member's schedule.
class TimeSlot {
  final String? id;
  final String? staffId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isBooked;
  
  TimeSlot({
    this.id,
    this.staffId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isBooked = true,
  });
  
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      staffId: json['staff_id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      isBooked: json['is_booked'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (staffId != null) 'staff_id': staffId,
      'date': date.toIso8601String().split('T').first,
      'start_time': startTime,
      'end_time': endTime,
      'is_booked': isBooked,
    };
  }
  
  TimeSlot copyWith({
    String? id,
    String? staffId,
    DateTime? date,
    String? startTime,
    String? endTime,
    bool? isBooked,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBooked: isBooked ?? this.isBooked,
    );
  }
  
  /// Checks if this time slot overlaps with another time slot.
  bool overlaps(TimeSlot other) {
    // Different dates don't overlap
    if (date.year != other.date.year || 
        date.month != other.date.month || 
        date.day != other.date.day) {
      return false;
    }
    
    // Convert times to minutes for easier comparison
    final thisStart = _timeToMinutes(startTime);
    final thisEnd = _timeToMinutes(endTime);
    final otherStart = _timeToMinutes(other.startTime);
    final otherEnd = _timeToMinutes(other.endTime);
    
    // Check for overlap
    return thisStart < otherEnd && thisEnd > otherStart;
  }
  
  /// Converts a time string (HH:MM) to minutes.
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
