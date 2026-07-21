import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:flutter/material.dart';

class ManualEntryCategoryField extends StatelessWidget {
  const ManualEntryCategoryField({
    required this.categories,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<ManualEntryCategory> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: categories.isEmpty ? 'Category: Other' : 'Category',
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: categories
          .map(
            (category) => DropdownMenuItem(
              value: category.id,
              child: Text('${category.emoji}  ${category.name}'),
            ),
          )
          .toList(),
      onChanged: categories.isEmpty ? null : onChanged,
    );
  }
}
