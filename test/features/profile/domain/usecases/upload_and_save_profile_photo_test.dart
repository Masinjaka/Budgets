import 'dart:async';
import 'dart:io';

import 'package:budgets/features/profile/domain/usecases/upload_and_save_profile_photo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_profile_repository.dart';

void main() {
  group('UploadAndSaveProfilePhoto', () {
    test('uploads and stores the resulting public URL', () async {
      final repository = FakeProfileRepository();
      final useCase = UploadAndSaveProfilePhoto(repository);

      final result = await useCase(file: File('avatar.jpg'), userId: 'user-1');

      expect(result, 'https://image.test/a');
      expect(repository.savedUserId, 'user-1');
      expect(repository.savedPhotoUrl, result);
    });

    test('times out instead of waiting forever for an upload', () async {
      final repository = FakeProfileRepository()
        ..upload = (_, __) => Completer<String>().future;
      final useCase = UploadAndSaveProfilePhoto(
        repository,
        timeout: const Duration(milliseconds: 10),
      );

      await expectLater(
        useCase(file: File('avatar.jpg'), userId: 'user-1'),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('times out instead of waiting forever while saving the URL', () async {
      final repository = FakeProfileRepository()
        ..save = (_, __) => Completer<void>().future;
      final useCase = UploadAndSaveProfilePhoto(
        repository,
        timeout: const Duration(milliseconds: 10),
      );

      await expectLater(
        useCase(file: File('avatar.jpg'), userId: 'user-1'),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
