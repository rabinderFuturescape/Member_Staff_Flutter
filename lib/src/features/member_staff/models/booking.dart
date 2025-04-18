import 'package:flutter/material.dart';

/// Model representing a booking request
class BookingRequest {
  final String staffId;
  final String memberId;
  final String unitId;
  final String companyId;
  final String startDate;
  final String endDate;
  final String repeatType;
  final List<int> slotHours;
  final String? notes;
  
  BookingRequest({
    required this.staffId,
    required this.memberId,
    required this.unitId,
    required this.companyId,
    required this.startDate,
    required this.endDate,
    required this.repeatType,
    required this.slotHours,
    this.notes,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'member_id': memberId,
      'unit_id': unitId,
      'company_id': companyId,
      'start_date': startDate,
      'end_date': endDate,
      'repeat_type': repeatType,
      'slot_hours': slotHours,
      'notes': notes,
    };
  }
}

/// Model representing a booking response
class BookingResponse {
  final String status;
  final String bookingId;
  
  BookingResponse({
    required this.status,
    required this.bookingId,
  });
  
  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      status: json['status'],
      bookingId: json['booking_id'].toString(),
    );
  }
}

/// Model representing a booking slot view (flattened booking with slot)
class BookingSlotView {
  final String bookingId;
  final String staffId;
  final DateTime date;
  final int hour;
  final String status;
  
  BookingSlotView({
    required this.bookingId,
    required this.staffId,
    required this.date,
    required this.hour,
    required this.status,
  });
  
  factory BookingSlotView.fromJson(Map<String, dynamic> json) {
    return BookingSlotView(
      bookingId: json['booking_id'].toString(),
      staffId: json['staff_id'].toString(),
      date: DateTime.parse(json['date']),
      hour: json['hour'],
      status: json['status'],
    );
  }
  
  String get formattedDate => '${date.day}/${date.month}/${date.year}';
  
  String get formattedTime => '${hour.toString().padLeft(2, '0')}:00';
  
  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'rescheduled':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Model representing hourly availability
class HourlyAvailability {
  final int hour;
  final bool isBooked;
  
  HourlyAvailability({
    required this.hour,
    required this.isBooked,
  });
  
  factory HourlyAvailability.fromJson(Map<String, dynamic> json) {
    return HourlyAvailability(
      hour: json['hour'],
      isBooked: json['is_booked'],
    );
  }
  
  String get formattedTime => '${hour.toString().padLeft(2, '0')}:00';
}
