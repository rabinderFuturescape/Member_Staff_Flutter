import 'staff.dart';
import 'staff_scope.dart';
import 'schedule.dart';

/// Model class representing a society staff member.
class SocietyStaff extends Staff {
  final String societyCategory;
  final String workTimings;

  SocietyStaff({
    required String id,
    required String name,
    required String email,
    required String phone,
    String? position,
    required DateTime hireDate,
    double? salary,
    required bool isActive,
    required String designation,
    required this.societyCategory,
    required this.workTimings,
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
          staffScope: StaffScope.society,
          designation: designation,
          schedule: schedule,
        );

  factory SocietyStaff.fromJson(Map<String, dynamic> json) {
    return SocietyStaff(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      position: json['position'],
      hireDate: DateTime.parse(json['hireDate']),
      salary: json['salary'] != null ? json['salary'].toDouble() : null,
      isActive: json['isActive'],
      designation: json['designation'] ?? '',
      societyCategory: json['society_category'] ?? '',
      workTimings: json['work_timings'] ?? '',
      schedule: json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['society_category'] = societyCategory;
    data['work_timings'] = workTimings;
    return data;
  }
}
