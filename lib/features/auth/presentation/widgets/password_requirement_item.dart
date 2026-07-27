import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';

class PasswordRequirementItem extends StatelessWidget {
  const PasswordRequirementItem({
    required this.label,
    required this.isSatisfied,
    required this.requirementKey,
    super.key,
  });

  final String label;
  final bool isSatisfied;
  final Key requirementKey;

  @override
  Widget build(BuildContext context) {
    final color = isSatisfied
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      key: requirementKey,
      checked: isSatisfied,
      label: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: isSatisfied ? color : Colors.transparent,
                border: Border.all(color: color, width: 1.25),
                shape: BoxShape.circle,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isSatisfied
                    ? Icon(
                        Icons.check_rounded,
                        key: const ValueKey('checked'),
                        size: 10,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : const SizedBox.shrink(key: ValueKey('unchecked')),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: color,
                  fontSize: AppTypography.caption,
                  fontWeight: isSatisfied ? FontWeight.w700 : FontWeight.w600,
                ),
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
