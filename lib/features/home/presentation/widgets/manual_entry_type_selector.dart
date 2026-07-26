import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';

class ManualEntryTypeSelector extends StatelessWidget {
  const ManualEntryTypeSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _option(context, 'expense', 'Expense'),
          _option(context, 'income', 'Income'),
        ],
      ),
    );
  }

  Widget _option(BuildContext context, String type, String label) {
    final selected = value == type;
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        key: Key('manual-$type-option'),
        onTap: () => onChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colors.inverseSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? colors.onInverseSurface : colors.onSurface,
              fontSize: AppTypography.body,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
