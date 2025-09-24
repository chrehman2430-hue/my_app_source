import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../services/database_service.dart';

class BudgetProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<Budget> _budgets = [];
  bool _isLoading = false;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;

  double get totalMonthlyBudget => _budgets.fold(0.0, (sum, budget) => sum + budget.monthlyLimit);
  double get totalCurrentSpent => _budgets.fold(0.0, (sum, budget) => sum + budget.currentSpent);
  double get totalRemaining => totalMonthlyBudget - totalCurrentSpent;

  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();





























































































































    try {
      _budgets = await _dbService.getBudgets();
    } catch (e) {
      // Error loading budgets: $e
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      await _dbService.insertBudget(budget);
      await loadBudgets(); // Reload to get updated list
    } catch (e) {
      // Error adding budget: $e
      rethrow;
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _dbService.updateBudget(budget);
      await loadBudgets();
    } catch (e) {
      // Error updating budget: $e
      rethrow;
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      await _dbService.deleteBudget(id);
      await loadBudgets();
    } catch (e) {
      // Error deleting budget: $e
      rethrow;
    }
  }

  List<Budget> getBudgetsByCategory(String categoryName) {
    return _budgets.where((budget) => budget.categoryName == categoryName).toList();
  }

  List<Budget> getOverBudgetItems() {
    return _budgets.where((budget) => budget.isOverBudget).toList();
  }

  void updateBudgetSpent(String categoryName, double amount) {
    final budgetIndex = _budgets.indexWhere((budget) => budget.categoryName == categoryName);
    if (budgetIndex != -1) {
      final updatedBudget = _budgets[budgetIndex].copyWith(
        currentSpent: _budgets[budgetIndex].currentSpent + amount,
      );
      _budgets[budgetIndex] = updatedBudget;
      notifyListeners();
    }
  }
}
