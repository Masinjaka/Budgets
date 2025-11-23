import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// A reusable button for actions like add, scan, or filter.
class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isSquare;
  final Color backgroundColor;
  final Color iconColor;

  const ActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isSquare = false,
    this.backgroundColor = const Color(0xFF3A3A3C),
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4.5.h,
      height: 4.5.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        // Use BorderRadius.circular for rounded corners or a circle shape
        borderRadius: BorderRadius.circular(isSquare ? 3.w : 50.w),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}
