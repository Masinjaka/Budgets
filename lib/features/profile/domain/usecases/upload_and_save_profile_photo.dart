import 'dart:io';
import 'package:budgets/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter/foundation.dart';

/// Use case to upload the image then persist its URL for a user.
class UploadAndSaveProfilePhoto {
  final ProfileRepositoryImpl repository;
  UploadAndSaveProfilePhoto(this.repository);

  /// Returns the final stored photo URL.
  Future<String> call({required File file, required String userId}) async {
    final url = await repository.uploadProfileImage(file: file, userId: userId);
    debugPrint('Uploaded profile photo URL: $url');
    await repository.saveProfilePhotoUrl(userId: userId, photoUrl: url);
    return url;
  }
}
