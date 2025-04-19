import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cms_models.dart';
import '../providers/cms_provider.dart';
import '../widgets/cms_widgets.dart';

/// Screen for displaying a CMS page
class CMSPageScreen extends StatefulWidget {
  /// Page slug
  final String slug;
  
  /// Create a new CMS page screen
  const CMSPageScreen({
    Key? key,
    required this.slug,
  }) : super(key: key);
  
  @override
  State<CMSPageScreen> createState() => _CMSPageScreenState();
}

class _CMSPageScreenState extends State<CMSPageScreen> {
  CMSPage? _page;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadPage();
  }
  
  /// Load the page
  Future<void> _loadPage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final cmsProvider = Provider.of<CMSProvider>(context, listen: false);
      final page = await cmsProvider.loadPageBySlug(widget.slug);
      
      setState(() {
        _page = page;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load page: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_page?.title ?? 'Loading...'),
      ),
      body: _buildBody(),
    );
  }
  
  /// Build the body
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage != null) {
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
              _errorMessage!,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPage,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_page == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }
    
    return CMSPageContent(page: _page!);
  }
}
