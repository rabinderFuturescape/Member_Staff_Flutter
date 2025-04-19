import 'package:flutter/material.dart';
import '../config/cms_config.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen for the CMS console
class CMSConsoleScreen extends StatelessWidget {
  /// Create a new CMS console screen
  const CMSConsoleScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CMS Console'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Strapi CMS Console',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Manage your content using the Strapi CMS admin panel.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildConsoleCard(
              context,
              title: 'Strapi Admin Panel',
              description: 'Manage all your content types, users, and settings.',
              icon: Icons.admin_panel_settings,
              onTap: () => _launchURL('${CMSConfig.baseUrl}/admin'),
            ),
            const SizedBox(height: 16),
            _buildConsoleCard(
              context,
              title: 'API Documentation',
              description: 'View the API documentation for your content types.',
              icon: Icons.api,
              onTap: () => _launchURL('${CMSConfig.baseUrl}/documentation'),
            ),
            const SizedBox(height: 16),
            _buildConsoleCard(
              context,
              title: 'Content Types',
              description: 'View and manage your content types.',
              icon: Icons.category,
              onTap: () => _showContentTypesDialog(context),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Configuration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildConfigItem(
              context,
              title: 'Base URL',
              value: CMSConfig.baseUrl,
            ),
            _buildConfigItem(
              context,
              title: 'API Version',
              value: CMSConfig.apiVersion,
            ),
            _buildConfigItem(
              context,
              title: 'API Token',
              value: '${CMSConfig.apiToken.substring(0, 4)}...',
              isSecret: true,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build a console card
  Widget _buildConsoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build a config item
  Widget _buildConfigItem(
    BuildContext context, {
    required String title,
    required String value,
    bool isSecret = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            '$title:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (isSecret)
            IconButton(
              icon: const Icon(Icons.visibility_off, size: 16),
              onPressed: () {},
              tooltip: 'Hidden for security',
            ),
        ],
      ),
    );
  }
  
  /// Show content types dialog
  void _showContentTypesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Content Types'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContentTypeItem(
                  context,
                  title: 'Pages',
                  description: 'Manage pages content',
                  contentType: CMSConfig.contentTypePages,
                ),
                _buildContentTypeItem(
                  context,
                  title: 'Features',
                  description: 'Manage features content',
                  contentType: CMSConfig.contentTypeFeatures,
                ),
                _buildContentTypeItem(
                  context,
                  title: 'Settings',
                  description: 'Manage application settings',
                  contentType: CMSConfig.contentTypeSettings,
                ),
                _buildContentTypeItem(
                  context,
                  title: 'Staff Members',
                  description: 'Manage staff members',
                  contentType: CMSConfig.contentTypeStaff,
                ),
                _buildContentTypeItem(
                  context,
                  title: 'Members',
                  description: 'Manage members',
                  contentType: CMSConfig.contentTypeMembers,
                ),
                _buildContentTypeItem(
                  context,
                  title: 'Notifications',
                  description: 'Manage notifications',
                  contentType: CMSConfig.contentTypeNotifications,
                ),
                _buildContentTypeItem(
                  context,
                  title: 'FAQs',
                  description: 'Manage frequently asked questions',
                  contentType: CMSConfig.contentTypeFAQs,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  
  /// Build a content type item
  Widget _buildContentTypeItem(
    BuildContext context, {
    required String title,
    required String description,
    required String contentType,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(description),
      onTap: () {
        Navigator.of(context).pop();
        _launchURL('${CMSConfig.baseUrl}/admin/content-manager/collectionType/api::$contentType.$contentType');
      },
    );
  }
  
  /// Launch a URL
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $url');
    }
  }
}
