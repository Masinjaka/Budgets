class AuthUser {
  final String id;
  final String? email;
  final String? username;

  const AuthUser({required this.id, this.email, this.username});

  factory AuthUser.fromSupabase(Map<String, dynamic> user) {
    return AuthUser(
      id: user['id'] as String,
      email: user['email'] as String?,
      username: user['user_metadata']?['username'] as String?,
    );
  }
}
