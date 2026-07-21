import 'package:budgets/features/settings/domain/repositories/account_data_repository.dart';

class UnavailableAccountDataRepository implements AccountDataRepository {
  const UnavailableAccountDataRepository();

  @override
  Future<void> deleteAllData(String confirmation) {
    throw StateError('No authenticated session');
  }

  @override
  Future<void> deleteAccount(String confirmation) {
    throw StateError('No authenticated session');
  }
}
