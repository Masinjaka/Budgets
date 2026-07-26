import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:budgets/features/envelopes/domain/models/envelope_category.dart';
import 'package:budgets/features/home/presentation/widgets/manual_entry_category_field.dart';
import 'package:flutter/material.dart';

class EnvelopeCategoryField extends StatelessWidget {
  const EnvelopeCategoryField({
    required this.categories,
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
  });

  final List<EnvelopeCategory> categories;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ManualEntryCategoryField(
      categories: categories
          .map(
            (category) => ManualEntryCategory(
              id: category.id,
              name: category.name,
              emoji: category.emoji,
              transactionType: 'expense',
              colorHex: category.color,
            ),
          )
          .toList(growable: false),
      value: value,
      onChanged: onChanged,
      label: label,
    );
  }
}
