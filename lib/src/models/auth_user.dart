/// Model class representing an authenticated user.
class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String token;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
    };
  }

  /// Creates a copy of this AuthUser with the given fields replaced with the new values.
  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? token,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
