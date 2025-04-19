/// Image assets
///
/// This class provides access to image assets.
class DSImages {
  // Private constructor to prevent instantiation
  DSImages._();
  
  /// Base path for images
  static const String _basePath = 'assets/images/';
  
  /// Logo image
  static const String logo = '${_basePath}logo.png';
  
  /// Placeholder image
  static const String placeholder = '${_basePath}placeholder.png';
  
  /// Error image
  static const String error = '${_basePath}error.png';
  
  /// Empty state image
  static const String empty = '${_basePath}empty.png';
  
  /// Success image
  static const String success = '${_basePath}success.png';
  
  /// Warning image
  static const String warning = '${_basePath}warning.png';
  
  /// Info image
  static const String info = '${_basePath}info.png';
  
  /// User avatar placeholder image
  static const String userAvatar = '${_basePath}user_avatar.png';
  
  /// Staff avatar placeholder image
  static const String staffAvatar = '${_basePath}staff_avatar.png';
  
  /// Member avatar placeholder image
  static const String memberAvatar = '${_basePath}member_avatar.png';
  
  /// Admin avatar placeholder image
  static const String adminAvatar = '${_basePath}admin_avatar.png';
  
  /// Committee avatar placeholder image
  static const String committeeAvatar = '${_basePath}committee_avatar.png';
  
  /// Get the image asset path
  static String getImageAssetPath(String imageName) {
    return '$_basePath$imageName';
  }
}
