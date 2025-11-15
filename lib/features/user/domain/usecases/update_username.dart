import 'package:budgets/features/user/domain/interfaces/user_repository.dart';
import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_username.g.dart';

class UpdateUsername {
  UpdateUsername(this._repo);
  final UserRepository _repo;

  Future<void> call(String username) => _repo.updateUsername(username);
}

@riverpod
UpdateUsername updateUsername(Ref ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UpdateUsername(repo);
}
