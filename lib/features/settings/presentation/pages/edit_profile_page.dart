// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'dart:io';

import 'package:budgets/core/ui/glass_flexible_space.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/functions/pick_image_with_permissions.dart';
import 'package:budgets/features/settings/presentation/modules/edit_profile_module.dart';
import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:budgets/features/user/presentation/controllers/username_controller.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<EditProfilePage> {
  File? _selectedImage;
  String? _profilePhotoUrl;
  bool _isLoadingPhoto = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _isUpdating = false;
  EditProfileModule editProfileModule = EditProfileModule();

  @override
  void initState() {
    super.initState();
    ref.read(userModelProvider.future).then((user) {
      if (!mounted) return;
      setState(() {
        _profilePhotoUrl = user?.profilePhoto;
        _usernameController.text = user?.name ?? '';
        _isLoadingPhoto = false;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _isLoadingPhoto = false);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for username update errors, similar to login page pattern
    ref.listen(usernameControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (e, st) {
          if (!mounted) return;
          showErrorToast(context, e);
        },
      );
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: const GlassFlexibleSpace(),
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 10.h,
          title: Text(
            'Modifier le profil',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.all(2.h),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () async {
                    if (_isUpdating) return; // prevent double taps
                    setState(() => _isUpdating = true);
                    try {
                      await editProfileModule.updateProfile(
                        context: context,
                        formKey: _formKey,
                        usernameController: _usernameController,
                        selectedImage: _selectedImage,
                        ref: ref,
                        profilePhotoUrl: _profilePhotoUrl,
                        isUpdating: _isUpdating,
                      );
                    } finally {
                      setState(() => _isUpdating = false);
                    }
                  },
                  icon: _isUpdating
                      ? SizedBox(
                          width: 2.h,
                          height: 2.h,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        )
                      : Icon(
                          Icons.save_outlined,
                          size: 20.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfilePhotoSection(context),
                    SizedBox(height: 4.h),
                    _buildProfileInfoSection(context),
                    SizedBox(height: 4.h),
                    _buildDangerZone(context),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 1.h),
        SizedBox(
          width: double.infinity,
          child: _buildSectionCard(
            context,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: DottedBorder(
                    options: CircularDottedBorderOptions(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.35),
                      strokeWidth: 2,
                      dashPattern: const [8, 4],
                    ),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: _buildAvatarWidget(),
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(
                    Icons.photo_camera_outlined,
                    size: 18.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                  label: Text(
                    'Choisir une photo',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 1.h),
        CustomTextField(
          title: Text(
            "Nom d'utilisateur",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15.5.sp,
            ),
          ),
          hint: 'Nouveau nom d\'utilisateur',
          controller: _usernameController,
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18.sp,
                  color: theme.colorScheme.error,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'La suppression est définitive',
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Votre compte et vos données seront supprimés.',
              style: TextStyle(
                fontSize: 13.5.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 2.h),
            CustomButton(
              backgroundColor: Colors.redAccent,
              text: 'Supprimer mon compte',
              onPressed: _isLoading
                  ? null
                  : () async {
                      await editProfileModule.deleteCurrentUserAccount(
                        context,
                        ref,
                        onDeletionStart: () {
                          if (!mounted) return;
                          setState(() => _isLoading = true);
                        },
                        onDeletionEnd: () {
                          if (!mounted) return;
                          setState(() => _isLoading = false);
                        },
                      );
                    },
              isLoading: _isLoading,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(3.w),
      child: child,
    );
  }

  Widget _buildAvatarWidget() {
    if (_selectedImage != null) {
      return ClipOval(
        child: Image.file(
          _selectedImage!,
          width: 50.sp,
          height: 50.sp,
          fit: BoxFit.cover,
        ),
      );
    }
    if (_isLoadingPhoto) {
      return avatarSkeleton(context, 50.sp);
    }
    if (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty) {
      final localFile = File(_profilePhotoUrl!);
      if (localFile.existsSync()) {
        return ClipOval(
          child: Image.file(
            localFile,
            width: 50.sp,
            height: 50.sp,
            fit: BoxFit.cover,
          ),
        );
      }
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: _profilePhotoUrl!,
          width: 50.sp,
          height: 50.sp,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Icon(
            Icons.person,
            size: 50.sp,
            color: Colors.grey,
          ),
        ),
      );
    }
    return Icon(
      Icons.person,
      size: 50.sp,
      color: Colors.grey,
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
