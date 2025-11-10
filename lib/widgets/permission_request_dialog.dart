import 'package:budgets/core/theme.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PermissionRequestDialog extends StatelessWidget {
  final String title;
  final String message;
  final String allowText;
  final String denyText;
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const PermissionRequestDialog({
    super.key,
    this.title = 'Autorisation requise',
    required this.message,
    this.allowText = 'Autoriser',
    this.denyText = 'Refuser',
    required this.onAllow,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
      backgroundColor: AppTheme.backgroundDark,
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.5.h),
            Text(
              message,
              style: TextStyle(fontSize: 15.sp),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: denyText,
                  onPressed: onDeny,
                  backgroundColor: AppTheme.secondaryDark,
                  width: 15.h,
                  foregroundColor: Colors.white,
                  borderColor: Colors.transparent,
                ),
                SizedBox(width: 2.w),
                CustomButton(
                  text: allowText,
                  onPressed: onAllow,
                  width: 15.h,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
