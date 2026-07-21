import 'package:budgets/features/settings/data/services/account_data_service.dart';
import 'package:budgets/features/settings/domain/repositories/account_data_repository.dart';

class SupabaseAccountDataRepository implements AccountDataRepository {
  const SupabaseAccountDataRepository(this._service);

  final AccountDataService _service;

  @override
  Future<void> deleteAllData(String confirmation) =>
      _service.deleteAllData(confirmation);

  @override
  Future<void> deleteAccount(String confirmation) =>
      _service.deleteAccount(confirmation);
}
