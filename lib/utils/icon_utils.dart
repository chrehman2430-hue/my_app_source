import 'package:flutter/material.dart';

class IconUtils {
  static IconData getIconData(String? iconName) {
    if (iconName == null) return Icons.category;

    switch (iconName.toLowerCase()) {
      case 'restaurant':
      case 'food':
        return Icons.restaurant;
      case 'shopping':
      case 'cart':
        return Icons.shopping_cart;
      case 'transport':
      case 'car':
        return Icons.directions_car;
      case 'entertainment':
      case 'movie':
        return Icons.movie;
      case 'health':
      case 'medical':
        return Icons.local_hospital;
      case 'education':
      case 'school':
        return Icons.school;
      case 'home':
      case 'house':
        return Icons.home;
      case 'utilities':
      case 'electricity':
        return Icons.flash_on;
      case 'salary':
      case 'income':
        return Icons.attach_money;
      case 'gift':
        return Icons.card_giftcard;
      case 'travel':
        return Icons.flight;
      case 'sports':
        return Icons.sports_soccer;
      case 'pets':
        return Icons.pets;
      case 'beauty':
        return Icons.face;
      case 'insurance':
        return Icons.security;
      case 'savings':
        return Icons.savings;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.category;
    }
  }

  static String getIconName(IconData icon) {
    // This is a reverse mapping for when we need to store icon as string
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.shopping_cart) return 'shopping';
    if (icon == Icons.directions_car) return 'transport';
    if (icon == Icons.movie) return 'entertainment';
    if (icon == Icons.local_hospital) return 'health';
    if (icon == Icons.school) return 'education';
    if (icon == Icons.home) return 'home';
    if (icon == Icons.flash_on) return 'utilities';
    if (icon == Icons.attach_money) return 'salary';
    if (icon == Icons.card_giftcard) return 'gift';
    if (icon == Icons.flight) return 'travel';
    if (icon == Icons.sports_soccer) return 'sports';
    if (icon == Icons.pets) return 'pets';
    if (icon == Icons.face) return 'beauty';
    if (icon == Icons.security) return 'insurance';
    if (icon == Icons.savings) return 'savings';
    if (icon == Icons.trending_up) return 'investment';
    return 'category';
  }
}
