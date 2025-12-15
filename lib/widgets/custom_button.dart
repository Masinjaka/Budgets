import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomButton extends StatefulWidget {
  const CustomButton(
      {super.key,
      required this.text,
      this.width,
      this.height,
      this.backgroundColor,
      required this.onPressed,
      this.foregroundColor,
      this.borderColor,
      this.isLoading});

  final String text;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final void Function()? onPressed;
  final bool? isLoading;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 5.5.h,
      child: ElevatedButton(
        onPressed: widget.onPressed != null
            ? () {
                HapticFeedback.mediumImpact();
                widget.onPressed!();
              }
            : null,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            widget.backgroundColor ?? AppTheme.primaryGreen,
          ),
          elevation: const WidgetStatePropertyAll(0),
          side: WidgetStatePropertyAll(
            widget.backgroundColor == AppTheme.primaryGreen ||
                    widget.backgroundColor == Colors.red
                ? BorderSide.none
                : BorderSide(
                    color: widget.borderColor ??
                        Theme.of(context).colorScheme.onPrimary,
                  ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.w),
            ),
          ),
        ),
        child: widget.isLoading != null && widget.isLoading!
            ? SizedBox(
                height: 6.w,
                width: 6.w,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : Text(
                widget.text,
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w900,
                  color: widget.foregroundColor ??
                      Theme.of(context).colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }
}
