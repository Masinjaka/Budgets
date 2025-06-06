import 'package:budgets/api/user_api.dart';
import 'package:budgets/core/constants.dart';
import 'package:budgets/main.dart';
import 'package:budgets/model/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<UserModel> build() async{
    return await getUser();
  }

  /// Sign in function
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Get the access token and refresh token
      final accessToken = response.session!.accessToken;
      final refreshToken = response.session!.refreshToken;

      // store the tokens in shared preferences
      storageBox.put(LocalAppStorage.accessKey, accessToken);
      storageBox.put(LocalAppStorage.refreshKey, refreshToken);

      // Fetch the user profile
      state = AsyncValue.data(await getUser());
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  /// Sign out function
  Future<void> signOut() async {
    await supabase.auth.signOut();
    state = AsyncValue.data(UserModel());
  }

  /// Sign up function
  Future<void> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    state = const AsyncValue.loading();

    try {
      AuthResponse response = await supabase.auth.signUp(
        password: password,
        email: email,
        data: {
          'username': username
        },
      );

      // Get access and refresh token
      storageBox.put(LocalAppStorage.accessKey, response.session!.accessToken);
      storageBox.put(LocalAppStorage.refreshKey, response.session!.refreshToken);

      // Fetch the user profile
      state = AsyncValue.data(await getUser());
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
