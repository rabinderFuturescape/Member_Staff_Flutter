import 'staff.dart';
import 'staff_scope.dart';
import 'schedule.dart';

/// Model class representing a member staff (staff assigned to members).
class MemberStaff extends Staff {
  MemberStaff({
    required String id,
    required String name,
    required String email,
    required String phone,
    String? position,
    required DateTime hireDate,
    double? salary,
    required bool isActive,
    String? designation,
    Schedule? schedule,
  }) : super(
          id: id,
          name: name,
          email: email,
          phone: phone,
          position: position,
          hireDate: hireDate,
          salary: salary,
          isActive: isActive,
          staffScope: StaffScope.member,
          designation: designation,
          schedule: schedule,
        );

  factory MemberStaff.fromJson(Map<String, dynamic> json) {
    return MemberStaff(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      position: json['position'],
      hireDate: DateTime.parse(json['hireDate']),
      salary: json['salary'] != null ? json['salary'].toDouble() : null,
      isActive: json['isActive'],
      designation: json['designation'],
      schedule: json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }
}
