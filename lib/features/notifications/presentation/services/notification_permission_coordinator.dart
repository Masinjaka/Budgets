import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/features/notifications/presentation/services/notification_permission_service.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionCoordinator {
  const NotificationPermissionCoordinator._();

  static Future<bool> ensure(BuildContext context) async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    if (!context.mounted) return false;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return _openSettings(context);
    }
    final allowed = await showAnimatedDialog<bool>(
      context: context,
      builder: (dialogContext) => PermissionRequestDialog(
        title: context.l10n.allowNotifications,
        message: context.l10n.notificationPermissionMessage,
        allowText: context.l10n.allow,
        denyText: context.l10n.cancel,
        onAllow: () => Navigator.of(dialogContext).pop(true),
        onDeny: () => Navigator.of(dialogContext).pop(false),
      ),
    );
    if (allowed != true || !context.mounted) return false;
    return NotificationPermissionService().request();
  }

  static Future<bool> _openSettings(BuildContext context) async {
    final opened = await showAnimatedDialog<bool>(
      context: context,
      builder: (dialogContext) => PermissionRequestDialog(
        title: context.l10n.notificationsBlocked,
        message: context.l10n.notificationsBlockedMessage,
        allowText: context.l10n.openSettings,
        denyText: context.l10n.cancel,
        onAllow: () async {
          await openAppSettings();
          if (dialogContext.mounted) Navigator.of(dialogContext).pop(true);
        },
        onDeny: () => Navigator.of(dialogContext).pop(false),
      ),
    );
    if (opened != true) return false;
    return (await Permission.notification.status).isGranted;
  }
}
