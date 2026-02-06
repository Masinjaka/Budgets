import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../utils/error_messages.dart';

enum AppToastType { success, error, info }

void showAppToast(
  BuildContext context,
  String message, {
  AppToastType type = AppToastType.info,
}) {
  final theme = Theme.of(context);
  final color = _toastColor(theme, type);
  final icon = _toastIcon(type, color);

  DelightToastBar(
    autoDismiss: true,
    builder: (context) => ToastCard(
      leading: icon,
      title: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 15.sp,
        ),
      ),
    ),
  ).show(context);
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

Color _toastColor(ThemeData theme, AppToastType type) {
  switch (type) {
    case AppToastType.success:
      return theme.colorScheme.secondary;
    case AppToastType.error:
      return theme.colorScheme.error;
    case AppToastType.info:
      return theme.colorScheme.primary;
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
