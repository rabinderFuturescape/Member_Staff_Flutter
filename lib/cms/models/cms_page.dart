/// Model for a CMS page
class CMSPage {
  /// Page ID
  final int id;
  
  /// Page title
  final String title;
  
  /// Page slug
  final String slug;
  
  /// Page content
  final String content;
  
  /// Page meta title
  final String? metaTitle;
  
  /// Page meta description
  final String? metaDescription;
  
  /// Page featured image
  final String? featuredImage;
  
  /// Page published status
  final bool isPublished;
  
  /// Page created at
  final DateTime createdAt;
  
  /// Page updated at
  final DateTime updatedAt;
  
  /// Create a new CMS page
  CMSPage({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.metaTitle,
    this.metaDescription,
    this.featuredImage,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Create a CMS page from JSON
  factory CMSPage.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};
    
    return CMSPage(
      id: json['id'] ?? 0,
      title: attributes['title'] ?? '',
      slug: attributes['slug'] ?? '',
      content: attributes['content'] ?? '',
      metaTitle: attributes['metaTitle'],
      metaDescription: attributes['metaDescription'],
      featuredImage: attributes['featuredImage']?['data']?['attributes']?['url'],
      isPublished: attributes['isPublished'] ?? false,
      createdAt: DateTime.parse(attributes['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(attributes['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  /// Convert CMS page to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attributes': {
        'title': title,
        'slug': slug,
        'content': content,
        'metaTitle': metaTitle,
        'metaDescription': metaDescription,
        'featuredImage': featuredImage != null ? {
          'data': {
            'attributes': {
              'url': featuredImage,
            },
          },
        } : null,
        'isPublished': isPublished,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      },
    };
  }
}
