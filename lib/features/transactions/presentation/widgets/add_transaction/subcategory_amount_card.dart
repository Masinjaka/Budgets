import 'package:budgets/widgets/animated_amount_field.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SubcategoryAmountCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final void Function(int) onRemove;
  final Future<void> Function(Map<String, dynamic>, int) onSubcategoryTap;

  const SubcategoryAmountCard({
    super.key,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
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
