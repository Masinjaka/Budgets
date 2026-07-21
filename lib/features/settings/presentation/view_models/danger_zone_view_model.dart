import 'package:budgets/features/settings/domain/repositories/account_data_repository.dart';
import 'package:flutter/foundation.dart';

enum DangerZoneAction { deleteData, deleteAccount }

class DangerZoneViewModel extends ChangeNotifier {
  DangerZoneViewModel(this._repository);

  final AccountDataRepository _repository;
  DangerZoneAction? _busyAction;

  DangerZoneAction? get busyAction => _busyAction;
  bool get isBusy => _busyAction != null;

  Future<void> deleteAllData(String confirmation) => _run(
        DangerZoneAction.deleteData,
        () => _repository.deleteAllData(confirmation),
      );

  Future<void> deleteAccount(String confirmation) => _run(
        DangerZoneAction.deleteAccount,
        () => _repository.deleteAccount(confirmation),
      );

  Future<void> _run(
    DangerZoneAction action,
    Future<void> Function() operation,
  ) async {
    if (isBusy) return;
    _busyAction = action;
    notifyListeners();
    try {
      await operation();
    } finally {
      _busyAction = null;
      notifyListeners();
    }
  }
}
