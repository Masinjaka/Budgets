import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomGreetingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String greeting;
  final VoidCallback? onNotificationPressed;

  const CustomGreetingAppBar({
    super.key,
    required this.greeting,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      toolbarHeight: 8.h,
      elevation: 0,
      titleSpacing: 2.5.w,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontSize: 18.8.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 0.2.h),
            Container(
              height: 0.4.h,
              width: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.textDark,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_outlined,
            size: 21.sp,
          ),
          onPressed: onNotificationPressed ?? () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(8.h);
}
