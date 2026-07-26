import 'package:flutter/material.dart';

class CalendarViewToggle extends StatelessWidget {
  const CalendarViewToggle({
    required this.isExpanded,
    required this.onPressed,
    super.key,
  });

  final bool isExpanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 32,
        child: IconButton(
          key: const Key('calendar-view-toggle'),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          tooltip: isExpanded ? 'Show week' : 'Show month',
          icon: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            child: const Icon(Icons.keyboard_arrow_down_rounded, size: 23),
          ),
        ),
      ),
    );
  }
}
