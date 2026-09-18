import 'category.dart';

class Entry {
  final int id;
  final String title;
  final String content;
  final int categoryId;
  final Category? category;
  final DateTime createdAt;

  Entry({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    this.category,
    required this.createdAt,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      categoryId: json['categoryId'],
      category: json['category'] != null 
          ? Category.fromJson(json['category']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'categoryId': categoryId,
    };
  }
}