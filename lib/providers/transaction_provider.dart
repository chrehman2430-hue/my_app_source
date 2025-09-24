import 'package:flutter/material.dart';
import '../models/transaction.dart' as finance_transaction;
import '../services/database_service.dart';
import '../providers/budget_provider.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<finance_transaction.Transaction> _transactions = [];
  bool _isLoading = false;
  BudgetProvider? _budgetProvider;

  void setBudgetProvider(BudgetProvider budgetProvider) {
    _budgetProvider = budgetProvider;
  }

  List<finance_transaction.Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => _transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpenses;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _dbService.getTransactions();
    } catch (e) {
      // Error loading transactions: $e
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(finance_transaction.Transaction transaction) async {
    try {
      await _dbService.insertTransaction(transaction);
      await loadTransactions(); // Reload to get updated list
      
      // Update budget spending if this is an expense transaction
      if (!transaction.isIncome && _budgetProvider != null) {
        await _updateBudgetSpending(transaction.category, transaction.amount);
      }
      
      notifyListeners(); // Ensure UI updates immediately
    } catch (e) {
      // Error adding transaction: $e
      rethrow;
    }
  }

  Future<void> updateTransaction(finance_transaction.Transaction transaction) async {
    try {
      await _dbService.updateTransaction(transaction);
      await loadTransactions();
      
      // Recalculate all budget spending after transaction update
      if (_budgetProvider != null) {
        await _recalculateAllBudgetSpending();
      }
    } catch (e) {
      // Error updating transaction: $e
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _dbService.deleteTransaction(id);
      await loadTransactions();
      
      // Recalculate all budget spending after transaction deletion
      if (_budgetProvider != null) {
        await _recalculateAllBudgetSpending();
      }
    } catch (e) {
      // Error deleting transaction: $e
      rethrow;
    }
  }

  List<finance_transaction.Transaction> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  List<finance_transaction.Transaction> getRecentTransactions(int limit) {
    return _transactions.take(limit).toList();
  }

  Map<String, double> getExpensesByCategory() {
    Map<String, double> expenses = {};
    for (var transaction in _transactions) {
      if (!transaction.isIncome) {
        expenses[transaction.category] = (expenses[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return expenses;
  }

  Future<void> _updateBudgetSpending(String categoryName, double amount) async {
    if (_budgetProvider != null) {
      _budgetProvider!.updateBudgetSpent(categoryName, amount);
      // Also update the budget in the database
      final budgets = _budgetProvider!.getBudgetsByCategory(categoryName);
      for (var budget in budgets) {
        await _budgetProvider!.updateBudget(budget);
      }
    }
  }

  Future<void> _recalculateAllBudgetSpending() async {
    if (_budgetProvider == null) return;
    
    // Get all expense categories and their totals
    final expensesByCategory = getExpensesByCategory();
    
    // Reset all budget spending and recalculate
    for (var budget in _budgetProvider!.budgets) {
      final categorySpending = expensesByCategory[budget.categoryName] ?? 0.0;
      final updatedBudget = budget.copyWith(currentSpent: categorySpending);
      await _budgetProvider!.updateBudget(updatedBudget);
    }
  }
}
