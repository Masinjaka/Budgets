import 'package:budgets/features/ai_entry/domain/models/manual_entry_input.dart';

enum ManualEntrySheetAction { save, delete }

class ManualEntrySheetResult {
  const ManualEntrySheetResult.save(ManualEntryInput this.input)
      : action = ManualEntrySheetAction.save;

  const ManualEntrySheetResult.delete()
      : action = ManualEntrySheetAction.delete,
        input = null;

  final ManualEntrySheetAction action;
  final ManualEntryInput? input;
}
