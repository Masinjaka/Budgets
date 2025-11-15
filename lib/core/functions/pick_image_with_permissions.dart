import 'dart:io';

import 'package:budgets/core/theme.dart';
import 'package:budgets/features/auth/presentation/widgets/file_picker_option.dart';
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Pick an image from camera or gallery with proper permission handling.
/// Returns the picked image as a File, or null if the user cancels or permissions are denied.
Future<File?> pickImageWithPermissions(BuildContext context) async {
  // Determine required media permission based on platform/version
  Permission mediaPermission;
  if (Platform.isIOS) {
    mediaPermission = Permission.photos;
  } else {
    // On Android 13+ photos/videos separated; permission_handler maps to photos. Use storage for older versions.
    mediaPermission = Permission.photos;
  }

  final cameraStatus = await Permission.camera.status;
  final mediaStatus = await mediaPermission.status;

  if (!cameraStatus.isGranted || !mediaStatus.isGranted) {
    if (!context.mounted) return null;

    final granted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PermissionRequestDialog(
        message:
            'Nous avons besoin de la caméra et l\'accès aux fichiers pour ajouter votre avatar.',
        onAllow: () async {
          Navigator.of(context).pop(true);
        },
        onDeny: () {
          Navigator.of(context).pop(false);
        },
      ),
    );

    if (granted != true) return null;

    // Request both
    await Permission.camera.request();
    await mediaPermission.request();
    // Android fallback for older SDKs where storage is required
    if (Platform.isAndroid && !(await mediaPermission.isGranted)) {
      await Permission.storage.request();
    }
  }

  // Verify again
  if (!await Permission.camera.isGranted) {
    if (!context.mounted) return null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Caméra refusée')),
    );
    return null;
  }
  bool mediaGranted = await mediaPermission.isGranted;
  if (Platform.isAndroid && !mediaGranted) {
    mediaGranted = await Permission.storage.isGranted;
  }
  if (!mediaGranted) {
    if (!context.mounted) return null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Accès aux médias refusé')),
    );
    return null;
  }

  if (!context.mounted) return null;

  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppTheme.backgroundDark,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(3.w)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 2.h),
            Text(
              'Choisir une source',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FileOption(
                  icon: Icons.photo_library,
                  title: 'Depuis la galerie',
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                FileOption(
                  icon: Icons.photo_camera,
                  title: 'Prendre une photo',
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      );
    },
  );

  if (source == null) return null;

  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (picked == null) return null;
    return File(picked.path);
  } catch (e) {
    debugPrint('Image pick error: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la sélection de l\'image')),
      );
    }
    return null;
  }
}
