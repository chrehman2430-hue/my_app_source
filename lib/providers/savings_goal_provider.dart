import 'package:flutter/material.dart';
import '../models/savings_goal.dart';
import '../services/database_service.dart';

class SavingsGoalProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<SavingsGoal> _savingsGoals = [];
  bool _isLoading = false;

  List<SavingsGoal> get savingsGoals => _savingsGoals;
  bool get isLoading => _isLoading;

  double get totalTargetAmount => _savingsGoals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
  double get totalCurrentAmount => _savingsGoals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
  double get totalRemaining => totalTargetAmount - totalCurrentAmount;

  List<SavingsGoal> get completedGoals => _savingsGoals.where((goal) => goal.isCompleted).toList();
  List<SavingsGoal> get activeGoals => _savingsGoals.where((goal) => !goal.isCompleted).toList();

  Future<void> loadSavingsGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      _savingsGoals = await _dbService.getSavingsGoals();
    } catch (e) {
      // Error loading savings goals: $e
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    try {
      await _dbService.insertSavingsGoal(goal);
      await loadSavingsGoals(); // Reload to get updated list
    } catch (e) {
      // Error adding savings goal: $e
      rethrow;
    }
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    try {
      await _dbService.updateSavingsGoal(goal);
      await loadSavingsGoals();
    } catch (e) {
      // Error updating savings goal: $e
      rethrow;
    }
  }

  Future<void> deleteSavingsGoal(String id) async {
    try {
      await _dbService.deleteSavingsGoal(id);
      await loadSavingsGoals();
    } catch (e) {
      // Error deleting savings goal: $e
      rethrow;
    }
  }

  void updateSavingsGoalProgress(String id, double amount) {
    final goalIndex = _savingsGoals.indexWhere((goal) => goal.id == id);
    if (goalIndex != -1) {
      final updatedGoal = _savingsGoals[goalIndex].copyWith(
        currentAmount: _savingsGoals[goalIndex].currentAmount + amount,
      );
      _savingsGoals[goalIndex] = updatedGoal;
      notifyListeners();
    }
  }

  List<SavingsGoal> getUpcomingDeadlines(int days) {
    final now = DateTime.now();
    final deadline = now.add(Duration(days: days));
    return _savingsGoals.where((goal) => goal.deadline.isBefore(deadline) && !goal.isCompleted).toList();
  }
}
