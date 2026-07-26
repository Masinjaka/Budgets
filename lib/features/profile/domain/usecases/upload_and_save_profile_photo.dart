import 'dart:async';
import 'dart:io';

import 'package:budgets/features/profile/domain/interfaces/profile_repository.dart';
import 'package:flutter/foundation.dart';

/// Use case to upload the image then persist its URL for a user.
class UploadAndSaveProfilePhoto {
  UploadAndSaveProfilePhoto(
    this.repository, {
    this.timeout = const Duration(seconds: 30),
  });

  final ProfileRepository repository;
  final Duration timeout;

  /// Returns the final stored photo URL.
  Future<String> call({required File file, required String userId}) async {
    final url = await repository
        .uploadProfileImage(file: file, userId: userId)
        .timeout(timeout);
    debugPrint('Uploaded profile photo URL: $url');
    await repository
        .saveProfilePhotoUrl(userId: userId, photoUrl: url)
        .timeout(timeout);
    return url;
  }
}
