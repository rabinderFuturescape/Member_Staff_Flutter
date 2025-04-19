/// Model for a CMS notification
class CMSNotification {
  /// Notification ID
  final int id;
  
  /// Notification title
  final String title;
  
  /// Notification message
  final String message;
  
  /// Notification type
  final String type;
  
  /// Notification icon
  final String? icon;
  
  /// Notification action
  final String? action;
  
  /// Notification action data
  final Map<String, dynamic>? actionData;
  
  /// Notification is read
  final bool isRead;
  
  /// Notification target user IDs
  final List<String> targetUserIds;
  
  /// Notification target roles
  final List<String> targetRoles;
  
  /// Notification created at
  final DateTime createdAt;
  
  /// Notification updated at
  final DateTime updatedAt;
  
  /// Create a new CMS notification
  CMSNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.icon,
    this.action,
    this.actionData,
    required this.isRead,
    required this.targetUserIds,
    required this.targetRoles,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Create a CMS notification from JSON
  factory CMSNotification.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};
    
    // Parse action data
    final actionDataJson = attributes['actionData'];
    Map<String, dynamic>? actionData;
    
    if (actionDataJson is Map) {
      actionData = Map<String, dynamic>.from(actionDataJson);
    }
    
    return CMSNotification(
      id: json['id'] ?? 0,
      title: attributes['title'] ?? '',
      message: attributes['message'] ?? '',
      type: attributes['type'] ?? 'info',
      icon: attributes['icon'],
      action: attributes['action'],
      actionData: actionData,
      isRead: attributes['isRead'] ?? false,
      targetUserIds: List<String>.from(attributes['targetUserIds'] ?? []),
      targetRoles: List<String>.from(attributes['targetRoles'] ?? []),
      createdAt: DateTime.parse(attributes['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(attributes['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  /// Convert CMS notification to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attributes': {
        'title': title,
        'message': message,
        'type': type,
        'icon': icon,
        'action': action,
        'actionData': actionData,
        'isRead': isRead,
        'targetUserIds': targetUserIds,
        'targetRoles': targetRoles,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      },
    };
  }
}
