/// Model class representing a member.
class Member {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime joinDate;
  final String membershipType;
  final bool isActive;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.joinDate,
    required this.membershipType,
    required this.isActive,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      joinDate: DateTime.parse(json['joinDate']),
      membershipType: json['membershipType'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'joinDate': joinDate.toIso8601String(),
      'membershipType': membershipType,
      'isActive': isActive,
    };
  }
}
