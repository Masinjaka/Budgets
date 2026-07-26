import 'dart:io';

import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/features/auth/domain/providers/auth_providers.dart';
import 'package:budgets/features/profile/domain/provider/profile_providers.dart';
import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:budgets/features/user/presentation/controllers/username_controller.dart';
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileModule {
  EditProfileModule();

  Future<void> deleteCurrentUserAccount(
    BuildContext context,
    WidgetRef ref, {
    VoidCallback? onDeletionStart,
    VoidCallback? onDeletionEnd,
  }) async {
    final dialogConfirmed = await showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => PermissionRequestDialog(
        title: context.l10n.deleteAccountQuestion,
        allowText: context.l10n.delete,
        denyText: context.l10n.cancel,
        backgroundColor: Colors.redAccent,
        message: context.l10n.deleteAccountDetails,
        onAllow: () {
          Navigator.of(ctx).pop(true);
        },
        onDeny: () {
          Navigator.of(ctx).pop(false);
        },
      ),
    );

    if (dialogConfirmed == true) {
      if (!context.mounted) return;
      onDeletionStart?.call();
      try {
        await deleteAccount(context, ref);
      } finally {
        onDeletionEnd?.call();
      }

      if (!context.mounted) return;
      context.go('/getting-started');
    }
  }

  // Helper: delete current user's account
  Future<void> deleteAccount(BuildContext context, WidgetRef ref) async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.deleteAccount(reason: "User requested account deletion");
    } catch (e) {
      debugPrint('Account deletion error: $e');
      if (!context.mounted) return;
      showAppToast(
        context,
        context.l10n.deleteAccountSummary,
        type: AppToastType.error,
      );
    }
  }

  // Function to update profile
  Future<void> updateProfile({
    required GlobalKey<FormState> formKey,
    required TextEditingController usernameController,
    required File? selectedImage,
    required WidgetRef ref,
    required String? profilePhotoUrl,
    required bool isUpdating,
    required BuildContext context,
  }) async {
    final localizations = context.l10n;
    // Allow updating either field independently
    if (!formKey.currentState!.validate()) return;
    final username = usernameController.text.trim();
    final file = selectedImage;
    if (username.isEmpty && file == null) return; // nothing selected to change

    bool usernameUpdated = false;
    bool photoUpdated = false;
    String? errorMessage; // Function to update profile

    // Update username if provided
    if (username.isNotEmpty) {
      try {
        await ref.read(usernameControllerProvider.notifier).doUpdate(username);
        usernameUpdated = true;
      } catch (e) {
        errorMessage = localizations.usernameUpdateFailed;
        debugPrint('Username update error: $e');
      }
    }

    // Upload profile photo if a new one is selected
    if (file != null) {
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) throw StateError('No authenticated user');
        final uploader = ref.read(uploadAndSaveProfilePhotoProvider);
        final newUrl = await uploader(file: file, userId: userId);
        profilePhotoUrl = newUrl;
        photoUpdated = true;
      } catch (e) {
        errorMessage = errorMessage ?? localizations.profilePhotoUploadFailed;
        debugPrint('Photo upload error: $e');
      }
    }

    // Refresh every visible profile surface after the direct Supabase writes.
    ref.invalidate(userModelProvider);

    if (!context.mounted) {
      return;
    }

    if (errorMessage != null) {
      showAppToast(
        context,
        errorMessage,
        type: AppToastType.error,
      );
      return;
    }
    if (usernameUpdated || photoUpdated) {
      context.pop();
    }
  }
}
