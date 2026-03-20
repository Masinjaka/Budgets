abstract class AuthRepository {
  // Email/password sign in
  Future<void> signInWithPassword(
      {required String email, required String password});

  // Email/password sign up with optional profile data
  Future<void> signUpWithPassword({
    required String email,
    required String password,
    required String username,
  });

  // Sign out
  Future<void> signOut();

  // Send password reset email
  Future<void> sendPasswordResetEmail(
      {required String email, String? redirectTo});

  // Verify OTP code and set new password (password reset flow)
  Future<void> verifyOtpAndResetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  // Change password for authenticated user
  Future<void> changePassword(
      {required String currentPassword, required String newPassword});

  // Auth state changes
  Stream<dynamic> authStateChanges();

  // Whether there's a session
  Future<bool> hasSession();

  // Gracefully delete the currently authenticated user's account
  // Best practice: call a server-side (Edge Function) endpoint that performs
  // privileged deletes (auth user, storage, and related rows) with a service role.
  Future<void> deleteAccount({String? reason});
}
