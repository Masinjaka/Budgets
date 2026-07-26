import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/presentation/controllers/profile_photo_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/core/functions/pick_image_with_permissions.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/app_typography.dart';

class UploadProfilePhotoPage extends ConsumerStatefulWidget {
  const UploadProfilePhotoPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UploadProfilePhotoPageState();
}

class _UploadProfilePhotoPageState
    extends ConsumerState<UploadProfilePhotoPage> {
  File? _selectedImage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildForm(context)),
      bottomNavigationBar: _buildBottomPart(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ajouter un avatar',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppTypography.title,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Pour que vos partenaires de budget puissent vous reconnaitre.',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppTypography.body,
              ),
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: DottedBorder(
                    options: const CircularDottedBorderOptions(
                      color: Colors.grey,
                      strokeWidth: 2,
                      dashPattern: [8, 4],
                    ),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: _selectedImage == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            )
                          : ClipOval(
                              child: Image.file(
                                _selectedImage!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPart(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            text: 'Suivant',
            isLoading: _isLoading,
            onPressed: () async {
              if (_isLoading) return;
              setState(() => _isLoading = true);
              try {
                if (_selectedImage == null) {
                  final proceed = await showAnimatedDialog<bool>(
                    context: context,
                    builder: (_) => PermissionRequestDialog(
                      title: 'Continuer sans avatar ?',
                      message:
                          'Vous n\'avez pas sélectionné d\'image. Continuer sans avatar ?',
                      allowText: 'Oui',
                      denyText: 'Non',
                      onAllow: () => Navigator.of(context).pop(true),
                      onDeny: () => Navigator.of(context).pop(false),
                    ),
                  );
                  if (!context.mounted) return;
                  if (proceed == true) {
                    context.go('/home');
                  }
                  return;
                }
                // Get current user id from Supabase auth
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId == null) {
                  if (!mounted) return;
                  showAppToast(
                    context,
                    'Utilisateur non authentifié',
                    type: AppToastType.error,
                  );
                  return;
                }
                // Trigger upload via controller
                final controller =
                    ref.read(profilePhotoControllerProvider.notifier);
                await controller.upload(file: _selectedImage!, userId: userId);
                if (!mounted) return;
                final result = ref.read(profilePhotoControllerProvider);
                result.when(
                  data: (url) {
                    if (!mounted) return;
                    if (url != null) {
                      showSuccessToast(context, 'Avatar enregistré');
                    }
                    context.go('/home');
                  },
                  error: (e, _) {
                    if (!mounted) return;
                    showErrorToast(context, e);
                  },
                  loading: () {},
                );
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
          ),
          SizedBox(height: 16),
          CustomButton(
            text: 'Passer',
            borderColor: Colors.transparent,
            backgroundColor: Theme.of(context).cardColor,
            onPressed: () async {
              if (mounted) context.go('/home');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final file = await pickImageWithPermissions(context);
    if (!mounted || file == null) return;
    setState(() => _selectedImage = file);
  }
}
