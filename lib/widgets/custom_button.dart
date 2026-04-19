import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomButton extends StatefulWidget {
  const CustomButton(
      {super.key,
      required this.text,
      this.width,
      this.height,
      this.backgroundColor,
      this.borderColor,
      this.icon,
      this.iconColor,
      this.isSquare = false,
      this.borderRadius,
      required this.onPressed,
      this.isLoading});

  const CustomButton.icon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.width,
    this.height,
    this.backgroundColor,
    this.iconColor,
    this.isSquare = false,
    this.borderColor,
    this.borderRadius,
    this.isLoading,
  }) : text = null;

  static const Color buttonTextColor = Colors.black;

  final String? text;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? icon;
  final Color? iconColor;
  final bool isSquare;
  final BorderRadius? borderRadius;
  final void Function()? onPressed;
  final bool? isLoading;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedBackgroundColor = widget.backgroundColor ?? AppTheme.primaryGreen;
    final isOutlinedStyle =
        resolvedBackgroundColor == theme.cardColor ||
            resolvedBackgroundColor == Colors.transparent;
    final themedOutlineColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final contentColor =
        isOutlinedStyle ? themedOutlineColor : CustomButton.buttonTextColor;

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 5.5.h,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            resolvedBackgroundColor,
          ),
          foregroundColor: WidgetStatePropertyAll(contentColor),
          elevation: const WidgetStatePropertyAll(0),
          side: WidgetStatePropertyAll(
            resolvedBackgroundColor == AppTheme.primaryGreen ||
                    resolvedBackgroundColor == Colors.red
                ? BorderSide.none
                : BorderSide(
                    color: widget.borderColor ??
                        (isOutlinedStyle
                            ? themedOutlineColor
                            : theme.colorScheme.onPrimary),
                  ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: widget.borderRadius ??
                  BorderRadius.circular(widget.isSquare ? 3.w : 50.w),
            ),
          ),
        ),
        child: widget.isLoading != null && widget.isLoading!
            ? SizedBox(
                height: 6.w,
                width: 6.w,
                child: CircularProgressIndicator(
                  color: contentColor,
                ),
              )
            : _buildChild(contentColor),
      ),
    );
  }

  Widget _buildChild(Color contentColor) {
    final icon = widget.icon;
    final text = widget.text;

    if (icon != null && (text == null || text.isEmpty)) {
      return Icon(
        icon,
        color: widget.iconColor ?? contentColor,
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: widget.iconColor ?? contentColor,
          ),
          SizedBox(width: 2.w),
          Text(
            text!,
            style: TextStyle(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w900,
              color: contentColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text ?? '',
      style: TextStyle(
        fontSize: 15.5.sp,
        fontWeight: FontWeight.w900,
        color: contentColor,
      ),
    );
  }
}
