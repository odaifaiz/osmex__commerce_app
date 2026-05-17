import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final int itemCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.itemCount,
  });

  /// Creates a CategoryModel from JSON (API response)
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? json['name']?.toString().toLowerCase() ?? '',
      name: json['name'] ?? '',
      icon: Icons.category, // Default icon
      itemCount: json['itemCount'] ?? 0,
    );
  }

  /// Converts CategoryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'itemCount': itemCount,
    };
  }
}
