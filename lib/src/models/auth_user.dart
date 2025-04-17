/// Model class representing an authenticated user.
class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;
  final String? memberId;
  final String? unitId;
  final String? companyId;
  final String? unitNumber;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    this.memberId,
    this.unitId,
    this.companyId,
    this.unitNumber,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      token: json['token'],
      memberId: json['member_id'],
      unitId: json['unit_id'],
      companyId: json['company_id'],
      unitNumber: json['unit_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
      'member_id': memberId,
      'unit_id': unitId,
      'company_id': companyId,
      'unit_number': unitNumber,
    };
  }

  /// Creates a copy of this AuthUser with the given fields replaced with the new values.
  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? token,
    String? memberId,
    String? unitId,
    String? companyId,
    String? unitNumber,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      memberId: memberId ?? this.memberId,
      unitId: unitId ?? this.unitId,
      companyId: companyId ?? this.companyId,
      unitNumber: unitNumber ?? this.unitNumber,
    );
  }
}
