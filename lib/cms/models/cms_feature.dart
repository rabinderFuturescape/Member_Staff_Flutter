/// Model for a CMS feature
class CMSFeature {
  /// Feature ID
  final int id;
  
  /// Feature title
  final String title;
  
  /// Feature description
  final String description;
  
  /// Feature icon
  final String icon;
  
  /// Feature color
  final String color;
  
  /// Feature route
  final String route;
  
  /// Feature order
  final int order;
  
  /// Feature is enabled
  final bool isEnabled;
  
  /// Feature requires authentication
  final bool requiresAuth;
  
  /// Feature required roles
  final List<String> requiredRoles;
  
  /// Feature created at
  final DateTime createdAt;
  
  /// Feature updated at
  final DateTime updatedAt;
  
  /// Create a new CMS feature
  CMSFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    required this.order,
    required this.isEnabled,
    required this.requiresAuth,
    required this.requiredRoles,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Create a CMS feature from JSON
  factory CMSFeature.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};
    
    return CMSFeature(
      id: json['id'] ?? 0,
      title: attributes['title'] ?? '',
      description: attributes['description'] ?? '',
      icon: attributes['icon'] ?? 'settings',
      color: attributes['color'] ?? '#000000',
      route: attributes['route'] ?? '',
      order: attributes['order'] ?? 0,
      isEnabled: attributes['isEnabled'] ?? false,
      requiresAuth: attributes['requiresAuth'] ?? true,
      requiredRoles: List<String>.from(attributes['requiredRoles'] ?? []),
      createdAt: DateTime.parse(attributes['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(attributes['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  /// Convert CMS feature to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attributes': {
        'title': title,
        'description': description,
        'icon': icon,
        'color': color,
        'route': route,
        'order': order,
        'isEnabled': isEnabled,
        'requiresAuth': requiresAuth,
        'requiredRoles': requiredRoles,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      },
    };
  }
}
