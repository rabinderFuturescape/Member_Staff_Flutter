/// Enum representing the scope of a staff member.
enum StaffScope {
  /// Staff working for the society (e.g., Office Staff, House Keeping, Security, etc.)
  society,
  
  /// Staff working for individual members (e.g., Domestic Help, Driver, etc.)
  member
}

/// Extension methods for StaffScope enum
extension StaffScopeExtension on StaffScope {
  /// Returns the string representation of the staff scope
  String get name {
    switch (this) {
      case StaffScope.society:
        return 'society';
      case StaffScope.member:
        return 'member';
    }
  }

  /// Returns the display name of the staff scope
  String get displayName {
    switch (this) {
      case StaffScope.society:
        return 'Society Staff';
      case StaffScope.member:
        return 'Member Staff';
    }
  }

  /// Creates a StaffScope from a string
  static StaffScope fromString(String value) {
    switch (value.toLowerCase()) {
      case 'society':
        return StaffScope.society;
      case 'member':
        return StaffScope.member;
      default:
        throw ArgumentError('Invalid staff scope: $value');
    }
  }
}
