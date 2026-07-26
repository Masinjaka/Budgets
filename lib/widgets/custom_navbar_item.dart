import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    Color? textColor = Theme.of(context).textTheme.bodyLarge?.color;
    Color backgroundColor = Theme.of(context).cardColor;

    return InkWell(
      onTap: widget.onTap,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            margin: EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.isActive ? backgroundColor : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(80),
              color: widget.isActive ? backgroundColor : Colors.transparent,
            ),
            child: Icon(
              widget.icon,
              color: textColor,
            ),
          ),
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
