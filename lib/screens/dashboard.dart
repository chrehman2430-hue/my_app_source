import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/savings_goal_provider.dart';
import '../models/transaction.dart' as finance_transaction;
import '../utils/icon_utils.dart';
import '../utils/currency_utils.dart';
import '../utils/color_utils.dart';
import '../widgets/bottom_navigation_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  @override
  void initState() {
    super.initState();
    // Listen for route changes to refresh data when returning from add transaction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final router = GoRouter.of(context);
        router.routerDelegate.addListener(_onRouteChanged);
      }
    });
  }

  @override
  void dispose() {
    final router = GoRouter.of(context);
    router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (mounted) {
      final currentLocation = GoRouterState.of(context).uri.toString();
      // Refresh data when returning to dashboard from add transaction
      if (currentLocation == '/' || currentLocation.startsWith('/?')) {
        _loadData();
      }
    }
  }

  Future<void> _loadData() async {
    await context.read<TransactionProvider>().loadTransactions();
    await context.read<UserProvider>().loadUser();
    await context.read<BudgetProvider>().loadBudgets();
    await context.read<SavingsGoalProvider>().loadSavingsGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Consumer4<TransactionProvider, UserProvider, BudgetProvider, SavingsGoalProvider>(
        builder: (context, transactionProvider, userProvider, budgetProvider, savingsGoalProvider, child) {
          if (transactionProvider.isLoading || userProvider.isLoading || budgetProvider.isLoading || savingsGoalProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Balance with Monthly Budget Progress
                  _buildBalanceWithBudgetCard(transactionProvider, userProvider, budgetProvider),

                  const SizedBox(height: 24),

                  // Categorized Expense Cards
                  _buildExpenseCategories(transactionProvider),

                  const SizedBox(height: 24),

                  // Monthly Expenses Chart
                  _buildExpenseChart(transactionProvider),

                  const SizedBox(height: 24),

                  // Savings Goals
                  _buildSavingsGoals(savingsGoalProvider),

                  const SizedBox(height: 24),

                  // Budget Overview
                  _buildBudgetOverview(budgetProvider),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildBalanceWithBudgetCard(TransactionProvider transactionProvider, UserProvider userProvider, BudgetProvider budgetProvider) {
    final totalBudget = budgetProvider.totalMonthlyBudget;
    final totalSpent = budgetProvider.totalCurrentSpent;
    final progress = totalBudget > 0 ? totalSpent / totalBudget : 0.0;
    final isOverBudget = totalSpent > totalBudget;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '${userProvider.user.currencySymbol}${transactionProvider.balance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: ColorUtils.getBalanceColor(context, transactionProvider.balance),
              ),
            ),
            const SizedBox(height: 16),
            // Monthly Budget Progress
            if (totalBudget > 0) ...[
              const Text(
                'Monthly Budget Progress',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ColorUtils.getProgressColor(context, progress),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${CurrencyUtils.formatCurrencyWithUser(context, totalSpent)} spent',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverBudget ? ColorUtils.getExpenseColor(context) : Colors.grey,
                    ),
                  ),
                  Text(
                    '${CurrencyUtils.formatCurrencyWithUser(context, totalBudget)} budget',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIncomeExpenseItem(
                  'Income',
                  transactionProvider.totalIncome,
                  ColorUtils.getIncomeColor(context),
                  userProvider,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                _buildIncomeExpenseItem(
                  'Expenses',
                  transactionProvider.totalExpenses,
                  ColorUtils.getExpenseColor(context),
                  userProvider,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCategories(TransactionProvider provider) {
    final expensesByCategory = provider.getExpensesByCategory();

    if (expensesByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by amount descending and take top categories
    final sortedCategories = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Spending Categories',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...sortedCategories.take(5).map((entry) {
          final percentage = (entry.value / expensesByCategory.values.fold(0.0, (sum, value) => sum + value)) * 100;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.primaries[sortedCategories.indexOf(entry) % Colors.primaries.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyUtils.formatCurrencyWithUser(context, entry.value),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBalanceCard(TransactionProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyUtils.formatCurrencyWithUser(context, provider.balance),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: provider.balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIncomeExpenseItem(
                  'Income',
                  provider.totalIncome,
                  Colors.green,
                  context.read<UserProvider>(),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                _buildIncomeExpenseItem(
                  'Expenses',
                  provider.totalExpenses,
                  Colors.red,
                  context.read<UserProvider>(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseItem(String label, double amount, Color color, UserProvider userProvider) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          '${userProvider.user.currencySymbol}${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickActionButton(
              'Add Transaction',
              Icons.add,
              () => context.go('/add-transaction?source=dashboard'),
            ),
            _buildQuickActionButton(
              'View Transactions',
              Icons.list,
              () => context.go('/transactions'),
            ),
            _buildQuickActionButton(
              'Budget',
              Icons.account_balance_wallet,
              () => context.go('/budget-planner'),
            ),
            _buildQuickActionButton(
              'Reports',
              Icons.bar_chart,
              () => context.go('/reports'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChart(TransactionProvider provider) {
    final expensesByCategory = provider.getExpensesByCategory();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expense Categories',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: expensesByCategory.isEmpty
                  ? const Center(child: Text('No expense data available'))
                  : PieChart(
                      PieChartData(
                        sections: expensesByCategory.entries.map((entry) {
                          final total = expensesByCategory.values.fold(0.0, (sum, value) => sum + value);
                          final percentage = (entry.value / total) * 100;
                          return PieChartSectionData(
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            color: Colors.primaries[expensesByCategory.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetOverview(BudgetProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Monthly Budget',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.go('/budget-planner'),
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.budgets.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('No budgets set up yet'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.go('/budget-planner'),
                    child: const Text('Create Budget'),
                  ),
                ],
              ),
            ),
          )
        else
          ...provider.budgets.take(3).map((budget) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            budget.categoryName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${CurrencyUtils.formatCurrencyWithUser(context, budget.currentSpent)} / ${CurrencyUtils.formatCurrencyWithUser(context, budget.monthlyLimit)}',
                            style: TextStyle(
                              color: budget.isOverBudget ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: budget.progressPercentage,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          budget.isOverBudget ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        budget.isOverBudget
                            ? 'Over budget by ${CurrencyUtils.formatCurrencyWithUser(context, budget.currentSpent - budget.monthlyLimit)}'
                            : '${CurrencyUtils.formatCurrencyWithUser(context, budget.remainingAmount)} remaining',
                        style: TextStyle(
                          fontSize: 12,
                          color: budget.isOverBudget ? Colors.red : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildSavingsGoals(SavingsGoalProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Savings Goals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.go('/savings-goals'),
              child: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.savingsGoals.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('No savings goals set up yet'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context.go('/savings-goals'),
                    child: const Text('Create Goal'),
                  ),
                ],
              ),
            ),
          )
        else
          ...provider.savingsGoals.take(3).map((goal) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            goal.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${CurrencyUtils.formatCurrencyWithUser(context, goal.currentAmount)} / ${CurrencyUtils.formatCurrencyWithUser(context, goal.targetAmount)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: goal.progressPercentage,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          goal.color ?? Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.isCompleted
                            ? 'Goal achieved! 🎉'
                            : '${CurrencyUtils.formatCurrencyWithUser(context, goal.remainingAmount)} remaining',
                        style: TextStyle(
                          fontSize: 12,
                          color: goal.isCompleted ? Colors.green : Colors.grey,
                        ),
                      ),
                      if (!goal.isCompleted)
                        Text(
                          '${goal.daysRemaining} days remaining',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildRecentTransactions(TransactionProvider provider) {
    final recentTransactions = provider.getRecentTransactions(5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.go('/transactions'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentTransactions.isEmpty)
          const Center(
            child: Text('No transactions yet'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = recentTransactions[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: transaction.color ?? Colors.blue,
                  child: Icon(
                    transaction.icon != null
                        ? IconUtils.getIconData(transaction.icon)
                        : transaction.type == finance_transaction.TransactionType.income
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                    color: Colors.white,
                  ),
                ),
                title: Text(transaction.description),
                subtitle: Text(transaction.category),
                trailing: Text(
                  '${transaction.type == finance_transaction.TransactionType.income ? '+' : '-'}${CurrencyUtils.formatCurrencyWithUser(context, transaction.amount)}',
                  style: TextStyle(
                    color: transaction.type == finance_transaction.TransactionType.income
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMonthlyOverview(TransactionProvider provider) {
    final expensesByCategory = provider.getExpensesByCategory();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Top Spending Categories',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (expensesByCategory.isEmpty)
                  const Text('No expense data available')
                else
                  ...(() {
                    final sorted = expensesByCategory.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));
                    return sorted.take(3).map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text(CurrencyUtils.formatCurrencyWithUser(context, entry.value)),
                            ],
                          ),
                        ));
                  })(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/transactions');
            break;
          case 2:
            context.go('/reports');
            break;
          case 3:
            context.go('/settings');
            break;
        }
      },
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey.shade600,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
