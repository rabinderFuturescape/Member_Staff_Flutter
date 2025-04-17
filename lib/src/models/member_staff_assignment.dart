/// Model class representing an assignment of a staff to a member.
class MemberStaffAssignment {
  final String id;
  final String memberId;
  final String staffId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MemberStaffAssignment({
    required this.id,
    required this.memberId,
    required this.staffId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MemberStaffAssignment.fromJson(Map<String, dynamic> json) {
    return MemberStaffAssignment(
      id: json['id'],
      memberId: json['member_id'],
      staffId: json['staff_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'staff_id': staffId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
