/// Utility functions for currency formatting and display
library;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class CurrencyUtils {
  /// Formats an amount with the given currency symbol
  static String formatCurrency(double amount, String currencySymbol) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  /// Formats an amount using the user's currency from UserProvider
  /// This requires the context to have access to UserProvider
  static String formatCurrencyWithUser(BuildContext context, double amount) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return formatCurrency(amount, userProvider.user.currencySymbol ?? '\$');
  }

  /// Formats currency without symbol (just the number)
  static String formatCurrencyWithoutSymbol(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Formats currency in compact form (K, M, B)
  static String formatCompactCurrency(double amount) {
    if (amount.abs() >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  /// Formats currency in compact form with symbol
  static String formatCompactCurrencyWithSymbol(double amount, String currencySymbol) {
    return '$currencySymbol${formatCompactCurrency(amount)}';
  }

  /// Formats percentage
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Formats large numbers with commas
  static String formatNumberWithCommas(double number) {
    final parts = number.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    
    String formattedInteger = '';
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        formattedInteger += ',';
      }
      formattedInteger += integerPart[i];
    }
    
    return '$formattedInteger.$decimalPart';
  }
}
