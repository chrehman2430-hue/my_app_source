import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class ColorUtils {
  // Private constructor to prevent instantiation
  ColorUtils._();

  // Get semantic colors based on context
  static Color getIncomeColor(BuildContext context) {
    return AppTheme.getIncomeColor(context);
  }

  static Color getExpenseColor(BuildContext context) {
    return AppTheme.getExpenseColor(context);
  }

  static Color getSavingsColor(BuildContext context) {
    return AppTheme.getSavingsColor(context);
  }

  static Color getBudgetColor(BuildContext context) {
    return AppTheme.getBudgetColor(context);
  }

  // Get category color
  static Color getCategoryColor(String category) {
    return AppColors.getCategoryColor(category);
  }

  // Get chart color by index
  static Color getChartColor(int index) {
    return AppColors.getChartColor(index);
  }

  // Color manipulation utilities
  static Color lighten(Color color, [double amount = 0.1]) {
    return AppColors.lighten(color, amount);
  }

  static Color darken(Color color, [double amount = 0.1]) {
    return AppColors.darken(color, amount);
  }

  static Color withOpacity(Color color, double opacity) {
    return AppColors.withOpacity(color, opacity);
  }

  // Get transaction type color
  static Color getTransactionTypeColor(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return getIncomeColor(context);
      case 'expense':
        return getExpenseColor(context);
      default:
        return Theme.of(context).primaryColor;
    }
  }

  // Get progress color based on percentage
  static Color getProgressColor(BuildContext context, double percentage) {
    if (percentage >= 1.0) {
      return getExpenseColor(context); // Over budget - red
    } else if (percentage >= 0.8) {
      return AppColors.warning; // Warning - orange
    } else {
      return getBudgetColor(context); // Good - green
    }
  }

  // Get balance color
  static Color getBalanceColor(BuildContext context, double balance) {
    return balance >= 0 ? getIncomeColor(context) : getExpenseColor(context);
  }

  // Convert Color to int for storage
  static int colorToInt(Color color) {
    return color.toARGB32();
  }

  // Convert int to Color for retrieval
  static Color intToColor(int colorValue) {
    return Color(colorValue);
  }

  // Get gradient colors based on theme
  static List<Color> getPrimaryGradient(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return isDark ? AppColors.primaryGradientDark : AppColors.primaryGradientLight;
  }

  // Get surface color based on theme
  static Color getSurfaceColor(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
  }

  // Get background color based on theme
  static Color getBackgroundColor(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
  }

  // Get text colors based on theme
  static Color getPrimaryTextColor(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  }

  // Predefined color options for user customization
  static const List<Color> customColorOptions = [
    AppColors.primaryGreen,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightGreen,
    Colors.deepPurple,
  ];

  // Get color name for display
  static String getColorName(Color color) {
    if (color == AppColors.primaryGreen) return 'Green';
    if (color == Colors.blue) return 'Blue';
    if (color == Colors.purple) return 'Purple';
    if (color == Colors.orange) return 'Orange';
    if (color == Colors.teal) return 'Teal';
    if (color == Colors.indigo) return 'Indigo';
    if (color == Colors.pink) return 'Pink';
    if (color == Colors.cyan) return 'Cyan';
    if (color == Colors.amber) return 'Amber';
    if (color == Colors.deepOrange) return 'Deep Orange';
    if (color == Colors.lightGreen) return 'Light Green';
    if (color == Colors.deepPurple) return 'Deep Purple';
    return 'Custom';
  }

  // Check if color is dark
  static bool isColorDark(Color color) {
    final luminance = color.computeLuminance();
    return luminance < 0.5;
  }

  // Get contrasting text color for a background color
  static Color getContrastingTextColor(Color backgroundColor) {
    return isColorDark(backgroundColor) ? Colors.white : Colors.black;
  }
}
