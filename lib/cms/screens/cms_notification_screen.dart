import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cms_models.dart';
import '../providers/cms_provider.dart';
import '../widgets/cms_widgets.dart';

/// Screen for displaying CMS notifications
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
  
  /// Load notifications
  Future<void> _loadNotifications() async {
    final cmsProvider = Provider.of<CMSProvider>(context, listen: false);
    
    // In a real app, you would get the user ID and roles from the auth provider
    await cmsProvider.loadNotifications(
      userId: 'current_user_id',
      roles: ['member'],
    );
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
        
        return CMSNotificationList(
          notifications: cmsProvider.notifications,
          onNotificationTap: _handleNotificationTap,
          onMarkAsRead: _handleMarkAsRead,
        );
      },
    );
  }
  
  /// Handle notification tap
  void _handleNotificationTap(CMSNotification notification) {
    // Mark the notification as read
    if (!notification.isRead) {
      _handleMarkAsRead(notification);
    }
    
    // Handle notification action
    if (notification.action != null) {
      print('Handle action: ${notification.action}');
      print('Action data: ${notification.actionData}');
      
      // In a real app, you would handle the action based on the action type
      // For example, navigate to a specific screen
    }
  }
  
  /// Handle mark as read
  Future<void> _handleMarkAsRead(CMSNotification notification) async {
    final cmsProvider = Provider.of<CMSProvider>(context, listen: false);
    await cmsProvider.markNotificationAsRead(notification.id);
  }
}
