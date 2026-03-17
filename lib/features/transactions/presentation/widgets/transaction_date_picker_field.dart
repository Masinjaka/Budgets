import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionDatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final bool isReadOnly;
  final void Function(DateTime) onDateSelected;

  const TransactionDatePickerField({
    super.key,
    required this.selectedDate,
    required this.isReadOnly,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isReadOnly
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Date',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat.yMMMd('fr_FR').format(selectedDate!)
                      : 'Sélectionner une date',
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                  size: 18.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
