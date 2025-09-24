import 'package:flutter/material.dart';

class Budget {
  final String? id;
  final String categoryId;
  final double monthlyLimit;
  final double currentSpent;
  final DateTime period;
  final String categoryName;
  final Color? categoryColor;

  Budget({
    this.id,
    required this.categoryId,
    required this.monthlyLimit,
    this.currentSpent = 0.0,
    required this.period,
    required this.categoryName,
    this.categoryColor,
  });

  double get remainingAmount => monthlyLimit - currentSpent;
  double get progressPercentage {
    if (monthlyLimit <= 0) return 0.0;
    if (currentSpent.isNaN || monthlyLimit.isNaN) return 0.0;
    final percentage = currentSpent / monthlyLimit;
    return percentage.isNaN ? 0.0 : percentage.clamp(0.0, double.infinity);
  }
  bool get isOverBudget => currentSpent > monthlyLimit;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'monthlyLimit': monthlyLimit,
      'currentSpent': currentSpent,
      'period': period.toIso8601String(),
      'categoryName': categoryName,
      'categoryColor': categoryColor?.toARGB32(),
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryId: map['categoryId'],
      monthlyLimit: map['monthlyLimit'],
      currentSpent: map['currentSpent'] ?? 0.0,
      period: DateTime.parse(map['period']),
      categoryName: map['categoryName'],
      categoryColor: map['categoryColor'] != null ? Color(map['categoryColor']) : null,
    );
  }

  Budget copyWith({
    String? id,
    String? categoryId,
    double? monthlyLimit,
    double? currentSpent,
    DateTime? period,
    String? categoryName,
    Color? categoryColor,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      currentSpent: currentSpent ?? this.currentSpent,
      period: period ?? this.period,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }
}