import 'dart:async';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart' show DatePickerDateOrder;
import 'package:flutter/material.dart';

class AppWheelPicker {
  const AppWheelPicker._();

  static Future<DateTime?> date(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String title = 'Select a date',
  }) {
    final result = Completer<DateTime?>();
    late final BottomPicker<DateTime> picker;
    picker = BottomPicker<DateTime>.date(
      initialDateTime: _clamp(initialDate, firstDate, lastDate),
      minDateTime: firstDate,
      maxDateTime: lastDate,
      dateOrder: DatePickerDateOrder.dmy,
      dismissable: true,
      useSafeArea: true,
      height: 360,
      itemExtent: 44,
      backgroundColor: _background(context),
      pickerTextStyle: _pickerTextStyle(context),
      headerBuilder: (_) => _header(context, title, () {
        _complete(result, null);
        picker.dismiss();
      }),
      buttonBuilder: (instance, _) => _doneButton(() {
        _complete(result, instance.currentValue as DateTime?);
        instance.dismiss();
      }),
      onDismiss: (_) => _complete(result, null),
    );
    picker.show(context);
    return result.future;
  }

  static Future<DateTime?> monthYear(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String title = 'Select a month',
  }) {
    final result = Completer<DateTime?>();
    late final BottomPicker<DateTime> picker;
    picker = BottomPicker<DateTime>.monthYear(
      initialDateTime: _clamp(initialDate, firstDate, lastDate),
      minDateTime: firstDate,
      maxDateTime: lastDate,
      dismissable: true,
      useSafeArea: true,
      height: 340,
      itemExtent: 44,
      backgroundColor: _background(context),
      pickerTextStyle: _pickerTextStyle(context),
      headerBuilder: (_) => _header(context, title, () {
        _complete(result, null);
        picker.dismiss();
      }),
      buttonBuilder: (instance, _) => _doneButton(() {
        _complete(result, instance.currentValue as DateTime?);
        instance.dismiss();
      }),
      onDismiss: (_) => _complete(result, null),
    );
    picker.show(context);
    return result.future;
  }

  static Future<TimeOfDay?> time(
    BuildContext context, {
    required TimeOfDay initialTime,
    String title = 'Select a time',
  }) {
    final result = Completer<TimeOfDay?>();
    late final BottomPicker<DateTime> picker;
    picker = BottomPicker<DateTime>.time(
      initialTime: Time(
        hours: initialTime.hour,
        minutes: initialTime.minute,
      ),
      minTime: Time(),
      maxTime: Time(hours: 23, minutes: 59),
      use24hFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      showTimeSeparator: true,
      dismissable: true,
      useSafeArea: true,
      height: 340,
      itemExtent: 44,
      backgroundColor: _background(context),
      pickerTextStyle: _pickerTextStyle(context),
      headerBuilder: (_) => _header(context, title, () {
        _complete(result, null);
        picker.dismiss();
      }),
      buttonBuilder: (instance, _) => _doneButton(() {
        final value = instance.currentValue as DateTime?;
        _complete(
          result,
          value == null ? null : TimeOfDay.fromDateTime(value),
        );
        instance.dismiss();
      }),
      onDismiss: (_) => _complete(result, null),
    );
    picker.show(context);
    return result.future;
  }

  static TextStyle _pickerTextStyle(BuildContext context) => TextStyle(
        color: _foreground(context),
        fontSize: 18,
        fontWeight: FontWeight.w500,
      );

  static Widget _header(
    BuildContext context,
    String title,
    VoidCallback onClose,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            key: const Key('app-wheel-picker-title'),
            style: TextStyle(
              color: _foreground(context),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          key: const Key('app-wheel-picker-close'),
          onPressed: onClose,
          color: _foreground(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  static Widget _doneButton(VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: CustomButton(
        key: const Key('app-wheel-picker-done'),
        text: 'Done',
        onPressed: onPressed,
      ),
    );
  }

  static Color _background(BuildContext context) => Theme.of(context).cardColor;

  static Color _foreground(BuildContext context) =>
      Theme.of(context).colorScheme.inverseSurface;

  static DateTime _clamp(DateTime value, DateTime min, DateTime max) {
    if (value.isBefore(min)) return min;
    if (value.isAfter(max)) return max;
    return value;
  }

  static void _complete<T>(Completer<T> completer, T value) {
    if (!completer.isCompleted) completer.complete(value);
  }
}
