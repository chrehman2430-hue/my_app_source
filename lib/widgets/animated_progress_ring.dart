import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? child;
  final Duration animationDuration;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
    this.child,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.showPercentage = false,
    this.percentageStyle,
  });

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ));
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = widget.progressColor ?? Theme.of(context).primaryColor;
    final backgroundColor = widget.backgroundColor ?? 
        Theme.of(context).dividerColor.withOpacity(0.2);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  progress: 1.0,
                  strokeWidth: widget.strokeWidth,
                  color: backgroundColor,
                  isBackground: true,
                ),
              ),
              // Progress ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  progress: _progressAnimation.value,
                  strokeWidth: widget.strokeWidth,
                  color: progressColor,
                  isBackground: false,
                ),
              ),
              // Center content
              if (widget.child != null)
                widget.child!
              else if (widget.showPercentage)
                Text(
                  '${(_progressAnimation.value * 100).round()}%',
                  style: widget.percentageStyle ??
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final bool isBackground;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.isBackground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = isBackground ? StrokeCap.round : StrokeCap.round;

    if (isBackground) {
      // Draw full circle for background
      canvas.drawCircle(center, radius, paint);
    } else {
      // Draw progress arc
      const startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress;

      // Add gradient effect for progress
      if (progress > 0) {
        final rect = Rect.fromCircle(center: center, radius: radius);
        final gradient = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: [
            color.withOpacity(0.3),
            color,
            color,
          ],
          stops: const [0.0, 0.5, 1.0],
        );

        paint.shader = gradient.createShader(rect);
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _ProgressRingPainter &&
        (oldDelegate.progress != progress ||
            oldDelegate.color != color ||
            oldDelegate.strokeWidth != strokeWidth);
  }
}

class SavingsGoalProgressRing extends StatelessWidget {
  final double currentAmount;
  final double targetAmount;
  final String goalName;
  final Color? color;
  final double size;

  const SavingsGoalProgressRing({
    super.key,
    required this.currentAmount,
    required this.targetAmount,
    required this.goalName,
    this.color,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final progress = targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).round();

    return AnimatedProgressRing(
      progress: progress,
      size: size,
      progressColor: color ?? Theme.of(context).primaryColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$percentage%',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            goalName,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class BudgetProgressRing extends StatelessWidget {
  final double spent;
  final double budget;
  final String categoryName;
  final double size;

  const BudgetProgressRing({
    super.key,
    required this.spent,
    required this.budget,
    required this.categoryName,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > budget;
    final percentage = (progress * 100).round();

    Color getProgressColor() {
      if (isOverBudget) return Colors.red;
      if (progress > 0.8) return Colors.orange;
      if (progress > 0.6) return Colors.yellow[700]!;
      return Colors.green;
    }

    return AnimatedProgressRing(
      progress: progress,
      size: size,
      progressColor: getProgressColor(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$percentage%',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: getProgressColor(),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            categoryName,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
