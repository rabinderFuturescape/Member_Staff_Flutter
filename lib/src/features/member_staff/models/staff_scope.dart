/// Enum representing the scope of a staff member.
enum StaffScope {
  society,
  member,
}

/// Extension methods for the StaffScope enum.
extension StaffScopeExtension on StaffScope {
  String get name {
    switch (this) {
      case StaffScope.society:
        return 'society';
      case StaffScope.member:
        return 'member';
    }
  }
  
  static StaffScope fromString(String value) {
    switch (value.toLowerCase()) {
      case 'society':
        return StaffScope.society;
      case 'member':
      default:
        return StaffScope.member;
    }
  }
}
