import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/cms_models.dart';

/// Widget for displaying a list of CMS FAQs
class CMSFAQList extends StatefulWidget {
  /// FAQs to display
  final List<CMSFAQ> faqs;
  
  /// FAQ categories
  final List<String> categories;
  
  /// Callback when a category is selected
  final Function(String? category)? onCategorySelected;
  
  /// Create a new CMS FAQ list
  const CMSFAQList({
    Key? key,
    required this.faqs,
    required this.categories,
    this.onCategorySelected,
  }) : super(key: key);
  
  @override
  State<CMSFAQList> createState() => _CMSFAQListState();
}

class _CMSFAQListState extends State<CMSFAQList> {
  String? _selectedCategory;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.categories.isNotEmpty)
          _buildCategoryFilter(),
        Expanded(
          child: _buildFAQList(),
        ),
      ],
    );
  }
  
  /// Build the category filter
  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildCategoryChip(null, 'All'),
          ...widget.categories.map((category) => _buildCategoryChip(category, category)),
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
          
          if (widget.onCategorySelected != null) {
            widget.onCategorySelected!(selected ? category : null);
          }
        },
        backgroundColor: Theme.of(context).chipTheme.backgroundColor,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }
  
  /// Build the FAQ list
  Widget _buildFAQList() {
    // Filter FAQs by category
    final filteredFAQs = _selectedCategory != null
        ? widget.faqs.where((faq) => faq.category == _selectedCategory).toList()
        : widget.faqs;
    
    if (filteredFAQs.isEmpty) {
      return const Center(
        child: Text('No FAQs found'),
      );
    }
    
    return ListView.builder(
      itemCount: filteredFAQs.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        final faq = filteredFAQs[index];
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
            child: Html(
              data: faq.answer,
              style: {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(16),
                  lineHeight: LineHeight.normal,
                ),
                'p': Style(
                  margin: Margins.only(bottom: 16),
                ),
                'ul': Style(
                  margin: Margins.only(bottom: 16, left: 20),
                ),
                'ol': Style(
                  margin: Margins.only(bottom: 16, left: 20),
                ),
                'li': Style(
                  margin: Margins.only(bottom: 8),
                ),
                'a': Style(
                  color: Theme.of(context).primaryColor,
                  textDecoration: TextDecoration.underline,
                ),
              },
              onLinkTap: (url, _, __) {
                if (url != null) {
                  // Handle link tap
                  print('Link tapped: $url');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
