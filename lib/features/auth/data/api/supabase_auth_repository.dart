import 'package:budgets/core/constants.dart';
import 'package:budgets/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/interfaces/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client = supabase;

  @override
  Future<void> signInWithPassword({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUpWithPassword({required String email, required String password, required String username}) async {
    await _client.auth.signUp(email: email, password: password, data: {
      'username': username,
    });
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email, String? redirectTo}) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo ?? LocalAppStorage.resetRedirectUri,
    );
  }

  @override
  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  @override
  Future<bool> hasSession() async => _client.auth.currentSession != null;
}
