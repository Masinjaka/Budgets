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
        onPressed: widget.onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            widget.backgroundColor ?? AppTheme.primaryGreen,
          ),
          elevation: const WidgetStatePropertyAll(0),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: widget.borderColor ?? Colors.black,
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
                child: const CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : Text(
                widget.text,
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w900,
                  color: widget.foregroundColor ?? Colors.black,
                ),
              ),
      ),
    );
  }
}
