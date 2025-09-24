import 'package:flutter/material.dart';

class Category {
  final String? id;
  final String name;
  final String icon;
  final Color color;
  final double? budgetLimit;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.budgetLimit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color.toARGB32(),
      'budgetLimit': budgetLimit,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: Color(map['color']),
      budgetLimit: map['budgetLimit'],
    );
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    Color? color,
    double? budgetLimit,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budgetLimit: budgetLimit ?? this.budgetLimit,
    );
  }

  // Predefined categories
  static List<Category> get defaultCategories => [
    Category(name: 'Food', icon: 'restaurant', color: Colors.orange),
    Category(name: 'Transportation', icon: 'directions_car', color: Colors.blue),
    Category(name: 'Shopping', icon: 'shopping_bag', color: Colors.pink),
    Category(name: 'Bills', icon: 'receipt', color: Colors.red),
    Category(name: 'Entertainment', icon: 'movie', color: Colors.purple),
    Category(name: 'Health', icon: 'local_hospital', color: Colors.green),
    Category(name: 'Education', icon: 'school', color: Colors.teal),
    Category(name: 'Salary', icon: 'work', color: Colors.indigo),
    Category(name: 'Freelance', icon: 'computer', color: Colors.cyan),
    Category(name: 'Other', icon: 'category', color: Colors.grey),
  ];
}
