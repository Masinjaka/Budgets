import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.onTap,
  });

  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(0.8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.w),
              color: Theme.of(context).cardColor,
            ),
            child: Icon(
              Icons.arrow_right_alt_sharp,
              size: 18.sp,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        )
      ],
    );
  }
}
