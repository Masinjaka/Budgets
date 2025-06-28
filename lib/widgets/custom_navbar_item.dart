import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomNavItem extends StatefulWidget {
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
  State<CustomNavItem> createState() => _CustomNavItemState();
}

class _CustomNavItemState extends State<CustomNavItem> {
  @override
  Widget build(BuildContext context) {
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
                color: widget.isActive? Colors.black:Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(20.w),
              color: widget.isActive?const Color(0xffDDFFBC):Colors.transparent,
            ),
            child: Icon(widget.icon),
          ),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
