import 'package:budgets/features/user/domain/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUserModel();
}
