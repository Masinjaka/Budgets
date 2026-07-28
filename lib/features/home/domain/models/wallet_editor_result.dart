import 'package:budgets/features/home/domain/models/add_wallet_input.dart';

enum WalletEditorAction { save, delete }

class WalletEditorResult {
  const WalletEditorResult.save(this.input) : action = WalletEditorAction.save;

  const WalletEditorResult.delete()
      : action = WalletEditorAction.delete,
        input = null;

  final WalletEditorAction action;
  final AddWalletInput? input;
}
