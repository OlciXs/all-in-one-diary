import 'category.dart';

class Entry {
  final int id;
  final String title;
  final String? content;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isAllDay;
  final int categoryId;
  final Category? category;

  Entry({
    required this.id,
    required this.title,
    this.content,
    required this.startDate,
    this.endDate,
    this.isAllDay = true,
    required this.categoryId,
    this.category,
  });

factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate']).toLocal() 
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate']).toLocal() 
          : null,
      isAllDay: json['isAllDay'] as bool? ?? true,
      categoryId: json['categoryId'] as int,
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isAllDay': isAllDay,
      'categoryId': categoryId,
    };
  }
}