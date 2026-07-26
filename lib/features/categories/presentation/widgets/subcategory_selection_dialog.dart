import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/features/categories/presentation/widgets/add_subcategory_dialog.dart';
import 'package:flutter/material.dart';

/// A dialog for selecting a subcategory from a list of pills.
/// Shows only an "Add subcategory" button if no subcategories exist.
class SubcategorySelectionDialog extends StatelessWidget {
  final List<Subcategory> subcategories;
  final String? categoryId;
  final Subcategory? selectedSubcategory;

  const SubcategorySelectionDialog({
    super.key,
    required this.subcategories,
    this.categoryId,
    this.selectedSubcategory,
  });

  /// Shows the subcategory selection dialog.
  /// Returns the selected [Subcategory] or null if dismissed.
  static Future<Subcategory?> show(
    BuildContext context, {
    required List<Subcategory> subcategories,
    String? categoryId,
    Subcategory? selectedSubcategory,
  }) {
    return showAnimatedDialog<Subcategory?>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SubcategorySelectionDialog(
        subcategories: subcategories,
        categoryId: categoryId,
        selectedSubcategory: selectedSubcategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Choisir une sous-catégorie',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Subcategory pills or empty state
            if (subcategories.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subcategories
                    .map((sub) => _buildSubcategoryPill(context, sub))
                    .toList(),
              ),
              SizedBox(height: 16),
            ],

            // Add subcategory button
            _buildAddSubcategoryButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSubcategoryPill(BuildContext context, Subcategory subcategory) {
    final isSelected = selectedSubcategory?.id == subcategory.id ||
        selectedSubcategory?.name == subcategory.name;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(subcategory),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9.6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.inverseSurface
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          subcategory.name ?? '',
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onInverseSurface
                : Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAddSubcategoryButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Open add subcategory dialog
        final newSubcategory = await AddSubcategoryDialog.show(
          context,
          categoryId: categoryId,
        );

        if (newSubcategory != null && context.mounted) {
          // Return the newly created subcategory
          Navigator.of(context).pop(newSubcategory);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withAlpha(100),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            SizedBox(width: 8),
            Text(
              'Ajouter une sous-catégorie',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
