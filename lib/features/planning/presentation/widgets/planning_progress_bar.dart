import 'package:flutter/material.dart';

class PlanningProgressBar extends StatelessWidget {
  final double progress;
  final bool useWarningColors;

  const PlanningProgressBar({
    super.key,
    required this.progress,
    this.useWarningColors = false,
  });

  Color _getProgressColor(BuildContext context) {
    if (!useWarningColors) {
      return Theme.of(context).primaryColor;
    }
    if (progress > 0.9) {
      return Colors.red;
    }
    if (progress > 0.7) {
      return Colors.orange;
    }
    return Theme.of(context).primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
          valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(context)),
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}
