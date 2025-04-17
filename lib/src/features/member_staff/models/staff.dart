import 'staff_scope.dart';

/// Model representing a staff member.
class Staff {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final StaffScope staffScope;
  final String? department;
  final String? designation;
  final String? societyId;
  final String? unitId;
  final String? companyId;
  final String? aadhaarNumber;
  final String? residentialAddress;
  final String? nextOfKinName;
  final String? nextOfKinMobile;
  final String? photoUrl;
  final bool isVerified;
  final DateTime? verifiedAt;
  final String? verifiedByMemberId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Staff({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.staffScope,
    this.department,
    this.designation,
    this.societyId,
    this.unitId,
    this.companyId,
    this.aadhaarNumber,
    this.residentialAddress,
    this.nextOfKinName,
    this.nextOfKinMobile,
    this.photoUrl,
    required this.isVerified,
    this.verifiedAt,
    this.verifiedByMemberId,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      email: json['email'],
      staffScope: StaffScopeExtension.fromString(json['staff_scope']),
      department: json['department'],
      designation: json['designation'],
      societyId: json['society_id'],
      unitId: json['unit_id'],
      companyId: json['company_id'],
      aadhaarNumber: json['aadhaar_number'],
      residentialAddress: json['residential_address'],
      nextOfKinName: json['next_of_kin_name'],
      nextOfKinMobile: json['next_of_kin_mobile'],
      photoUrl: json['photo_url'],
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'] != null 
          ? DateTime.parse(json['verified_at']) 
          : null,
      verifiedByMemberId: json['verified_by_member_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'staff_scope': staffScope.name,
      'department': department,
      'designation': designation,
      'society_id': societyId,
      'unit_id': unitId,
      'company_id': companyId,
      'aadhaar_number': aadhaarNumber,
      'residential_address': residentialAddress,
      'next_of_kin_name': nextOfKinName,
      'next_of_kin_mobile': nextOfKinMobile,
      'photo_url': photoUrl,
      'is_verified': isVerified,
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by_member_id': verifiedByMemberId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  Staff copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    StaffScope? staffScope,
    String? department,
    String? designation,
    String? societyId,
    String? unitId,
    String? companyId,
    String? aadhaarNumber,
    String? residentialAddress,
    String? nextOfKinName,
    String? nextOfKinMobile,
    String? photoUrl,
    bool? isVerified,
    DateTime? verifiedAt,
    String? verifiedByMemberId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      staffScope: staffScope ?? this.staffScope,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      societyId: societyId ?? this.societyId,
      unitId: unitId ?? this.unitId,
      companyId: companyId ?? this.companyId,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      nextOfKinName: nextOfKinName ?? this.nextOfKinName,
      nextOfKinMobile: nextOfKinMobile ?? this.nextOfKinMobile,
      photoUrl: photoUrl ?? this.photoUrl,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedByMemberId: verifiedByMemberId ?? this.verifiedByMemberId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
