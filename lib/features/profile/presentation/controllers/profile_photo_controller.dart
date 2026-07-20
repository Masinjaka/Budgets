import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/provider/profile_providers.dart';

part 'profile_photo_controller.g.dart';

@riverpod
class ProfilePhotoController extends _$ProfilePhotoController {
  Object? _token;

  @override
  AsyncValue<String?> build() {
    return const AsyncData(null);
  }

  Future<void> upload({required File file, required String userId}) async {
    // Prevent concurrent operation
    if (state.isLoading) return;

    // Get usecase fresh to avoid stale references
    final usecase = ref.read(uploadAndSaveProfilePhotoProvider);

    final t = Object();
    _token = t;
    state = const AsyncLoading();
    try {
      final url = await usecase(file: file, userId: userId);
      // Check if still mounted and token is current after async gap
      if (!ref.mounted || !identical(_token, t)) return;
      state = AsyncData(url);
    } catch (e, st) {
      if (!ref.mounted || !identical(_token, t)) return;
      state = AsyncError(e, st);
    } finally {
      if (identical(_token, t)) _token = null;
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}
