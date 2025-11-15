import 'package:budgets/features/user/domain/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/supabase_user_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../usecases/update_username.dart';

part 'user_providers.g.dart';

@riverpod
SupabaseUserDataSource userDataSource(Ref ref) {
  final client = Supabase.instance.client;
  return SupabaseUserDataSource(client);
}

@riverpod
UserRepositoryImpl userRepository(Ref ref) {
  final ds = ref.watch(userDataSourceProvider);
  return UserRepositoryImpl(ds);
}

@riverpod
Future<UserModel?> userModel(Ref ref) async {
  final repo = ref.watch(userRepositoryProvider);
  final user = await repo.getUserModel();
  return user;
}

// Expose UpdateUsername use case
final updateUsernameProvider = Provider<UpdateUsername>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UpdateUsername(repo);
});
