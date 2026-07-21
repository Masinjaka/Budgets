import 'package:budgets/features/settings/presentation/view_models/danger_zone_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_account_data_repository.dart';

void main() {
  test('delegates data and account deletion confirmations', () async {
    final repository = FakeAccountDataRepository();
    final viewModel = DangerZoneViewModel(repository);
    addTearDown(viewModel.dispose);

    await viewModel.deleteAllData('SUPPRIMER');
    await viewModel.deleteAccount('owner@example.com');

    expect(repository.dataConfirmation, 'SUPPRIMER');
    expect(repository.accountConfirmation, 'owner@example.com');
    expect(viewModel.isBusy, isFalse);
  });
}
