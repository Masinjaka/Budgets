import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction/add_category_pill.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction/category_pill.dart';
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
                  (c) => CategoryPill(
                    category: c,
                    isSelected: selectedCategory?.id == c.id,
                    onTap: () => onCategoryTap(c),
                  ),
                ),
                AddCategoryPill(onAddTap: onAddCategoryTap),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
