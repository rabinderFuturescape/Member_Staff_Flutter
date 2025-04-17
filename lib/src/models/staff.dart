/// Model class representing a staff member.
class Staff {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String position;
  final DateTime hireDate;
  final double salary;
  final bool isActive;

  Staff({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.hireDate,
    required this.salary,
    required this.isActive,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      position: json['position'],
      hireDate: DateTime.parse(json['hireDate']),
      salary: json['salary'].toDouble(),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'position': position,
      'hireDate': hireDate.toIso8601String(),
      'salary': salary,
      'isActive': isActive,
    };
  }
}
