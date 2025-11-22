import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/provider/profile_providers.dart';
import '../../domain/usecases/upload_and_save_profile_photo.dart';

class ProfilePhotoController extends StateNotifier<AsyncValue<String?>> {
  ProfilePhotoController(this._usecase) : super(const AsyncData(null));
  final UploadAndSaveProfilePhoto _usecase;
  Object? _token;

  Future<void> upload({required File file, required String userId}) async {
    // Prevent concurrent operation
    if (state.isLoading) return;
    final t = Object();
    _token = t;
    if (!mounted) return; // safety
    state = const AsyncLoading();
    try {
      final url = await _usecase(file: file, userId: userId);
      if (!identical(_token, t) || !mounted) return; // outdated or disposed
      state = AsyncData(url);
    } catch (e, st) {
      if (!identical(_token, t) || !mounted) return;
      state = AsyncError(e, st);
    } finally {
      if (identical(_token, t)) _token = null;
    }
  }

  void reset() {
    if (!mounted) return;
    state = const AsyncData(null);
  }
}

final profilePhotoControllerProvider =
    StateNotifierProvider<ProfilePhotoController, AsyncValue<String?>>((ref) {
  final usecase = ref.read(uploadAndSaveProfilePhotoProvider);
  return ProfilePhotoController(usecase);
});
