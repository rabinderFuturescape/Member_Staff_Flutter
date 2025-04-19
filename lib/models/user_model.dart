class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final int? memberId;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.memberId,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      memberId: json['member_id'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'member_id': memberId,
      'photo_url': photoUrl,
    };
  }

  bool get isCommitteeMember => role == 'committee';
  bool get isAdmin => role == 'admin';
}
