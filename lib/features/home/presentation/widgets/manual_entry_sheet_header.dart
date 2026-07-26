import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManualEntrySheetHeader extends StatelessWidget {
  const ManualEntrySheetHeader({
    required this.date,
    required this.isEditing,
    super.key,
  });

  final DateTime date;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEditing ? 'Edit entry' : 'Add an entry',
          style: const TextStyle(
            fontSize: AppTypography.headline,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          DateFormat('EEEE, d MMMM').format(date),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: AppTypography.supporting,
          ),
        ),
      ],
    );
  }
}
