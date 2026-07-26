import 'package:flutter/material.dart';

class AddCategoryPill extends StatelessWidget {
  final Future<void> Function(BuildContext) onAddTap;

  const AddCategoryPill({
    super.key,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200);
    return GestureDetector(
      onTap: () => onAddTap(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: textColor),
            SizedBox(width: 4),
            Text(
              'Ajouter une catégorie',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
