/// Model for CMS settings
class CMSSettings {
  /// Settings ID
  final int id;
  
  /// App name
  final String appName;
  
  /// App logo
  final String? appLogo;
  
  /// App theme color
  final String themeColor;
  
  /// App primary color
  final String primaryColor;
  
  /// App secondary color
  final String secondaryColor;
  
  /// App accent color
  final String accentColor;
  
  /// App background color
  final String backgroundColor;
  
  /// App text color
  final String textColor;
  
  /// App font family
  final String fontFamily;
  
  /// App contact email
  final String contactEmail;
  
  /// App contact phone
  final String contactPhone;
  
  /// App social media links
  final Map<String, String> socialLinks;
  
  /// App terms and conditions URL
  final String termsUrl;
  
  /// App privacy policy URL
  final String privacyUrl;
  
  /// App created at
  final DateTime createdAt;
  
  /// App updated at
  final DateTime updatedAt;
  
  /// Create a new CMS settings
  CMSSettings({
    required this.id,
    required this.appName,
    this.appLogo,
    required this.themeColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.textColor,
    required this.fontFamily,
    required this.contactEmail,
    required this.contactPhone,
    required this.socialLinks,
    required this.termsUrl,
    required this.privacyUrl,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Create CMS settings from JSON
  factory CMSSettings.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};
    
    // Parse social links
    final socialLinksJson = attributes['socialLinks'] ?? {};
    final Map<String, String> socialLinks = {};
    
    if (socialLinksJson is Map) {
      socialLinksJson.forEach((key, value) {
        if (value is String) {
          socialLinks[key] = value;
        }
      });
    }
    
    return CMSSettings(
      id: json['id'] ?? 0,
      appName: attributes['appName'] ?? 'Member Staff App',
      appLogo: attributes['appLogo']?['data']?['attributes']?['url'],
      themeColor: attributes['themeColor'] ?? '#2196F3',
      primaryColor: attributes['primaryColor'] ?? '#2196F3',
      secondaryColor: attributes['secondaryColor'] ?? '#4CAF50',
      accentColor: attributes['accentColor'] ?? '#FFC107',
      backgroundColor: attributes['backgroundColor'] ?? '#FFFFFF',
      textColor: attributes['textColor'] ?? '#212121',
      fontFamily: attributes['fontFamily'] ?? 'Roboto',
      contactEmail: attributes['contactEmail'] ?? '',
      contactPhone: attributes['contactPhone'] ?? '',
      socialLinks: socialLinks,
      termsUrl: attributes['termsUrl'] ?? '',
      privacyUrl: attributes['privacyUrl'] ?? '',
      createdAt: DateTime.parse(attributes['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(attributes['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  /// Convert CMS settings to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attributes': {
        'appName': appName,
        'appLogo': appLogo != null ? {
          'data': {
            'attributes': {
              'url': appLogo,
            },
          },
        } : null,
        'themeColor': themeColor,
        'primaryColor': primaryColor,
        'secondaryColor': secondaryColor,
        'accentColor': accentColor,
        'backgroundColor': backgroundColor,
        'textColor': textColor,
        'fontFamily': fontFamily,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'socialLinks': socialLinks,
        'termsUrl': termsUrl,
        'privacyUrl': privacyUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      },
    };
  }
}
