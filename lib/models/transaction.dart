import 'package:flutter/material.dart';

enum TransactionType {
  income,
  expense,
}

class Transaction {
  final String? id;
  final DateTime date;
  final String category;
  final double amount;
  final String description;
  final bool isIncome;
  final Color? color;
  final String? icon;

  Transaction({
    this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.description,
    required this.isIncome,
    this.color,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'category': category,
      'amount': amount,
      'description': description,
      'isIncome': isIncome,
      'color': color?.toARGB32(),
      'icon': icon,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      amount: map['amount'],
      description: map['description'] ?? map['note'] ?? '',
      isIncome: map['isIncome'] ?? false,
      color: map['color'] != null ? Color(map['color']) : null,
      icon: map['icon'],
    );
  }

  Transaction copyWith({
    String? id,
    DateTime? date,
    String? category,
    double? amount,
    String? description,
    bool? isIncome,
    Color? color,
    String? icon,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isIncome: isIncome ?? this.isIncome,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  TransactionType get type => isIncome ? TransactionType.income : TransactionType.expense;
}

