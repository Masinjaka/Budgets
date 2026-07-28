import 'package:budgets/core/ui/app_control_metrics.dart';
import 'package:flutter/material.dart';

class PersistentTextFieldSuffix extends StatelessWidget {
  const PersistentTextFieldSuffix({
    required this.text,
    required this.style,
    super.key,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppControlMetrics.horizontalPadding,
      ),
      child: Center(
        widthFactor: 1,
        child: Text(text, style: style),
      ),
    );
  }
}
