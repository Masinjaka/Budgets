import 'package:budgets/core/theme.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class ManualEntrySheetActions extends StatelessWidget {
  const ManualEntrySheetActions({
    required this.isEditing,
    required this.onSave,
    required this.onDelete,
    super.key,
  });

  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          key: const Key('save-manual-entry-button'),
          text: isEditing ? 'Save changes' : 'Add entry',
          onPressed: onSave,
        ),
        if (isEditing) ...[
          const SizedBox(height: 9),
          CustomButton.outlined(
            key: const Key('delete-manual-entry-button'),
            text: 'Delete entry',
            onPressed: onDelete,
            foregroundColor: AppTheme.dangerColor,
            borderColor: AppTheme.dangerColor,
          ),
        ],
      ],
    );
  }
}
