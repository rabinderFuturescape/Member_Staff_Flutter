import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cms/cms.dart';
import '../src/providers/auth_provider.dart';

/// Notification screen that uses content from the CMS
class CMSNotificationScreen extends StatefulWidget {
  /// Create a new CMS notification screen
  const CMSNotificationScreen({Key? key}) : super(key: key);
  
  @override
  State<CMSNotificationScreen> createState() => _CMSNotificationScreenState();
}

class _CMSNotificationScreenState extends State<CMSNotificationScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  /// Load notifications from the CMS
  Future<void> _loadNotifications() async {
    final cmsProvider = Provider.of<CMSProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      await cmsProvider.loadNotifications(
        userId: authProvider.currentUser?.id ?? '',
        roles: authProvider.currentUser?.roles ?? [],
      );
    } else {
      // Load notifications for guest users
      await cmsProvider.loadNotifications(
        userId: 'guest',
        roles: ['guest'],
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
  
  /// Build the body
  Widget _buildBody() {
    return Consumer<CMSProvider>(
      builder: (context, cmsProvider, child) {
        if (cmsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (cmsProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  cmsProvider.errorMessage!,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadNotifications,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (cmsProvider.notifications.isEmpty) {
          return const Center(
            child: Text('No notifications'),
          );
        }
        
        return ListView.builder(
          itemCount: cmsProvider.notifications.length,
          itemBuilder: (context, index) {
            final notification = cmsProvider.notifications[index];
            return _buildNotificationItem(notification);
          },
        );
      },
    );
  }
  
  /// Build a notification item
  Widget _buildNotificationItem(CMSNotification notification) {
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
        if (!notification.isRead) {
          _markAsRead(notification);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: notification.isRead
            ? null
            : Theme.of(context).primaryColor.withOpacity(0.1),
        child: InkWell(
          onTap: () {
            _handleNotificationTap(notification);
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
  
  /// Handle notification tap
  void _handleNotificationTap(CMSNotification notification) {
    // Mark the notification as read
    if (!notification.isRead) {
      _markAsRead(notification);
    }
    
    // Handle notification action
    if (notification.action != null) {
      print('Handle action: ${notification.action}');
      print('Action data: ${notification.actionData}');
      
      // In a real app, you would handle the action based on the action type
      // For example, navigate to a specific screen
    }
  }
  
  /// Mark a notification as read
  Future<void> _markAsRead(CMSNotification notification) async {
    final cmsProvider = Provider.of<CMSProvider>(context, listen: false);
    await cmsProvider.markNotificationAsRead(notification.id);
  }
}
