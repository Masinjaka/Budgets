abstract class AuthRepository {
  // Email/password sign in
  Future<void> signInWithPassword({required String email, required String password});

  // Email/password sign up with optional profile data
  Future<void> signUpWithPassword({
    required String email,
    required String password,
    required String username,
  });

  // Sign out
  Future<void> signOut();

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email, String? redirectTo});

  // Auth state changes
  Stream<dynamic> authStateChanges();

  // Whether there's a session
  Future<bool> hasSession();
}
