// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'dart:io';

import 'package:budgets/core/ui/glass_flexible_space.dart';
import 'package:budgets/core/functions/pick_image_with_permissions.dart';
import 'package:budgets/features/settings/presentation/modules/edit_profile_module.dart';
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
    // Load profile photo via module without defining a local method
    editProfileModule.fetchProfilePhotoUrl().then((url) {
      if (!mounted) return;
      setState(() {
        _profilePhotoUrl = url;
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$e')));
        },
      );
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: const GlassFlexibleSpace(),
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 10.h,
          actions: [
            Padding(
              padding: EdgeInsets.all(2.h),
              child: TextButton(
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
                child: _isUpdating
                    ? SizedBox(
                        width: 2.h,
                        height: 2.h,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : Text(
                        'Sauvegarder',
                        style: TextStyle(
                          fontSize: 15.5.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SizedBox(
            height: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 12.h), // Top padding for glass effect
                    GestureDetector(
                      onTap: _pickImage,
                      child: DottedBorder(
                        borderType: BorderType.Circle,
                        color: Colors.grey,
                        strokeWidth: 2,
                        dashPattern: const [8, 4],
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: _buildAvatarWidget(),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Modifier l'avatar",
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 5.h),
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
                    SizedBox(height: 3.h),
                    Divider(
                      height: 4.h,
                    ),
                    SizedBox(height: 3.h),
                    const Spacer(),
                    CustomButton(
                      backgroundColor: Colors.redAccent,
                      text: 'Supprimer mon compte',
                      onPressed: () async {
                        setState(() => _isLoading = true);

                        await editProfileModule.deleteCurrentUserAccount(
                            context, ref);

                        setState(() => _isLoading = false);
                      },
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
