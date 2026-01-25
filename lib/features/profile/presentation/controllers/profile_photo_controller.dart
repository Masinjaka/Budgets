import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/provider/profile_providers.dart';
import '../../domain/usecases/upload_and_save_profile_photo.dart';

part 'profile_photo_controller.g.dart';

@riverpod
class ProfilePhotoController extends _$ProfilePhotoController {
  UploadAndSaveProfilePhoto? _usecase;
  Object? _token;

  @override
  AsyncValue<String?> build() {
    _usecase = ref.read(uploadAndSaveProfilePhotoProvider);
    return const AsyncData(null);
  }

  Future<void> upload({required File file, required String userId}) async {
    // Prevent concurrent operation
    if (state.isLoading) return;
    final t = Object();
    _token = t;
    state = const AsyncLoading();
    try {
      final url = await _usecase!(file: file, userId: userId);
      if (!identical(_token, t)) return; // outdated
      state = AsyncData(url);
    } catch (e, st) {
      if (!identical(_token, t)) return;
      state = AsyncError(e, st);
    } finally {
      if (identical(_token, t)) _token = null;
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}
