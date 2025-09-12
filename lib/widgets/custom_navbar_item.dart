import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomNavItem extends ConsumerStatefulWidget {
  const CustomNavItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    required this.isActive,
  });
  final IconData icon;
  final String title;
  final void Function()? onTap;
  final bool isActive;
  @override
  ConsumerState<CustomNavItem> createState() => _CustomNavItemState();
}

class _CustomNavItemState extends ConsumerState<CustomNavItem> {

  @override
  Widget build(BuildContext context) {
    // Always use dark theme colors
    Color textColor = AppTheme.textDark;
    Color backgroundColor = AppTheme.secondaryDark;

    return InkWell(
      onTap: widget.onTap,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w,vertical: 1.w),
            margin: EdgeInsets.only(bottom: 0.5.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.isActive ? backgroundColor :Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(20.w),
              color: widget.isActive  ? backgroundColor: Colors.transparent,
            ),
            child: Icon(widget.icon),
          ),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 14.sp,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
