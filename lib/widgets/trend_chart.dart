import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../utils/currency_utils.dart';

class TrendChartData {
  final DateTime date;
  final double income;
  final double expenses;

  TrendChartData({
    required this.date,
    required this.income,
    required this.expenses,
  });

  double get netAmount => income - expenses;
}

class AnimatedTrendChart extends StatefulWidget {
  final List<TrendChartData> data;
  final String title;
  final Duration animationDuration;
  final bool showLegend;
  final bool showGrid;

  const AnimatedTrendChart({
    super.key,
    required this.data,
    this.title = 'Income vs Expenses Trend',
    this.animationDuration = const Duration(milliseconds: 2000),
    this.showLegend = true,
    this.showGrid = true,
  });

  @override
  State<AnimatedTrendChart> createState() => _AnimatedTrendChartState();
}

class _AnimatedTrendChartState extends State<AnimatedTrendChart>
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
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
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
                  return LineChart(
                    _buildLineChartData(),
                  );
                },
              ),
            ),
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
            Icons.trending_up,
            size: 64,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).dividerColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some transactions to see trends',
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
          _buildLegendItem(
            'Income',
            Colors.green,
            Icons.arrow_upward,
          ),
          const SizedBox(width: 24),
          _buildLegendItem(
            'Expenses',
            Colors.red,
            Icons.arrow_downward,
          ),
          const SizedBox(width: 24),
          _buildLegendItem(
            'Net',
            Colors.blue,
            Icons.trending_up,
          ),
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
            shape: BoxShape.circle,
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

  LineChartData _buildLineChartData() {
    final maxY = _getMaxY();
    final minY = _getMinY();

    return LineChartData(
      gridData: FlGridData(
        show: widget.showGrid,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        horizontalInterval: (maxY - minY) / 5,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < widget.data.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MMM dd').format(widget.data[index].date),
                    style: Theme.of(context).textTheme.bodySmall,
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
            interval: (maxY - minY) / 5,
            reservedSize: 60,
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
      minX: 0,
      maxX: (widget.data.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        _buildLineBarData(
          widget.data.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              entry.value.income * _animation.value,
            );
          }).toList(),
          Colors.green,
        ),
        _buildLineBarData(
          widget.data.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              entry.value.expenses * _animation.value,
            );
          }).toList(),
          Colors.red,
        ),
        _buildLineBarData(
          widget.data.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              entry.value.netAmount * _animation.value,
            );
          }).toList(),
          Colors.blue,
        ),
      ],
        lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipPadding: const EdgeInsets.all(8),
          tooltipMargin: 8,
          getTooltipColor: (touchedSpot) => Theme.of(context).cardColor,
          tooltipBorderRadius: BorderRadius.circular(8),
          getTooltipItems: (touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final index = barSpot.x.toInt();
              if (index < 0 || index >= widget.data.length) return null;

              final data = widget.data[index];
              String label;
              Color color;

              switch (barSpot.barIndex) {
                case 0:
                  label =
                      'Income: ${CurrencyUtils.formatCurrencyWithoutSymbol(data.income)}';
                  color = Colors.green;
                  break;
                case 1:
                  label =
                      'Expenses: ${CurrencyUtils.formatCurrencyWithoutSymbol(data.expenses)}';
                  color = Colors.red;
                  break;
                case 2:
                  label =
                      'Net: ${CurrencyUtils.formatCurrencyWithoutSymbol(data.netAmount)}';
                  color = Colors.blue;
                  break;
                default:
                  label = '';
                  color = Colors.grey;
              }

              return LineTooltipItem(
                label,
                TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  LineChartBarData _buildLineBarData(
    List<FlSpot> spots,
    Color color,
  ) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      isStrokeCapRound: true,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.1),
      ),
      gradient: LinearGradient(colors: [color]),
    );
  }

  double _getMaxY() {
    if (widget.data.isEmpty) return 100;

    double max = 0;
    for (final data in widget.data) {
      if (data.income > max) max = data.income;
      if (data.expenses > max) max = data.expenses;
      if (data.netAmount > max) max = data.netAmount;
    }
    return max * 1.1;
  }

  double _getMinY() {
    if (widget.data.isEmpty) return 0;

    double min = 0;
    for (final data in widget.data) {
      if (data.netAmount < min) min = data.netAmount;
    }
    return min < 0 ? min * 1.1 : 0;
  }
}

class CompactTrendChart extends StatelessWidget {
  final List<TrendChartData> data;
  final double height;
  final Color? primaryColor;

  const CompactTrendChart({
    super.key,
    required this.data,
    this.height = 120,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No trend data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).dividerColor,
                ),
          ),
        ),
      );
    }

    final color = primaryColor ?? Theme.of(context).primaryColor;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: _getMinY(),
          maxY: _getMaxY(),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value.netAmount,
                );
              }).toList(),
              isCurved: true,
              isStrokeCapRound: true,
              barWidth: 2,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.1),
              ),
              gradient: LinearGradient(colors: [color]),
            ),
          ],
          lineTouchData: LineTouchData(enabled: false),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    return data.map((d) => d.netAmount).reduce((a, b) => a > b ? a : b) * 1.1;
  }

  double _getMinY() {
    if (data.isEmpty) return 0;
    final min = data.map((d) => d.netAmount).reduce((a, b) => a < b ? a : b);
    return min < 0 ? min * 1.1 : 0;
  }
}
