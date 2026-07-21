import 'package:flutter/material.dart';

import '../utils/error_messages.dart';
import 'app_toast_overlay.dart';

enum AppToastType { success, error, info }

OverlayEntry? _activeToast;

void showAppToast(
  BuildContext context,
  String message, {
  AppToastType type = AppToastType.info,
}) {
  final overlay = Navigator.of(context, rootNavigator: true).overlay;
  if (overlay == null) return;
  _activeToast?.remove();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => AppToastOverlay(
      message: message,
      color: _toastColor(type),
      icon: _toastIcon(type),
      onDisposed: () {
        if (_activeToast == entry) _activeToast = null;
      },
      onDismissed: () {
        if (_activeToast != entry) return;
        entry.remove();
        _activeToast = null;
      },
    ),
  );
  _activeToast = entry;
  overlay.insert(entry);
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

Color _toastColor(AppToastType type) => switch (type) {
      AppToastType.success => const Color(0xFF558564),
      AppToastType.error => const Color(0xFFDB5A42),
      AppToastType.info => const Color(0xFFFA9500),
    };

IconData _toastIcon(AppToastType type) => switch (type) {
      AppToastType.success => Icons.check_circle_outline_rounded,
      AppToastType.error => Icons.error_outline_rounded,
      AppToastType.info => Icons.info_outline_rounded,
    };
