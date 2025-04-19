/// Model for a CMS FAQ
class CMSFAQ {
  /// FAQ ID
  final int id;
  
  /// FAQ question
  final String question;
  
  /// FAQ answer
  final String answer;
  
  /// FAQ category
  final String category;
  
  /// FAQ order
  final int order;
  
  /// FAQ is published
  final bool isPublished;
  
  /// FAQ created at
  final DateTime createdAt;
  
  /// FAQ updated at
  final DateTime updatedAt;
  
  /// Create a new CMS FAQ
  CMSFAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.order,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Create a CMS FAQ from JSON
  factory CMSFAQ.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] ?? {};
    
    return CMSFAQ(
      id: json['id'] ?? 0,
      question: attributes['question'] ?? '',
      answer: attributes['answer'] ?? '',
      category: attributes['category'] ?? 'General',
      order: attributes['order'] ?? 0,
      isPublished: attributes['isPublished'] ?? false,
      createdAt: DateTime.parse(attributes['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(attributes['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  /// Convert CMS FAQ to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attributes': {
        'question': question,
        'answer': answer,
        'category': category,
        'order': order,
        'isPublished': isPublished,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      },
    };
  }
}
