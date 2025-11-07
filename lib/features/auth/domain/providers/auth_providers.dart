import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repository/supabase_auth_repository.dart';
import '../interfaces/auth_repository.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => SupabaseAuthRepository();

@Riverpod(keepAlive: true)
Stream<dynamic> authState(Ref ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges();
}

@Riverpod(keepAlive: true)
Future<bool> hasSession(Ref ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.hasSession();
}
