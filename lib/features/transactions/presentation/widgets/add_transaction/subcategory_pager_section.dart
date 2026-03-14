import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/widgets/animated_amount_field.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SubcategoryPagerSection extends StatelessWidget {
  final List<Map<String, dynamic>> subcategoryAmounts;
  final PageController pageController;
  final Set<int> removingIndices;
  final int? newlyAddedIndex;
  final void Function(int) onRemove;
  final VoidCallback onAdd;
  final Future<void> Function(Map<String, dynamic>, int) onSubcategoryTap;

  const SubcategoryPagerSection({
    super.key,
    required this.subcategoryAmounts,
    required this.pageController,
    required this.removingIndices,
    required this.newlyAddedIndex,
    required this.onRemove,
    required this.onAdd,
    required this.onSubcategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20.h,
      child: PageView.builder(
        controller: pageController,
        padEnds: true,
        itemCount: subcategoryAmounts.length + 1,
        itemBuilder: (context, index) {
          if (index == subcategoryAmounts.length) {
            return _AddSubcategoryCard(onAdd: onAdd);
          }
          final isRemoving = removingIndices.contains(index);
          final isNewlyAdded = newlyAddedIndex == index;

          Widget card = _SubcategoryAmountCard(
            item: subcategoryAmounts[index],
            index: index,
            onRemove: onRemove,
            onSubcategoryTap: onSubcategoryTap,
          );

          if (isNewlyAdded) {
            card = TweenAnimationBuilder<Offset>(
              tween: Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, offset, child) =>
                  FractionalTranslation(translation: offset, child: child),
              child: card,
            );
          }

          return AnimatedScale(
            scale: isRemoving ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: isRemoving ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: card,
            ),
          );
        },
      ),
    );
  }
}

class _SubcategoryAmountCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final void Function(int) onRemove;
  final Future<void> Function(Map<String, dynamic>, int) onSubcategoryTap;

  const _SubcategoryAmountCard({
    required this.item,
    required this.index,
    required this.onRemove,
    required this.onSubcategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final amountController = item['amountController'] as TextEditingController;
    final subcategoryName = item['subcategoryName'] as String? ?? '';
    return Container(
      margin: EdgeInsets.only(right: 3.w),
      height: 20.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSubcategoryAmountField(
                    controller: amountController,
                    hint: '0.00',
                    fontSize: 25.sp,
                    fillColor: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  SizedBox(height: 1.h),
                  GestureDetector(
                    onTap: () => onSubcategoryTap(item, index),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceDim,
                        borderRadius: BorderRadius.circular(5.w),
                      ),
                      child: Text(
                        subcategoryName.isNotEmpty
                            ? subcategoryName
                            : 'Choisir une sous-catégorie',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: subcategoryName.isNotEmpty
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: subcategoryName.isNotEmpty
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 1.h,
            right: 1.h,
            child: GestureDetector(
              onTap: () => onRemove(index),
              child: Container(
                height: 3.h,
                width: 3.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceDim,
                ),
                child: const Center(child: Icon(Icons.remove)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddSubcategoryCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _AddSubcategoryCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        margin: EdgeInsets.only(right: 3.w),
        height: 20.h,
        width: 25.w,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 24.sp,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}

/// Reusable subcategory amount field with animation (used in both dialog and page)
class SubcategoryAmountCardWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final List<Subcategory> subcategories;
  final String? selectedCategoryId;
  final void Function(int) onRemove;
  final void Function(Map<String, dynamic>, Subcategory) onSubcategorySelected;
  final bool enabled;

  const SubcategoryAmountCardWidget({
    super.key,
    required this.item,
    required this.index,
    required this.subcategories,
    required this.selectedCategoryId,
    required this.onRemove,
    required this.onSubcategorySelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return _SubcategoryAmountCard(
      item: item,
      index: index,
      onRemove: onRemove,
      onSubcategoryTap: (item, index) async => onSubcategorySelected(item, item['subcategory']),
    );
  }
}
