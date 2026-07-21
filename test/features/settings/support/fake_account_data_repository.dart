import 'package:budgets/features/settings/domain/repositories/account_data_repository.dart';

class FakeAccountDataRepository implements AccountDataRepository {
  String? dataConfirmation;
  String? accountConfirmation;

  @override
  Future<void> deleteAllData(String confirmation) async {
    dataConfirmation = confirmation;
  }

  @override
  Future<void> deleteAccount(String confirmation) async {
    accountConfirmation = confirmation;
  }
}
