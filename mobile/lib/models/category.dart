import 'package:flutter/material.dart';

class Category {
  final int id;
  final String name;
  final Color color;
  final bool hasContent;
  final bool hasPhotos;
  final bool hasDate;
  final bool defaultToCurrentDate;
  final bool allowTimeRange;

  Category({
    required this.id,
    required this.name,
    required this.color,
    this.hasContent = true,
    this.hasPhotos = true,
    this.hasDate = true,
    this.defaultToCurrentDate = true,
    this.allowTimeRange = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      color: _colorFromHex(json['color'] as String? ?? '#2196F3'),
      hasContent: json['hasContent'] as bool? ?? true,
      hasPhotos: json['hasPhotos'] as bool? ?? true,
      hasDate: json['hasDate'] as bool? ?? true,
      defaultToCurrentDate: json['defaultToCurrentDate'] as bool? ?? true,
      allowTimeRange: json['allowTimeRange'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}',
      'hasContent': hasContent,
      'hasPhotos': hasPhotos,
      'hasDate': hasDate,
      'defaultToCurrentDate': defaultToCurrentDate,
      'allowTimeRange': allowTimeRange,
    };
  }

  static Color _colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}