import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/savings_goal_provider.dart';
import '../widgets/bottom_navigation_bar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReportType = 'Overview';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: const Color(0xFFE8F5E8),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF3E5F5),
            ],
          ),
        ),
        child: Consumer4<TransactionProvider, UserProvider, BudgetProvider, SavingsGoalProvider>(
          builder: (context, transactionProvider, userProvider, budgetProvider, savingsProvider, child) {
            if (transactionProvider.isLoading || budgetProvider.isLoading || savingsProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                await transactionProvider.loadTransactions();
                await budgetProvider.loadBudgets();
                await savingsProvider.loadSavingsGoals();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report Type Selector
                    _buildReportTypeSelector(),

                    const SizedBox(height: 24),

                    // Report Content
                    if (_selectedReportType == 'Overview')
                      _buildOverviewReport(transactionProvider, userProvider, budgetProvider, savingsProvider)
                    else if (_selectedReportType == 'Income vs Expenses')
                      _buildIncomeExpenseReport(transactionProvider)
                    else if (_selectedReportType == 'Budget Performance')
                      _buildBudgetReport(budgetProvider)
                    else if (_selectedReportType == 'Savings Progress')
                      _buildSavingsReport(savingsProvider)
                    else if (_selectedReportType == 'Category Breakdown')
                      _buildCategoryReport(transactionProvider),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }

  Widget _buildReportTypeSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildReportTypeChip('Overview'),
                _buildReportTypeChip('Income vs Expenses'),
                _buildReportTypeChip('Budget Performance'),
                _buildReportTypeChip('Savings Progress'),
                _buildReportTypeChip('Category Breakdown'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeChip(String type) {
    final isSelected = _selectedReportType == type;
    return FilterChip(
      label: Text(type),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedReportType = type;
          });
        }
      },
      backgroundColor: isSelected ? const Color(0xFF4CAF50).withValues(alpha: 0.1) : Colors.white,
      selectedColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF4CAF50),
    );
  }

  Widget _buildOverviewReport(TransactionProvider transactionProvider, UserProvider userProvider, BudgetProvider budgetProvider, SavingsGoalProvider savingsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Overview',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Income',
                '${userProvider.user.currencySymbol}${transactionProvider.totalIncome.toStringAsFixed(2)}',
                Icons.arrow_upward,
                const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Total Expenses',
                '\$${transactionProvider.totalExpenses.toStringAsFixed(2)}',
                Icons.arrow_downward,
                const Color(0xFFF44336),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Net Balance',
                '\$${transactionProvider.balance.toStringAsFixed(2)}',
                transactionProvider.balance >= 0 ? Icons.trending_up : Icons.trending_down,
                transactionProvider.balance >= 0 ? const Color(0xFF2196F3) : const Color(0xFFFF9800),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Active Budgets',
                '${budgetProvider.budgets.length}',
                Icons.account_balance_wallet,
                const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Quick Stats
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatRow('Savings Goals', '${savingsProvider.savingsGoals.length} active'),
                _buildStatRow('Completed Goals', '${savingsProvider.completedGoals.length} achieved'),
                _buildStatRow('Over Budget Items', '${budgetProvider.getOverBudgetItems().length} items'),
                _buildStatRow('Transaction Count', '${transactionProvider.transactions.length} total'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenseReport(TransactionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Income vs Expenses',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Monthly Comparison',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (provider.totalIncome > provider.totalExpenses ? provider.totalIncome : provider.totalExpenses) * 1.2,
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: provider.totalIncome,
                              color: const Color(0xFF4CAF50),
                              width: 30,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: provider.totalExpenses,
                              color: const Color(0xFFF44336),
                              width: 30,
                            ),
                          ],
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return const Text('Income');
                                case 1:
                                  return const Text('Expenses');
                                default:
                                  return const Text('');
                              }
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              return Text('\$${value.toInt()}');
                            },
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetReport(BudgetProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget Performance',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (provider.budgets.isEmpty)
          const Center(
            child: Text('No budgets to display'),
          )
        else
          ...provider.budgets.map((budget) => Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.categoryName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${budget.currentSpent.toStringAsFixed(2)} / \$${budget.monthlyLimit.toStringAsFixed(2)}'),
                          Text('${(budget.progressPercentage * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: budget.progressPercentage.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          budget.isOverBudget ? const Color(0xFFF44336) : const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildSavingsReport(SavingsGoalProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Savings Progress',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        if (provider.savingsGoals.isEmpty)
          const Center(
            child: Text('No savings goals to display'),
          )
        else
          ...provider.savingsGoals.map((goal) => Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('\$${goal.currentAmount.toStringAsFixed(2)} / \$${goal.targetAmount.toStringAsFixed(2)}'),
                          Text('${(goal.progressPercentage * 100).toStringAsFixed(1)}%'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: goal.progressPercentage.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          goal.isCompleted ? const Color(0xFF4CAF50) : const Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.isCompleted
                            ? 'Goal achieved! 🎉'
                            : 'Deadline: ${DateFormat('MMM dd, yyyy').format(goal.deadline)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: goal.isCompleted ? const Color(0xFF4CAF50) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }

  Widget _buildCategoryReport(TransactionProvider provider) {
    final expensesByCategory = provider.getExpensesByCategory();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Breakdown',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'Expense Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
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
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Category List
        ...expensesByCategory.entries.map((entry) => Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFF44336),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
