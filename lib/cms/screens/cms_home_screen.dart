import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cms_provider.dart';
import '../widgets/cms_widgets.dart';
import 'cms_page_screen.dart';
import 'cms_notification_screen.dart';
import 'cms_faq_screen.dart';

/// Screen for displaying the CMS home screen
class CMSHomeScreen extends StatefulWidget {
  /// Create a new CMS home screen
  const CMSHomeScreen({Key? key}) : super(key: key);
  
  @override
  State<CMSHomeScreen> createState() => _CMSHomeScreenState();
}

class _CMSHomeScreenState extends State<CMSHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  /// Load data
  Future<void> _loadData() async {
    final cmsProvider = Provider.of<CMSProvider>(context, listen: false);
    await cmsProvider.initialize();
    
    // Load notifications for the current user
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
        title: Consumer<CMSProvider>(
          builder: (context, cmsProvider, child) {
            return Text(cmsProvider.settings?.appName ?? 'Member Staff App');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'FAQs',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CMSFAQScreen(),
                ),
              );
            },
          ),
          Consumer<CMSProvider>(
            builder: (context, cmsProvider, child) {
              final unreadCount = cmsProvider.unreadNotifications.length;
              
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    tooltip: 'Notifications',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CMSNotificationScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildFeaturesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build the welcome section
  Widget _buildWelcomeSection() {
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
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to ${cmsProvider.settings?.appName ?? 'Member Staff App'}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your society staff and member staff with ease.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CMSPageScreen(
                          slug: 'about',
                        ),
                      ),
                    );
                  },
                  child: const Text('Learn More'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Build the features section
  Widget _buildFeaturesSection() {
    return Consumer<CMSProvider>(
      builder: (context, cmsProvider, child) {
        if (cmsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (cmsProvider.features.isEmpty) {
          return const Center(
            child: Text('No features available'),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Features',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            CMSFeatureGrid(
              features: cmsProvider.features,
              onFeatureTap: (feature) {
                // Navigate to the feature route
                print('Navigate to: ${feature.route}');
                
                // For demonstration purposes, navigate to a CMS page
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CMSPageScreen(
                      slug: feature.route,
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
