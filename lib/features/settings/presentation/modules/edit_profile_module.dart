import 'dart:io';

import 'package:budgets/features/auth/domain/providers/auth_providers.dart';
import 'package:budgets/features/profile/domain/provider/profile_providers.dart';
import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:budgets/features/user/presentation/controllers/username_controller.dart';
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budgets/features/user/data/datasources/user_api.dart';

class EditProfileModule {
  EditProfileModule();

  Future<void> deleteCurrentUserAccount(
      BuildContext context, WidgetRef ref) async {
    final dialogConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => PermissionRequestDialog(
        title: "Suppression du compte",
        allowText: "Supprimer",
        denyText: "Annuler",
        backgroundColor: Colors.redAccent,
        message:
            'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible. Toutes vos données seront perdues.',
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
      await deleteAccount(context, ref);

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la suppression du compte')),
      );
    }
  }

  // Helper: fetch current user's profile photo url
  Future<String?> fetchProfilePhotoUrl() async {
    try {
      final user = await getUser();
      return user.profilePhoto;
    } catch (_) {
      return null;
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
        errorMessage = "Erreur lors de la mise à jour du nom d'utilisateur";
        debugPrint('Username update error: $e');
      }
    }

    // Upload profile photo if a new one is selected
    if (file != null) {
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          final uploader = ref.read(uploadAndSaveProfilePhotoProvider);
          final newUrl = await uploader(file: file, userId: userId);
          profilePhotoUrl = newUrl; // local update for immediate UI if needed
          photoUpdated = true;
        }
      } catch (e) {
        errorMessage = errorMessage ??
            'Erreur lors du téléversement de la photo de profil';
        debugPrint('Photo upload error: $e');
      }
    }

    // Refresh user model so other parts of UI update
    final _ = ref.refresh(userModelProvider);

    if (!context.mounted) {
      return;
    }

    // Show feedback
    if (errorMessage != null && !(usernameUpdated || photoUpdated)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } else {
      context.pop();
    }
  }
}
