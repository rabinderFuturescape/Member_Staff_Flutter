import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cms_models.dart';

/// Widget for displaying a list of CMS notifications
class CMSNotificationList extends StatelessWidget {
  /// Notifications to display
  final List<CMSNotification> notifications;
  
  /// Callback when a notification is tapped
  final Function(CMSNotification notification)? onNotificationTap;
  
  /// Callback when a notification is marked as read
  final Function(CMSNotification notification)? onMarkAsRead;
  
  /// Create a new CMS notification list
  const CMSNotificationList({
    Key? key,
    required this.notifications,
    this.onNotificationTap,
    this.onMarkAsRead,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(
        child: Text('No notifications'),
      );
    }
    
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(context, notification);
      },
    );
  }
  
  /// Build a notification item
  Widget _buildNotificationItem(BuildContext context, CMSNotification notification) {
    // Get the icon based on the notification type
    IconData icon;
    Color iconColor;
    
    switch (notification.type) {
      case 'info':
        icon = Icons.info;
        iconColor = Colors.blue;
        break;
      case 'success':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'warning':
        icon = Icons.warning;
        iconColor = Colors.orange;
        break;
      case 'error':
        icon = Icons.error;
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Theme.of(context).primaryColor;
    }
    
    // Format the date
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final formattedDate = dateFormat.format(notification.createdAt.toLocal());
    
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        if (onMarkAsRead != null && !notification.isRead) {
          onMarkAsRead!(notification);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: notification.isRead
            ? null
            : Theme.of(context).primaryColor.withOpacity(0.1),
        child: InkWell(
          onTap: () {
            if (onNotificationTap != null) {
              onNotificationTap!(notification);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(
                    notification.icon != null
                        ? IconData(
                            int.tryParse(notification.icon!) ?? 0,
                            fontFamily: 'MaterialIcons',
                          )
                        : icon,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: notification.isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
