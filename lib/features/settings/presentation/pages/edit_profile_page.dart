import 'dart:io';

import 'package:budgets/core/functions/pick_image_with_permissions.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:budgets/api/user_api.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    try {
      final user = await getUser();
      if (!mounted) return;
      setState(() {
        _profilePhotoUrl = user.profilePhoto;
        _isLoadingPhoto = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingPhoto = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundDark,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 10.h,
            actions: [
              Padding(
                padding: EdgeInsets.all(2.h),
                child: TextButton(
                  onPressed: () => {},
                  child: Text(
                    'Sauvegarder',
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      color: AppTheme.primaryGreen,
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
                padding: EdgeInsets.symmetric(horizontal: 6.w,vertical: 2.h),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
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
      return avatarSkeleton(50.sp);
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
