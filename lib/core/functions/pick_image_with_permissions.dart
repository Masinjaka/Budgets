import 'dart:io';

import 'package:budgets/features/auth/presentation/widgets/file_picker_option.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Pick an image from camera or gallery with proper permission handling.
/// Returns the picked image as a File, or null if the user cancels or permissions are denied.
/// [description] - Custom message to show in the permission dialog.
Future<File?> pickImageWithPermissions(
  BuildContext context, {
  String? description,
}) async {
  if (!context.mounted) return null;
  final permissionMessage = description ?? context.l10n.mediaPermissionMessage;

  // Determine required media permission based on platform/version
  Permission mediaPermission;
  if (Platform.isIOS) {
    mediaPermission = Permission.photos;
  } else {
    // On Android 13+ photos/videos separated; permission_handler maps to photos. Use storage for older versions.
    mediaPermission = Permission.photos;
  }

  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Theme.of(context).cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Text(
              context.l10n.chooseSource,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FileOption(
                  icon: Icons.photo_library,
                  title: context.l10n.fromGallery,
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                FileOption(
                  icon: Icons.photo_camera,
                  title: context.l10n.takePhoto,
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      );
    },
  );

  if (source == null) return null;

  final needsCamera = source == ImageSource.camera;
  final needsMedia = source == ImageSource.gallery;

  if (needsCamera) {
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      if (!context.mounted) return null;
      final granted = await showAnimatedDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PermissionRequestDialog(
          message: permissionMessage,
          onAllow: () => Navigator.of(dialogContext).pop(true),
          onDeny: () => Navigator.of(dialogContext).pop(false),
        ),
      );
      if (granted != true) return null;
      await Permission.camera.request();
    }

    if (!await Permission.camera.isGranted) {
      if (!context.mounted) return null;
      showInfoToast(context, context.l10n.cameraDenied);
      return null;
    }
  }

  if (needsMedia) {
    if (Platform.isAndroid) {
      // On Android, avoid explicit media permission requests to prevent
      // duplicate system pickers (e.g., "Select photos" flow). Let
      // ImagePicker handle access prompts.
      // Proceed directly to ImagePicker below.
      // No-op here.
      // ignore: empty_statements
    } else {
      final mediaStatus = await mediaPermission.status;
      if (!mediaStatus.isGranted && !mediaStatus.isLimited) {
        if (!context.mounted) return null;
        final granted = await showAnimatedDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => PermissionRequestDialog(
            message: permissionMessage,
            onAllow: () => Navigator.of(dialogContext).pop(true),
            onDeny: () => Navigator.of(dialogContext).pop(false),
          ),
        );
        if (granted != true) return null;
        await mediaPermission.request();
      }

      final isGranted = await mediaPermission.isGranted;
      final isLimited = await mediaPermission.isLimited;
      if (!isGranted && !isLimited) {
        if (!context.mounted) return null;
        showInfoToast(context, context.l10n.mediaDenied);
        return null;
      }
    }
  }

  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (picked == null) return null;
    return File(picked.path);
  } catch (e) {
    debugPrint('Image pick error: $e');
    if (context.mounted) {
      showAppToast(
        context,
        context.l10n.imageSelectionFailed,
        type: AppToastType.error,
      );
    }
    return null;
  }
}
