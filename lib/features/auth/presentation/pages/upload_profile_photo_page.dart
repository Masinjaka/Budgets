// ignore_for_file: use_build_context_synchronously

import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/presentation/controllers/profile_photo_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budgets/core/functions/pick_image_with_permissions.dart';

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
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ajouter un avatar',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20.5.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Pour que vos partenaires de budget puissent vous reconnaitre.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15.5.sp,
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
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: _selectedImage == null
                          ? Icon(
                              Icons.person,
                              size: 50.sp,
                              color: Colors.grey,
                            )
                          : ClipOval(
                              child: Image.file(
                                _selectedImage!,
                                width: 50.sp,
                                height: 50.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            text: 'Suivant',
            isLoading: _isLoading,
            onPressed: () async {
              if (_isLoading) return;
              setState(() {
                _isLoading = true;
              });
              if (_selectedImage == null) {
                final proceed = await showDialog<bool>(
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
                if (proceed == true) {
                  if (mounted) context.go('/home');
                }
                setState(() {
                  _isLoading = false;
                });
                return;
              }
              // Get current user id from Supabase auth
              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Utilisateur non authentifié')),
                );
                return;
              }
              // Trigger upload via controller
              final controller =
                  ref.read(profilePhotoControllerProvider.notifier);
              await controller.upload(file: _selectedImage!, userId: userId);
              final result = ref.read(profilePhotoControllerProvider);
              result.when(
                data: (url) {
                  if (url != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Avatar enregistré')),
                    );
                  }
                  if (mounted) context.go('/home');
                },
                error: (e, _) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                },
                loading: () {},
              );
              setState(() {
                _isLoading = false;
              });
            },
          ),
          SizedBox(height: 2.h),
          CustomButton(
            text: 'Passer',
            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
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
    if (file == null) return;
    setState(() {
      _selectedImage = file;
    });
  }
}
