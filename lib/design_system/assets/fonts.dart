/// Font assets
///
/// This class provides access to font assets.
class DSFonts {
  // Private constructor to prevent instantiation
  DSFonts._();
  
  /// Primary font family
  static const String primary = 'Roboto';
  
  /// Secondary font family
  static const String secondary = 'Roboto';
  
  /// Font assets map
  static const Map<String, List<String>> fontAssets = {
    primary: [
      'assets/fonts/Roboto-Regular.ttf',
      'assets/fonts/Roboto-Medium.ttf',
      'assets/fonts/Roboto-Bold.ttf',
      'assets/fonts/Roboto-Light.ttf',
      'assets/fonts/Roboto-Thin.ttf',
      'assets/fonts/Roboto-Italic.ttf',
      'assets/fonts/Roboto-MediumItalic.ttf',
      'assets/fonts/Roboto-BoldItalic.ttf',
      'assets/fonts/Roboto-LightItalic.ttf',
      'assets/fonts/Roboto-ThinItalic.ttf',
    ],
  };
  
  /// Get the font asset path
  static String getFontAssetPath(String fontFamily, String fontWeight, String fontStyle) {
    final String basePath = 'assets/fonts/';
    final String fileName = '$fontFamily-$fontWeight$fontStyle.ttf';
    
    return '$basePath$fileName';
  }
}
