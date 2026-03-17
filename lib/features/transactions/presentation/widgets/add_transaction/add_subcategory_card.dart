import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AddSubcategoryCard extends StatelessWidget {
  final VoidCallback onAdd;

  const AddSubcategoryCard({
    super.key,
    required this.onAdd,
  });

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
