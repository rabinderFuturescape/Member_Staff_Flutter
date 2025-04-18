import 'package:flutter/material.dart';

/// Model representing a staff attendance entry
class StaffAttendance {
  final String staffId;
  final String staffName;
  final String? staffPhoto;
  final String staffCategory;
  final String status;
  final String? note;
  final String? photoUrl;
  
  StaffAttendance({
    required this.staffId,
    required this.staffName,
    this.staffPhoto,
    required this.staffCategory,
    required this.status,
    this.note,
    this.photoUrl,
  });
  
  factory StaffAttendance.fromJson(Map<String, dynamic> json) {
    return StaffAttendance(
      staffId: json['staff_id'].toString(),
      staffName: json['staff_name'] ?? 'Unknown',
      staffPhoto: json['staff_photo'],
      staffCategory: json['staff_category'] ?? 'Staff',
      status: json['status'],
      note: json['note'],
      photoUrl: json['photo_url'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'status': status,
      'note': note,
      'photo_url': photoUrl,
    };
  }
  
  Color get statusColor {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  IconData get statusIcon {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      default:
        return Icons.circle_outlined;
    }
  }
  
  StaffAttendance copyWith({
    String? staffId,
    String? staffName,
    String? staffPhoto,
    String? staffCategory,
    String? status,
    String? note,
    String? photoUrl,
  }) {
    return StaffAttendance(
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      staffPhoto: staffPhoto ?? this.staffPhoto,
      staffCategory: staffCategory ?? this.staffCategory,
      status: status ?? this.status,
      note: note ?? this.note,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

/// Model representing a day's attendance status for calendar display
class DayAttendanceStatus {
  final DateTime date;
  final Map<String, StaffAttendance> staffAttendances;
  
  DayAttendanceStatus({
    required this.date,
    required this.staffAttendances,
  });
  
  /// Get the overall status for the day
  String get overallStatus {
    if (staffAttendances.isEmpty) {
      return 'not_marked';
    }
    
    bool hasPresent = false;
    bool hasAbsent = false;
    
    for (final attendance in staffAttendances.values) {
      if (attendance.status == 'present') {
        hasPresent = true;
      } else if (attendance.status == 'absent') {
        hasAbsent = true;
      }
    }
    
    if (hasPresent && hasAbsent) {
      return 'mixed';
    } else if (hasPresent) {
      return 'present';
    } else if (hasAbsent) {
      return 'absent';
    } else {
      return 'not_marked';
    }
  }
  
  /// Get the color for the day's status
  Color get statusColor {
    switch (overallStatus) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'mixed':
        return Colors.orange;
      default:
        return Colors.grey.shade300;
    }
  }
  
  /// Get the icon for the day's status
  IconData get statusIcon {
    switch (overallStatus) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'mixed':
        return Icons.warning;
      default:
        return Icons.circle_outlined;
    }
  }
}
