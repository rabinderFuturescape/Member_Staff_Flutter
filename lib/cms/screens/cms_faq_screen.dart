import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cms_provider.dart';
import '../widgets/cms_widgets.dart';

/// Screen for displaying CMS FAQs
class CMSFAQScreen extends StatefulWidget {
  /// Create a new CMS FAQ screen
  const CMSFAQScreen({Key? key}) : super(key: key);
  
  @override
  State<CMSFAQScreen> createState() => _CMSFAQScreenState();
}

class _CMSFAQScreenState extends State<CMSFAQScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  /// Load data
  Future<void> _loadData() async {
    final cmsProvider = Provider.of<CMSProvider>(context, listen: false);
    await cmsProvider.loadFAQCategories();
    await cmsProvider.loadFAQs();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadData,
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
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (cmsProvider.faqs.isEmpty) {
          return const Center(
            child: Text('No FAQs available'),
          );
        }
        
        return CMSFAQList(
          faqs: cmsProvider.faqs,
          categories: cmsProvider.faqCategories,
          onCategorySelected: (category) {
            cmsProvider.loadFAQs(category: category);
          },
        );
      },
    );
  }
}
