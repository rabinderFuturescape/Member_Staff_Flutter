import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cms/cms.dart';
import '../src/providers/auth_provider.dart';

/// Home screen that uses content from the CMS
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
  
  /// Load data from the CMS
  Future<void> _loadData() async {
    final cmsProvider = Provider.of<CMSProvider>(context, listen: false);
    
    // Load features and settings
    await Future.wait([
      cmsProvider.loadFeatures(),
      cmsProvider.loadSettings(),
    ]);
    
    // Load notifications if user is authenticated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      await cmsProvider.loadNotifications(
        userId: authProvider.currentUser?.id ?? '',
        roles: authProvider.currentUser?.roles ?? [],
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(),
      ),
    );
  }
  
  /// Build the app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
    );
  }
  
  /// Build the drawer
  Widget _buildDrawer() {
    return Drawer(
      child: Consumer<CMSProvider>(
        builder: (context, cmsProvider, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cmsProvider.settings?.appName ?? 'Member Staff App',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.isAuthenticated) {
                          return Text(
                            'Welcome, ${authProvider.currentUser?.name ?? 'User'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          );
                        } else {
                          return const Text(
                            'Welcome, Guest',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              // Dynamic menu items from CMS features
              ...cmsProvider.features.map((feature) {
                // Parse the icon
                IconData icon;
                try {
                  icon = IconData(
                    int.parse(feature.icon, radix: 16),
                    fontFamily: 'MaterialIcons',
                  );
                } catch (e) {
                  icon = Icons.settings;
                }
                
                return ListTile(
                  leading: Icon(icon),
                  title: Text(feature.title),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the drawer
                    
                    // Navigate to the feature route
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CMSPageScreen(
                          slug: feature.route,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CMSPageScreen(
                        slug: 'about',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('FAQs'),
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CMSFAQScreen(),
                    ),
                  );
                },
              ),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.isAuthenticated) {
                    return ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () {
                        Navigator.of(context).pop(); // Close the drawer
                        authProvider.logout();
                      },
                    );
                  } else {
                    return ListTile(
                      leading: const Icon(Icons.login),
                      title: const Text('Login'),
                      onTap: () {
                        Navigator.of(context).pop(); // Close the drawer
                        // Navigate to login screen
                      },
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// Build the body
  Widget _buildBody() {
    return SingleChildScrollView(
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
