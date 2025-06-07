import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomButton extends StatefulWidget {
  const CustomButton(
      {super.key,
      required this.text,
      this.width,
      required this.onPressed,
      this.isLoading});

  final String text;
  final double? width;
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
      height: 5.5.h,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll(
            Color(0xffDDFFBC),
          ),
          elevation: const WidgetStatePropertyAll(0),
          side: const WidgetStatePropertyAll(
            BorderSide(
              color: Colors.black,
            ),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.w),
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
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}
