import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF2E7D32);
  static const Color primaryGreenLight = Color(0xFF81C784);

  // Semantic Colors - Light Theme
  static const Color incomeLight = Color(0xFF2196F3); // Blue
  static const Color expenseLight = Color(0xFFE53935); // Red
  static const Color savingsLight = Color(0xFFFF9800); // Orange
  static const Color budgetLight = Color(0xFF4CAF50); // Green

  // Semantic Colors - Dark Theme (Brighter variants)
  static const Color incomeDark = Color(0xFF42A5F5); // Brighter Blue
  static const Color expenseDark = Color(0xFFEF5350); // Brighter Red
  static const Color savingsDark = Color(0xFFFFB74D); // Brighter Orange
  static const Color budgetDark = Color(0xFF66BB6A); // Brighter Green

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Card Colors
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF2D2D2D);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);

  // Success/Error Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Gradient Colors
  static const List<Color> primaryGradientLight = [
    Color(0xFFE8F5E8),
    Color(0xFFF3E5F5),
  ];

  static const List<Color> primaryGradientDark = [
    Color(0xFF1A1A1A),
    Color(0xFF2D2D2D),
  ];

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFFE91E63), // Pink
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFF44336), // Red
  ];

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'Food & Dining': Color(0xFFFF5722),
    'Transportation': Color(0xFF3F51B5),
    'Shopping': Color(0xFFE91E63),
    'Entertainment': Color(0xFF9C27B0),
    'Bills & Utilities': Color(0xFF607D8B),
    'Healthcare': Color(0xFF4CAF50),
    'Education': Color(0xFF00BCD4),
    'Travel': Color(0xFFFF9800),
    'Personal Care': Color(0xFFCDDC39),
    'Gifts & Donations': Color(0xFF795548),
    'Income': Color(0xFF2196F3),
    'Savings': Color(0xFFFF9800),
    'Investment': Color(0xFF4CAF50),
    'Other': Color(0xFF9E9E9E),
  };

  // Helper methods for color variations
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Get semantic color based on context and theme
  static Color getIncomeColor(bool isDark) => isDark ? incomeDark : incomeLight;
  static Color getExpenseColor(bool isDark) => isDark ? expenseDark : expenseLight;
  static Color getSavingsColor(bool isDark) => isDark ? savingsDark : savingsLight;
  static Color getBudgetColor(bool isDark) => isDark ? budgetDark : budgetLight;

  // Get category color
  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? categoryColors['Other']!;
  }

  // Get chart color by index
  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }
}
