import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Supprimer',
  String cancelText = 'Annuler',
}) async {
  final confirmed = await showAnimatedDialog<bool>(
    context: context,
    builder: (dialogContext) => PermissionRequestDialog(
      title: title,
      message: message,
      allowText: confirmText,
      denyText: cancelText,
      backgroundColor: Colors.red,
      onAllow: () => Navigator.of(dialogContext).pop(true),
      onDeny: () => Navigator.of(dialogContext).pop(false),
    ),
  );

  return confirmed ?? false;
}
