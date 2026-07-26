import 'dart:io';

import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:flutter/material.dart';

class EditableProfileAvatar extends StatelessWidget {
  const EditableProfileAvatar({
    required this.selectedImage,
    required this.photoUrl,
    required this.isLoading,
    required this.onTap,
    super.key,
  });

  final File? selectedImage;
  final String? photoUrl;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox.square(dimension: 88, child: _image(context)),
            Positioned(
              right: -2,
              bottom: -2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(7),
                  child: Icon(Icons.camera_alt_outlined, size: 17),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(BuildContext context) {
    final file = selectedImage;
    if (file != null) {
      return ClipOval(child: Image.file(file, fit: BoxFit.cover));
    }
    if (isLoading) return avatarSkeleton(context, 88);
    return avatar(context, photoUrl, 88);
  }
}
