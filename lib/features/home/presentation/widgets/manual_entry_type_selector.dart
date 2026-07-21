import 'package:budgets/core/theme.dart';
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _option('expense', 'Expense'),
          _option('income', 'Income'),
        ],
      ),
    );
  }

  Widget _option(String type, String label) {
    final selected = value == type;
    return Expanded(
      child: GestureDetector(
        key: Key('manual-$type-option'),
        onTap: () => onChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? AppTheme.interactiveTextColor
                  : const Color(0xFF555555),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
