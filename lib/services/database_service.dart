import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/user.dart';

class DatabaseService {
  static const String _transactionsKey = 'transactions';
  static const String _categoriesKey = 'categories';
  static const String _budgetsKey = 'budgets';
  static const String _savingsGoalsKey = 'savings_goals';
  static const String _userKey = 'user';

  final Uuid _uuid = const Uuid();

  // Transaction CRUD operations
  Future<String> insertTransaction(Transaction transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = await getTransactions();
    final id = transaction.id ?? _uuid.v4();
    final newTransaction = transaction.copyWith(id: id);
    transactions.add(newTransaction);

    final transactionsJson = transactions.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(_transactionsKey, transactionsJson);
    return id;
  }

  Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getStringList(_transactionsKey) ?? [];
    return transactionsJson.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return Transaction.fromMap(map);
    }).toList();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      final transactionsJson = transactions.map((t) => jsonEncode(t.toMap())).toList();
      await prefs.setStringList(_transactionsKey, transactionsJson);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == id);
    final transactionsJson = transactions.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(_transactionsKey, transactionsJson);
  }

  // Category CRUD operations
  Future<String> insertCategory(Category category) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = await getCategories();
    final id = category.id ?? _uuid.v4();
    final newCategory = category.copyWith(id: id);
    categories.add(newCategory);

    final categoriesJson = categories.map((c) => jsonEncode(c.toMap())).toList();
    await prefs.setStringList(_categoriesKey, categoriesJson);
    return id;
  }

  Future<List<Category>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getStringList(_categoriesKey) ?? [];
    return categoriesJson.map((json) => Category.fromMap(jsonDecode(json))).toList();
  }

  Future<void> updateCategory(Category category) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = await getCategories();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      final categoriesJson = categories.map((c) => jsonEncode(c.toMap())).toList();
      await prefs.setStringList(_categoriesKey, categoriesJson);
    }
  }

  Future<void> deleteCategory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final categories = await getCategories();
    categories.removeWhere((c) => c.id == id);
    final categoriesJson = categories.map((c) => jsonEncode(c.toMap())).toList();
    await prefs.setStringList(_categoriesKey, categoriesJson);
  }

  // Budget CRUD operations
  Future<String> insertBudget(Budget budget) async {
    final prefs = await SharedPreferences.getInstance();
    final budgets = await getBudgets();
    final id = budget.id ?? _uuid.v4();
    final newBudget = budget.copyWith(id: id);
    budgets.add(newBudget);

    final budgetsJson = budgets.map((b) => jsonEncode(b.toMap())).toList();
    await prefs.setStringList(_budgetsKey, budgetsJson);
    return id;
  }

  Future<List<Budget>> getBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = prefs.getStringList(_budgetsKey) ?? [];
    return budgetsJson.map((json) => Budget.fromMap(jsonDecode(json))).toList();
  }

  Future<void> updateBudget(Budget budget) async {
    final prefs = await SharedPreferences.getInstance();
    final budgets = await getBudgets();
    final index = budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      budgets[index] = budget;
      final budgetsJson = budgets.map((b) => jsonEncode(b.toMap())).toList();
      await prefs.setStringList(_budgetsKey, budgetsJson);
    }
  }

  Future<void> deleteBudget(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final budgets = await getBudgets();
    budgets.removeWhere((b) => b.id == id);
    final budgetsJson = budgets.map((b) => jsonEncode(b.toMap())).toList();
    await prefs.setStringList(_budgetsKey, budgetsJson);
  }

  // Savings Goal CRUD operations
  Future<String> insertSavingsGoal(SavingsGoal goal) async {
    final prefs = await SharedPreferences.getInstance();
    final goals = await getSavingsGoals();
    final id = goal.id ?? _uuid.v4();
    final newGoal = goal.copyWith(id: id);
    goals.add(newGoal);

    final goalsJson = goals.map((g) => jsonEncode(g.toMap())).toList();
    await prefs.setStringList(_savingsGoalsKey, goalsJson);
    return id;
  }

  Future<List<SavingsGoal>> getSavingsGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getStringList(_savingsGoalsKey) ?? [];
    return goalsJson.map((json) => SavingsGoal.fromMap(jsonDecode(json))).toList();
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    final prefs = await SharedPreferences.getInstance();
    final goals = await getSavingsGoals();
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      goals[index] = goal;
      final goalsJson = goals.map((g) => jsonEncode(g.toMap())).toList();
      await prefs.setStringList(_savingsGoalsKey, goalsJson);
    }
  }

  Future<void> deleteSavingsGoal(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final goals = await getSavingsGoals();
    goals.removeWhere((g) => g.id == id);
    final goalsJson = goals.map((g) => jsonEncode(g.toMap())).toList();
    await prefs.setStringList(_savingsGoalsKey, goalsJson);
  }

  // User operations
  Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromMap(jsonDecode(userJson));
    }
    return User();
  }

  Future<void> updateUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }

  // Initialize default data
  Future<void> initializeDefaults() async {
    final categories = await getCategories();
    if (categories.isEmpty) {
      for (var category in Category.defaultCategories) {
        await insertCategory(category);
      }
    }

    final user = await getUser();
    if (user.id == null) {
      await updateUser(user);
    }
  }

  // Analytics queries
  Future<double> getTotalIncome() async {
    final transactions = await getTransactions();
    return transactions.where((t) => t.isIncome).fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  Future<double> getTotalExpenses() async {
    final transactions = await getTransactions();
    return transactions.where((t) => !t.isIncome).fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  Future<Map<String, double>> getExpensesByCategory() async {
    final transactions = await getTransactions();
    final expenses = <String, double>{};
    for (var transaction in transactions) {
      if (!transaction.isIncome) {
        expenses[transaction.category] = (expenses[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return expenses;
  }

  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final transactions = await getTransactions();
    return transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
    await prefs.remove(_categoriesKey);
    await prefs.remove(_budgetsKey);
    await prefs.remove(_savingsGoalsKey);
    await prefs.remove(_userKey);
  }
}
