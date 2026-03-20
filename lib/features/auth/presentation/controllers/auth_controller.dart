import 'dart:async';

import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/providers/auth_providers.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    debugPrint('[AuthController][signIn] Start');
    try {
      await repo.signInWithPassword(email: email, password: password);
      debugPrint('[AuthController][signIn] Success');
      ref.invalidate(userModelProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      debugPrint('[AuthController][signIn] Error: $e');
      debugPrint('[AuthController][signIn] StackTrace: $st');
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signUp(
      {required String username,
      required String email,
      required String password}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    debugPrint('[AuthController][signUp] Start');
    try {
      await repo.signUpWithPassword(
          email: email, password: password, username: username);
      debugPrint('[AuthController][signUp] Success');
      state = const AsyncData(null);
    } catch (e, st) {
      debugPrint('[AuthController][signUp] Error: $e');
      debugPrint('[AuthController][signUp] StackTrace: $st');
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.signOut();
      ref.invalidate(userModelProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> resetPassword(
      {required String email, String? redirectTo}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.sendPasswordResetEmail(email: email, redirectTo: redirectTo);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> verifyOtpAndResetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.verifyOtpAndResetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.changePassword(
          currentPassword: currentPassword, newPassword: newPassword);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
