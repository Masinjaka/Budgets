import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionFilterDateField extends StatelessWidget {
  final String? hint;
  final TextEditingController controller;
  final VoidCallback onTap;

  const TransactionFilterDateField({
    super.key,
    required this.hint,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      controller: controller,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
          borderSide: const BorderSide(color: Colors.transparent, width: 1.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
          borderSide: const BorderSide(color: Colors.black, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 252, 154, 147),
            width: 1.8,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
          borderSide: const BorderSide(color: Colors.black, width: 1.8),
        ),
        hintText: hint,
        suffixIcon: Icon(
          Icons.calendar_month_outlined,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
