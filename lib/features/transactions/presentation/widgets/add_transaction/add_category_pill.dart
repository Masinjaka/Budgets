import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
