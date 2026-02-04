import 'package:budgets/features/user/domain/interfaces/user_repository.dart';

class UpdateUsername {
  UpdateUsername(this._repo);
  final UserRepository _repo;

  Future<void> call(String username) => _repo.updateUsername(username);
}
