import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:html_unescape/html_unescape.dart';
import '../config/cms_config.dart';
import '../models/cms_models.dart';

/// Widget for displaying CMS page content
class CMSPageContent extends StatelessWidget {
  /// Page to display
  final CMSPage page;
  
  /// Create a new CMS page content widget
  const CMSPageContent({
    Key? key,
    required this.page,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (page.featuredImage != null && page.featuredImage!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: CMSConfig.getImageUrl(page.featuredImage),
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HtmlUnescape().convert(page.title),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Html(
                  data: page.content,
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(16),
                      lineHeight: LineHeight.normal,
                    ),
                    'h1': Style(
                      fontSize: FontSize(24),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 16),
                    ),
                    'h2': Style(
                      fontSize: FontSize(22),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 14),
                    ),
                    'h3': Style(
                      fontSize: FontSize(20),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(bottom: 12),
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
                    'img': Style(
                      margin: Margins.only(bottom: 16),
                    ),
                    'a': Style(
                      color: Theme.of(context).primaryColor,
                      textDecoration: TextDecoration.underline,
                    ),
                    'blockquote': Style(
                      margin: Margins.only(bottom: 16, left: 16),
                      padding: HtmlPaddings.only(left: 16),
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 4,
                        ),
                      ),
                      fontStyle: FontStyle.italic,
                    ),
                    'table': Style(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      margin: Margins.only(bottom: 16),
                    ),
                    'th': Style(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      padding: HtmlPaddings.all(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                      fontWeight: FontWeight.bold,
                    ),
                    'td': Style(
                      padding: HtmlPaddings.all(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                  },
                  onLinkTap: (url, _, __) {
                    if (url != null) {
                      // Handle link tap
                      print('Link tapped: $url');
                    }
                  },
                  onImageTap: (url, _, __, ___) {
                    if (url != null) {
                      // Handle image tap
                      print('Image tapped: $url');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
