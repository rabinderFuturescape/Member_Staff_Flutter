# Member Staff Module - Models Documentation

This document provides a comprehensive overview of all data models used in the Member Staff module. It serves as a reference for developers to understand the data structure and relationships.

## Table of Contents

1. [Staff Model](#staff-model)
2. [TimeSlot Model](#timeslot-model)
3. [Schedule Model](#schedule-model)
4. [Member Model](#member-model)
5. [Unit Model](#unit-model)
6. [MemberStaffAssignment Model](#memberstaffassignment-model)
7. [StaffScope Enum](#staffscope-enum)
8. [ApiResponse Model](#apiresponse-model)
9. [ApiException Model](#apiexception-model)
10. [AuthUser Model](#authuser-model)

## Staff Model

**Path**: `lib/src/features/member_staff/models/staff.dart`

Represents a staff member with their personal and verification details.

```dart
class Staff {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final StaffScope staffScope;
  final String? department;
  final String? designation;
  final String? societyId;
  final String? unitId;
  final String companyId;
  final String? aadhaarNumber;
  final String? residentialAddress;
  final String? nextOfKinName;
  final String? nextOfKinMobile;
  final String? photoUrl;
  final bool isVerified;
  final DateTime? verifiedAt;
  final String? verifiedByMemberId;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Staff({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.staffScope,
    this.department,
    this.designation,
    this.societyId,
    this.unitId,
    required this.companyId,
    this.aadhaarNumber,
    this.residentialAddress,
    this.nextOfKinName,
    this.nextOfKinMobile,
    this.photoUrl,
    required this.isVerified,
    this.verifiedAt,
    this.verifiedByMemberId,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Factory constructor to create a Staff from JSON
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      email: json['email'],
      staffScope: StaffScope.values.firstWhere(
        (e) => e.toString().split('.').last == json['staff_scope'],
        orElse: () => StaffScope.member,
      ),
      department: json['department'],
      designation: json['designation'],
      societyId: json['society_id'],
      unitId: json['unit_id'],
      companyId: json['company_id'],
      aadhaarNumber: json['aadhaar_number'],
      residentialAddress: json['residential_address'],
      nextOfKinName: json['next_of_kin_name'],
      nextOfKinMobile: json['next_of_kin_mobile'],
      photoUrl: json['photo_url'],
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      verifiedByMemberId: json['verified_by_member_id'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  // Convert Staff to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'staff_scope': staffScope.toString().split('.').last,
      'department': department,
      'designation': designation,
      'society_id': societyId,
      'unit_id': unitId,
      'company_id': companyId,
      'aadhaar_number': aadhaarNumber,
      'residential_address': residentialAddress,
      'next_of_kin_name': nextOfKinName,
      'next_of_kin_mobile': nextOfKinMobile,
      'photo_url': photoUrl,
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by_member_id': verifiedByMemberId,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create a copy of Staff with some fields updated
  Staff copyWith({
    String? name,
    String? email,
    String? department,
    String? designation,
    String? aadhaarNumber,
    String? residentialAddress,
    String? nextOfKinName,
    String? nextOfKinMobile,
    String? photoUrl,
    bool? isVerified,
    DateTime? verifiedAt,
    String? verifiedByMemberId,
    String? updatedBy,
  }) {
    return Staff(
      id: id,
      name: name ?? this.name,
      mobile: mobile,
      email: email ?? this.email,
      staffScope: staffScope,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      societyId: societyId,
      unitId: unitId,
      companyId: companyId,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      nextOfKinName: nextOfKinName ?? this.nextOfKinName,
      nextOfKinMobile: nextOfKinMobile ?? this.nextOfKinMobile,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedByMemberId: verifiedByMemberId ?? this.verifiedByMemberId,
      createdBy: createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
```

## TimeSlot Model

**Path**: `lib/src/features/member_staff/models/time_slot.dart`

Represents a time slot in a staff member's schedule.

```dart
class TimeSlot {
  final String? id;
  final String? staffId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isBooked;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  TimeSlot({
    this.id,
    this.staffId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
    this.createdAt,
    this.updatedAt,
  });
  
  // Factory constructor to create a TimeSlot from JSON
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      staffId: json['staff_id'],
      date: DateTime.parse(json['date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      isBooked: json['is_booked'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
  
  // Convert TimeSlot to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_id': staffId,
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'is_booked': isBooked,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  // Create a copy of TimeSlot with some fields updated
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
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
  
  // Check if this time slot overlaps with another time slot
  bool overlaps(TimeSlot other) {
    // Different dates don't overlap
    if (date.year != other.date.year ||
        date.month != other.date.month ||
        date.day != other.date.day) {
      return false;
    }
    
    // Convert times to minutes for easier comparison
    int thisStart = _timeToMinutes(startTime);
    int thisEnd = _timeToMinutes(endTime);
    int otherStart = _timeToMinutes(other.startTime);
    int otherEnd = _timeToMinutes(other.endTime);
    
    // Check for overlap
    return thisStart < otherEnd && thisEnd > otherStart;
  }
  
  // Convert a time string (HH:MM) to minutes
  int _timeToMinutes(String time) {
    List<String> parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}
```

## Schedule Model

**Path**: `lib/src/features/member_staff/models/schedule.dart`

Represents a staff member's schedule with time slots.

```dart
class Schedule {
  final Staff staff;
  final List<TimeSlot> timeSlots;
  final DateTime startDate;
  final DateTime endDate;
  
  Schedule({
    required this.staff,
    required this.timeSlots,
    required this.startDate,
    required this.endDate,
  });
  
  // Factory constructor to create a Schedule from JSON
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      staff: Staff.fromJson(json['staff']),
      timeSlots: (json['time_slots'] as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
    );
  }
  
  // Get time slots for a specific date
  List<TimeSlot> getTimeSlotsForDate(DateTime date) {
    return timeSlots.where((slot) =>
        slot.date.year == date.year &&
        slot.date.month == date.month &&
        slot.date.day == date.day
    ).toList();
  }
  
  // Check if a date has any time slots
  bool hasTimeSlotsForDate(DateTime date) {
    return getTimeSlotsForDate(date).isNotEmpty;
  }
  
  // Get all dates in the schedule that have time slots
  List<DateTime> getDatesWithTimeSlots() {
    Set<String> dateStrings = {};
    for (var slot in timeSlots) {
      dateStrings.add(slot.date.toIso8601String().split('T')[0]);
    }
    
    return dateStrings
        .map((dateStr) => DateTime.parse(dateStr))
        .toList()
        ..sort();
  }
}
```

## Member Model

**Path**: `lib/src/features/member_staff/models/member.dart`

Represents a member who can have staff assigned to them.

```dart
class Member {
  final String id;
  final String name;
  final String? email;
  final String mobile;
  final String unitId;
  final String companyId;
  final String unitNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Member({
    required this.id,
    required this.name,
    this.email,
    required this.mobile,
    required this.unitId,
    required this.companyId,
    required this.unitNumber,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Factory constructor to create a Member from JSON
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      unitId: json['unit_id'],
      companyId: json['company_id'],
      unitNumber: json['unit_number'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  // Convert Member to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'unit_id': unitId,
      'company_id': companyId,
      'unit_number': unitNumber,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
```

## Unit Model

**Path**: `lib/src/features/member_staff/models/unit.dart`

Represents a unit in a society/company.

```dart
class Unit {
  final String id;
  final String unitNumber;
  final String companyId;
  final String? block;
  final String? floor;
  final String? unitType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Unit({
    required this.id,
    required this.unitNumber,
    required this.companyId,
    this.block,
    this.floor,
    this.unitType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Factory constructor to create a Unit from JSON
  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      unitNumber: json['unit_number'],
      companyId: json['company_id'],
      block: json['block'],
      floor: json['floor'],
      unitType: json['unit_type'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  // Convert Unit to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_number': unitNumber,
      'company_id': companyId,
      'block': block,
      'floor': floor,
      'unit_type': unitType,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
```

## MemberStaffAssignment Model

**Path**: `lib/src/features/member_staff/models/member_staff_assignment.dart`

Represents the assignment of a staff to a member.

```dart
class MemberStaffAssignment {
  final String id;
  final String memberId;
  final String staffId;
  final String assignedBy;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  MemberStaffAssignment({
    required this.id,
    required this.memberId,
    required this.staffId,
    required this.assignedBy,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // Factory constructor to create a MemberStaffAssignment from JSON
  factory MemberStaffAssignment.fromJson(Map<String, dynamic> json) {
    return MemberStaffAssignment(
      id: json['id'],
      memberId: json['member_id'],
      staffId: json['staff_id'],
      assignedBy: json['assigned_by'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  // Convert MemberStaffAssignment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'staff_id': staffId,
      'assigned_by': assignedBy,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
```

## StaffScope Enum

**Path**: `lib/src/features/member_staff/models/staff_scope.dart`

Enum representing the scope of a staff member.

```dart
enum StaffScope {
  society,
  member,
}
```

## ApiResponse Model

**Path**: `lib/src/core/network/api_response.dart`

Represents a response from the API.

```dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  
  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });
  
  // Factory constructor to create an ApiResponse from JSON
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? fromJson(json['data']) : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
  
  // Factory constructor to create an ApiResponse with a list of items
  factory ApiResponse.fromJsonList(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((item) => fromJson(item)).toList() as T
          : null,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}
```

## ApiException Model

**Path**: `lib/src/core/exceptions/api_exception.dart`

Represents an exception thrown by the API.

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool isAuthError;
  final Map<String, dynamic>? errors;
  
  ApiException({
    required this.message,
    this.statusCode,
    this.isAuthError = false,
    this.errors,
  });
  
  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode)';
  }
}
```

## AuthUser Model

**Path**: `lib/src/models/auth_user.dart`

Represents an authenticated user with member context.

```dart
class AuthUser {
  final String memberId;
  final String unitId;
  final String companyId;
  final String name;
  final String? email;
  final DateTime tokenExpiry;
  
  AuthUser({
    required this.memberId,
    required this.unitId,
    required this.companyId,
    required this.name,
    this.email,
    required this.tokenExpiry,
  });
  
  // Factory constructor to create an AuthUser from a decoded JWT token
  factory AuthUser.fromToken(Map<String, dynamic> decodedToken) {
    return AuthUser(
      memberId: decodedToken['member_id'],
      unitId: decodedToken['unit_id'],
      companyId: decodedToken['company_id'],
      name: decodedToken['name'],
      email: decodedToken['email'],
      tokenExpiry: DateTime.fromMillisecondsSinceEpoch(
        decodedToken['exp'] * 1000,
      ),
    );
  }
  
  // Check if the token is expired
  bool get isTokenExpired => DateTime.now().isAfter(tokenExpiry);
  
  // Get the member context for API requests
  Map<String, String> get memberContext => {
    'member_id': memberId,
    'unit_id': unitId,
    'company_id': companyId,
  };
}
```

## Conclusion

This document provides a comprehensive overview of all data models used in the Member Staff module. It serves as a reference for developers to understand the data structure and relationships.

For more detailed information about each model, please refer to the source code and inline documentation.
