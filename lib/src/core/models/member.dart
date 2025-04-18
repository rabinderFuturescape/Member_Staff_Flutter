/// Model representing a member
class Member {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String unitId;
  final String companyId;
  final String unitNumber;
  final bool isActive;
  
  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.unitId,
    required this.companyId,
    required this.unitNumber,
    required this.isActive,
  });
  
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      email: json['email'] ?? '',
      mobile: json['mobile'],
      unitId: json['unit_id'],
      companyId: json['company_id'],
      unitNumber: json['unit_number'],
      isActive: json['is_active'] ?? true,
    );
  }
  
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
    };
  }
}
