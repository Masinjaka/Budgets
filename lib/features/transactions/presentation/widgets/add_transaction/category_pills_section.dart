import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CategoryPillsSection extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final bool isPerSubcategory;
  final void Function(Category) onCategoryTap;
  final Future<void> Function(BuildContext) onAddCategoryTap;

  const CategoryPillsSection({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.isPerSubcategory,
    required this.onCategoryTap,
    required this.onAddCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Catégorie${isPerSubcategory ? " principale" : ""}',
          textAlign: TextAlign.left,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5.sp),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 5.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.h),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                ...categories.map(
                  (c) => _CategoryPill(
                    category: c,
                    isSelected: selectedCategory?.id == c.id,
                    onTap: () => onCategoryTap(c),
                  ),
                ),
                _AddCategoryPill(onAddTap: onAddCategoryTap),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 2.w),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.inverseSurface
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.emoji ?? '📁', style: TextStyle(fontSize: 14.sp)),
            SizedBox(width: 1.5.w),
            Text(
              category.name ?? '',
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onInverseSurface
                    : Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha(200),
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCategoryPill extends StatelessWidget {
  final Future<void> Function(BuildContext) onAddTap;

  const _AddCategoryPill({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200);
    return GestureDetector(
      onTap: () => onAddTap(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14.sp, color: textColor),
            SizedBox(width: 1.w),
            Text(
              'Ajouter une catégorie',
              style: TextStyle(
                  color: textColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
