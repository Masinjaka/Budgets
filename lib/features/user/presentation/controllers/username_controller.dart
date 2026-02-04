import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/provider/user_providers.dart';

part 'username_controller.g.dart';

@Riverpod(keepAlive: true)
class UsernameController extends _$UsernameController {
  @override
  FutureOr<void> build() {}

  Future<void> doUpdate(String username) async {
    state = const AsyncLoading();
    final usecase = ref.read(updateUsernameProvider);
    try {
      await usecase(username);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
