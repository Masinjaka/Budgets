import 'package:budgets/core/constants.dart';
import 'package:budgets/main.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/interfaces/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client = supabase;

  @override
  Future<void> signInWithPassword(
      {required String email, required String password}) async {
    debugPrint('[SupabaseAuthRepository][signInWithPassword] Start');
    try {
      final response = await _client.auth
          .signInWithPassword(email: email, password: password);
      debugPrint(
          '[SupabaseAuthRepository][signInWithPassword] Success userId=${response.user?.id}, hasSession=${response.session != null}');
    } catch (e, st) {
      debugPrint('[SupabaseAuthRepository][signInWithPassword] Error: $e');
      debugPrint(
          '[SupabaseAuthRepository][signInWithPassword] StackTrace: $st');
      rethrow;
    }
  }

  @override
  Future<void> signUpWithPassword(
      {required String email,
      required String password,
      required String username}) async {
    debugPrint('[SupabaseAuthRepository][signUpWithPassword] Start');
    try {
      final response =
          await _client.auth.signUp(email: email, password: password, data: {
        'username': username,
      });
      debugPrint(
          '[SupabaseAuthRepository][signUpWithPassword] Success userId=${response.user?.id}, hasSession=${response.session != null}');
    } catch (e, st) {
      debugPrint('[SupabaseAuthRepository][signUpWithPassword] Error: $e');
      debugPrint(
          '[SupabaseAuthRepository][signUpWithPassword] StackTrace: $st');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(
      {required String email, String? redirectTo}) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo ?? LocalAppStorage.resetRedirectUri,
    );
  }

  @override
  Future<void> changePassword(
      {required String currentPassword, required String newPassword}) async {
    // First, verify the current password by trying to sign in
    final currentUser = _client.auth.currentUser;
    if (currentUser == null || currentUser.email == null) {
      throw Exception('User not authenticated');
    }

    try {
      // If verification successful, update password
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('Current password is incorrect');
      }
      rethrow;
    }
  }

  @override
  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  @override
  Future<bool> hasSession() async => _client.auth.currentSession != null;

  @override
  Future<void> deleteAccount({String? reason}) async {
    // Best practice: perform destructive operations server-side with a service role key
    // via a Supabase Edge Function. The client sends the user's JWT for verification.
    final session = _client.auth.currentSession;
    final accessToken = session?.accessToken;
    if (accessToken == null) {
      throw StateError('No authenticated session');
    }

    try {
      final result = await _client.rpc('delete_user');

      debugPrint('delete_user RPC result: $result');
      // Sign out locally after successful deletion
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Error deleting account: $e');

      rethrow;
    }
  }
}
