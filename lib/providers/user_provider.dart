import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  User _user = User();
  bool _isLoading = false;

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isPremium => _user.isPremium;
  double get totalIncome => _user.totalIncome;
  String get currency => _user.currency;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _dbService.getUser();
    } catch (e) {
      // Error loading user: $e
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _dbService.updateUser(user);
      _user = user;
      notifyListeners();
    } catch (e) {
      // Error updating user: $e
      rethrow;
    }
  }

  Future<void> upgradeToPremium() async {
    try {
      User updatedUser = _user.copyWith(isPremium: true);
      await updateUser(updatedUser);
    } catch (e) {
      // Error upgrading to premium: $e
      rethrow;
    }
  }

  Future<void> updateTotalIncome(double income) async {
    try {
      User updatedUser = _user.copyWith(totalIncome: income);
      await updateUser(updatedUser);
    } catch (e) {
      // Error updating total income: $e
      rethrow;
    }
  }

  Future<void> updateCurrency(String currency) async {
    try {
      User updatedUser = _user.copyWith(currency: currency);
      await updateUser(updatedUser);
    } catch (e) {
      // Error updating currency: $e
      rethrow;
    }
  }

  Future<void> updatePushNotifications(bool enabled) async {
    try {
      User updatedUser = _user.copyWith(pushNotificationsEnabled: enabled);
      await updateUser(updatedUser);
    } catch (e) {
      // Error updating push notifications: $e
      rethrow;
    }
  }

  Future<void> updateBudgetAlerts(bool enabled) async {
    try {
      User updatedUser = _user.copyWith(budgetAlertsEnabled: enabled);
      await updateUser(updatedUser);
    } catch (e) {
      // Error updating budget alerts: $e
      rethrow;
    }
  }

  Future<void> updateGoalReminders(bool enabled) async {
    try {
      User updatedUser = _user.copyWith(goalRemindersEnabled: enabled);
      await updateUser(updatedUser);
    } catch (e) {
      // Error updating goal reminders: $e
      rethrow;
    }
  }

  Future<void> updateThemeMode(String themeMode) async {
    try {
      User updatedUser = _user.copyWith(themeMode: themeMode);
      await updateUser(updatedUser);
    } catch (e) {
      // Error updating theme mode: $e
      rethrow;
    }
  }

  Future<void> updateCustomPrimaryColor(int? colorValue) async {
    try {
      User updatedUser = _user.copyWith(customPrimaryColor: colorValue);
      await updateUser(updatedUser);
    } catch (e) {
      // Error updating custom primary color: $e
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      await _dbService.clearAllData();
      _user = User(); // Reset to default user
      notifyListeners();
    } catch (e) {
      // Error clearing data: $e
      rethrow;
    }
  }

  // Premium feature checks
  bool get canExportData => _user.canExportData;
  bool get canSyncBankAccounts => _user.canSyncBankAccounts;
  bool get hasAdvancedReports => _user.hasAdvancedReports;
}
