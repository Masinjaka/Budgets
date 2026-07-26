import 'dart:io';

import 'package:budgets/features/profile/domain/interfaces/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  Future<String> Function(File file, String userId)? upload;
  Future<void> Function(String userId, String photoUrl)? save;
  String? savedUserId;
  String? savedPhotoUrl;

  @override
  Future<String> uploadProfileImage({
    required File file,
    required String userId,
  }) {
    return upload?.call(file, userId) ?? Future.value('https://image.test/a');
  }

  @override
  Future<void> saveProfilePhotoUrl({
    required String userId,
    required String photoUrl,
  }) async {
    savedUserId = userId;
    savedPhotoUrl = photoUrl;
    await save?.call(userId, photoUrl);
  }
}
