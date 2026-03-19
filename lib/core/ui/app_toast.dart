import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../utils/error_messages.dart';

enum AppToastType { success, error, info }

void showAppToast(
  BuildContext context,
  String message, {
  AppToastType type = AppToastType.info,
}) {
  final theme = Theme.of(context);
  final bgColor = _toastBgColor(type);
  final fgColor = type == AppToastType.info ? Colors.black : Colors.white;
  final icon = _toastIcon(type, fgColor);

  // Use the root navigator overlay so the toast renders on top of dialogs,
  // and call show() with that root context for immediate display.
  final rootNavigator = Navigator.of(context, rootNavigator: true);

  DelightToastBar(
    autoDismiss: true,
    position: DelightSnackbarPosition.top,
    snackbarDuration: const Duration(milliseconds: 2200),
    animationDuration: const Duration(milliseconds: 300),
    builder: (_) => ToastCard(
      color: bgColor,
      leading: icon,
      title: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w600,
          fontSize: 15.sp,
        ),
      ),
    ),
  ).show(rootNavigator.context);

  // DelightToastBar defers overlay insertion to addPostFrameCallback.
  // Force a frame so the toast appears immediately even without a setState.
  SchedulerBinding.instance.scheduleFrame();
}

void showSuccessToast(BuildContext context, String message) {
  showAppToast(context, message, type: AppToastType.success);
}

void showInfoToast(BuildContext context, String message) {
  showAppToast(context, message, type: AppToastType.info);
}

void showErrorToast(BuildContext context, Object error) {
  showAppToast(
    context,
    friendlyErrorMessage(error),
    type: AppToastType.error,
  );
}

Color _toastBgColor(AppToastType type) {
  switch (type) {
    case AppToastType.success:
      return const Color(0xFF558564);
    case AppToastType.error:
      return const Color(0xFFDB5A42);
    case AppToastType.info:
      return const Color(0xFFFA9500);
  }
}

Icon _toastIcon(AppToastType type, Color color) {
  switch (type) {
    case AppToastType.success:
      return Icon(Icons.check_circle, color: color, size: 18.sp);
    case AppToastType.error:
      return Icon(Icons.error, color: color, size: 18.sp);
    case AppToastType.info:
      return Icon(Icons.info, color: color, size: 18.sp);
  }
}
