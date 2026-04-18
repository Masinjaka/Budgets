import 'package:budgets/features/user/domain/models/user_model.dart';
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
Stream<UserModel?> userModel(Ref ref) {
  final ds = ref.watch(userDataSourceProvider);
  return ds.watchCurrentUserRow();
}

@riverpod
UpdateUsername updateUsername(Ref ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UpdateUsername(repo);
}
