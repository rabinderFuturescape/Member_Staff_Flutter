import 'staff_scope.dart';
import 'schedule.dart';

/// Base model class representing a staff member.
class Staff {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? position;
  final DateTime hireDate;
  final double? salary;
  final bool isActive;
  final StaffScope staffScope;
  final String? designation;
  final Schedule? schedule;

  Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.position,
    required this.hireDate,
    this.salary,
    required this.isActive,
    required this.staffScope,
    this.designation,
    this.schedule,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      position: json['position'],
      hireDate: DateTime.parse(json['hireDate']),
      salary: json['salary'] != null ? json['salary'].toDouble() : null,
      isActive: json['isActive'],
      staffScope: StaffScopeExtension.fromString(json['staff_scope'] ?? 'member'),
      designation: json['designation'],
      schedule: json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'hireDate': hireDate.toIso8601String(),
      'isActive': isActive,
      'staff_scope': staffScope.name,
    };

    if (position != null) data['position'] = position;
    if (salary != null) data['salary'] = salary;
    if (designation != null) data['designation'] = designation;
    if (schedule != null) data['schedule'] = schedule!.toJson();

    return data;
  }
}
