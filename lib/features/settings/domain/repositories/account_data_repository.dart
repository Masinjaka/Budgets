abstract interface class AccountDataRepository {
  Future<void> deleteAllData(String confirmation);

  Future<void> deleteAccount(String confirmation);
}
