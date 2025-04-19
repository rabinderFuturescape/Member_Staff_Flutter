import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cms/cms.dart';

/// FAQ screen that uses content from the CMS
class CMSFAQScreen extends StatefulWidget {
  /// Create a new CMS FAQ screen
  const CMSFAQScreen({Key? key}) : super(key: key);
  
  @override
  State<CMSFAQScreen> createState() => _CMSFAQScreenState();
}

class _CMSFAQScreenState extends State<CMSFAQScreen> {
  String? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  /// Load data from the CMS
  Future<void> _loadData() async {
    final cmsProvider = Provider.of<CMSProvider>(context, listen: false);
    await cmsProvider.loadFAQCategories();
    await cmsProvider.loadFAQs(category: _selectedCategory);
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
        
        return Column(
          children: [
            if (cmsProvider.faqCategories.isNotEmpty)
              _buildCategoryFilter(cmsProvider),
            Expanded(
              child: _buildFAQList(cmsProvider),
            ),
          ],
        );
      },
    );
  }
  
  /// Build the category filter
  Widget _buildCategoryFilter(CMSProvider cmsProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildCategoryChip(null, 'All'),
          ...cmsProvider.faqCategories.map((category) => _buildCategoryChip(category, category)),
        ],
      ),
    );
  }
  
  /// Build a category chip
  Widget _buildCategoryChip(String? category, String label) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
          
          final cmsProvider = Provider.of<CMSProvider>(context, listen: false);
          cmsProvider.loadFAQs(category: selected ? category : null);
        },
        backgroundColor: Theme.of(context).chipTheme.backgroundColor,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }
  
  /// Build the FAQ list
  Widget _buildFAQList(CMSProvider cmsProvider) {
    return ListView.builder(
      itemCount: cmsProvider.faqs.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        final faq = cmsProvider.faqs[index];
        return _buildFAQItem(faq);
      },
    );
  }
  
  /// Build an FAQ item
  Widget _buildFAQItem(CMSFAQ faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              faq.answer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
