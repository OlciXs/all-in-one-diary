class Entry {
  final int id;
  final String title;
  final String content;
  final int categoryId;
  final int userId;

  Entry({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.userId,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      categoryId: json['categoryId'] as int,
      userId: json['userId'] as int,
    );
  }
}