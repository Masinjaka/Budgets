import 'package:budgets/features/user/domain/models/user_model.dart';

import '../../domain/interfaces/user_repository.dart';
import '../datasources/supabase_user_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final SupabaseUserDataSource dataSource;
  UserRepositoryImpl(this.dataSource);

  @override
  Future<UserModel?> getUserModel() {
    return dataSource.getCurrentUserRow();
  }

  @override
  Future<void> updateUsername(String username) {
    return dataSource.updateUsername(username);
  }

  @override
  Future<void> updateCurrencyCode(String currencyCode) {
    return dataSource.updateCurrencyCode(currencyCode);
  }
}
