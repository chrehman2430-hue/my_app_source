import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/budget.dart';
import '../utils/currency_utils.dart';

class BudgetComparisonChart extends StatefulWidget {
  final List<Budget> budgets;
  final String title;
  final Duration animationDuration;
  final bool showLegend;

  const BudgetComparisonChart({
    super.key,
    required this.budgets,
    this.title = 'Budget vs Actual Spending',
    this.animationDuration = const Duration(milliseconds: 1500),
    this.showLegend = true,
  });

  @override
  State<BudgetComparisonChart> createState() => _BudgetComparisonChartState();
}

class _BudgetComparisonChartState extends State<BudgetComparisonChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.budgets.isEmpty) {
      return _buildEmptyState();
    }

    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            if (widget.title.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
            if (widget.showLegend) _buildLegend(),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return BarChart(
                    _buildBarChartData(),
                    swapAnimationDuration: const Duration(milliseconds: 250),
                  );
                },
              ),
            ),
            _buildBudgetSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 64,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No budget data available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).dividerColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up budgets to see comparisons',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).dividerColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('Budget', Colors.blue, Icons.account_balance_wallet),
          const SizedBox(width: 24),
          _buildLegendItem('Actual', Colors.orange, Icons.shopping_cart),
          const SizedBox(width: 24),
          _buildLegendItem('Over Budget', Colors.red, Icons.warning),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildBudgetSummary() {
    final totalBudget =
        widget.budgets.fold(0.0, (sum, budget) => sum + budget.monthlyLimit);
    final totalSpent =
        widget.budgets.fold(0.0, (sum, budget) => sum + budget.currentSpent);
    final overBudgetCount =
        widget.budgets.where((budget) => budget.isOverBudget).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Budget',
              CurrencyUtils.formatCurrencyWithoutSymbol(totalBudget),
              Colors.blue,
              Icons.account_balance_wallet,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total Spent',
              CurrencyUtils.formatCurrencyWithoutSymbol(totalSpent),
              Colors.orange,
              Icons.shopping_cart,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Over Budget',
              '$overBudgetCount items',
              Colors.red,
              Icons.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  BarChartData _buildBarChartData() {
    final maxY = _getMaxY();

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final budget = widget.budgets[group.x.toInt()];
            String label = '';

            if (rodIndex == 0) {
              label =
                  'Budget: ${CurrencyUtils.formatCurrencyWithoutSymbol(budget.monthlyLimit)}';
            } else {
              label =
                  'Spent: ${CurrencyUtils.formatCurrencyWithoutSymbol(budget.currentSpent)}';
            }

            return BarTooltipItem(
              label,
              TextStyle(
                color: rod.color ?? Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < widget.budgets.length) {
                final budget = widget.budgets[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    budget.categoryName.length > 8
                        ? '${budget.categoryName.substring(0, 8)}...'
                        : budget.categoryName,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            interval: maxY / 5,
            getTitlesWidget: (value, meta) {
              return Text(
                CurrencyUtils.formatCompactCurrency(value),
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      barGroups: widget.budgets.asMap().entries.map((entry) {
        final index = entry.key;
        final budget = entry.value;

        return BarChartGroupData(
          x: index,
          barRods: [
            // Budget bar
            BarChartRodData(
              toY: budget.monthlyLimit * _animation.value,
              color: Colors.blue,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            // Actual spending bar
            BarChartRodData(
              toY: budget.currentSpent * _animation.value,
              color: budget.isOverBudget ? Colors.red : Colors.orange,
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
          barsSpace: 4,
        );
      }).toList(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
    );
  }

  double _getMaxY() {
    if (widget.budgets.isEmpty) return 100;

    double max = 0;
    for (final budget in widget.budgets) {
      if (budget.monthlyLimit > max) max = budget.monthlyLimit;
      if (budget.currentSpent > max) max = budget.currentSpent;
    }
    return max * 1.2; // Add 20% padding
  }
}

class CompactBudgetChart extends StatelessWidget {
  final List<Budget> budgets;
  final double height;

  const CompactBudgetChart({
    super.key,
    required this.budgets,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No budget data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).dividerColor,
                ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barGroups: budgets.asMap().entries.map((entry) {
            final index = entry.key;
            final budget = entry.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: budget.monthlyLimit,
                  color: Colors.blue.withValues(alpha: 0.3),
                  width: 8,
                ),
                BarChartRodData(
                  toY: budget.currentSpent,
                  color: budget.isOverBudget ? Colors.red : Colors.orange,
                  width: 8,
                ),
              ],
              barsSpace: 2,
            );
          }).toList(),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (budgets.isEmpty) return 100;

    double max = 0;
    for (final budget in budgets) {
      if (budget.monthlyLimit > max) max = budget.monthlyLimit;
      if (budget.currentSpent > max) max = budget.currentSpent;
    }
    return max * 1.1;
  }
}
