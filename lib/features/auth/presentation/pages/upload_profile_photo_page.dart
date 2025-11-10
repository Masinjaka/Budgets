// ignore_for_file: use_build_context_synchronously

import 'package:budgets/core/theme.dart';
import 'package:budgets/features/auth/presentation/widgets/file_picker_option.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/presentation/controllers/profile_photo_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadProfilePhotoPage extends ConsumerStatefulWidget {
  const UploadProfilePhotoPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UploadProfilePhotoPageState();
}

class _UploadProfilePhotoPageState
    extends ConsumerState<UploadProfilePhotoPage> {
  final ImagePicker _picker = ImagePicker();
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
                    borderType: BorderType.Circle,
                    color: Colors.grey,
                    strokeWidth: 2,
                    dashPattern: const [8, 4],
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: const BoxDecoration(
                        color: AppTheme.secondaryDark,
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
                    message: 'Vous n\'avez pas sélectionné d\'image. Continuer sans avatar ?',
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
                  const SnackBar(content: Text('Utilisateur non authentifié')),);
                return;
              }
              // Trigger upload via controller
              final controller = ref.read(profilePhotoControllerProvider.notifier);
              await controller.upload(file: _selectedImage!, userId: userId);
              final result = ref.read(profilePhotoControllerProvider);
              result.when(
                data: (url) {
                  if (url != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Avatar enregistré')),);
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
            foregroundColor: Colors.white,
            borderColor: Colors.transparent,
            backgroundColor: AppTheme.secondaryDark,
            onPressed: () async {
              if (mounted) context.go('/home');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    // Determine required media permission based on platform/version
    Permission mediaPermission;
    if (Platform.isIOS) {
      mediaPermission = Permission.photos;
    } else {
      // On Android 13+ photos/videos separated; permission_handler maps to photos. Use storage for older versions.
      // We attempt photos first then fallback to storage if not granted.
      mediaPermission = Permission
          .photos; // permission_handler handles API level specifics internally
    }

    final cameraStatus = await Permission.camera.status;
    final mediaStatus = await mediaPermission.status;

    if (!cameraStatus.isGranted || !mediaStatus.isGranted) {
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

      if (granted != true) return;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caméra refusée')),
      );
      return;
    }
    bool mediaGranted = await mediaPermission.isGranted;
    if (Platform.isAndroid && !mediaGranted) {
      mediaGranted = await Permission.storage.isGranted;
    }
    if (!mediaGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accès aux médias refusé')),
      );
      return;
    }

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
                "Choisir une source",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FileOption(
                    title: 'Depuis la galerie',
                    icon: Icons.photo_library,
                    onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                  ),
                  FileOption(
                    title: 'Prendre une photo',
                    icon: Icons.photo_camera,
                    onTap: () => Navigator.pop(ctx, ImageSource.camera),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
          source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (picked == null) return;
      setState(() {
        _selectedImage = File(picked.path);
      });
    } catch (e) {
      debugPrint('Image pick error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de la sélection de l\'image')),
      );
    }
  }
}
