import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cms/cms.dart';

/// About screen that uses content from the CMS
class CMSAboutScreen extends StatefulWidget {
  /// Create a new CMS about screen
  const CMSAboutScreen({Key? key}) : super(key: key);
  
  @override
  State<CMSAboutScreen> createState() => _CMSAboutScreenState();
}

class _CMSAboutScreenState extends State<CMSAboutScreen> {
  CMSPage? _aboutPage;
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadAboutPage();
  }
  
  /// Load the about page from the CMS
  Future<void> _loadAboutPage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final cmsProvider = Provider.of<CMSProvider>(context, listen: false);
      final page = await cmsProvider.loadPageBySlug('about');
      
      setState(() {
        _aboutPage = page;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load about page: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
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
              onPressed: _loadAboutPage,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_aboutPage == null) {
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
              'About page not found',
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
    
    return CMSPageContent(page: _aboutPage!);
  }
}
