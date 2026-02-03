import 'package:budgets/features/user/domain/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel?> getUserModel();
  Future<void> updateUsername(String username);
  Future<void> updateCurrencyCode(String currencyCode);
}
