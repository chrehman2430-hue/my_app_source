import 'package:flutter/material.dart';

class SavingsGoal {
  final String? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime deadline;
  final String description;
  final Color? color;
  final String? icon;

  SavingsGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.deadline,
    required this.description,
    this.color,
    this.icon,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    if (currentAmount.isNaN || targetAmount.isNaN) return 0.0;
    final percentage = currentAmount / targetAmount;
    return percentage.isNaN ? 0.0 : percentage.clamp(0.0, 1.0);
  }
  double get remainingAmount => targetAmount - currentAmount;
  bool get isCompleted => currentAmount >= targetAmount;
  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'description': description,
      'color': color?.toARGB32(),
      'icon': icon,
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      name: map['name'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'] ?? 0.0,
      deadline: DateTime.parse(map['deadline']),
      description: map['description'],
      color: map['color'] != null ? Color(map['color']) : null,
      icon: map['icon'],
    );
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? description,
    Color? color,
    String? icon,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}
