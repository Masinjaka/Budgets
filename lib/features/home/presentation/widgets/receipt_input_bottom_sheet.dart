import 'package:budgets/features/home/presentation/widgets/bottom_sheet_drag_handle.dart';
import 'package:budgets/features/home/presentation/widgets/receipt_input_option.dart';
import 'package:flutter/material.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

enum ReceiptInputAction { manualEntry, importFile, scanReceipt }

class ReceiptInputBottomSheet extends StatelessWidget {
  const ReceiptInputBottomSheet({super.key});

  static Future<ReceiptInputAction?> show(BuildContext context) {
    return showModalBottomSheet<ReceiptInputAction>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ReceiptInputBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.sizeOf(context).width;
    final sheetWidth = availableWidth > 480 ? 480.0 : availableWidth;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: sheetWidth,
        height: 222,
        padding: const EdgeInsets.fromLTRB(28, 13, 28, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomSheetTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BottomSheetDragHandle(),
              const SizedBox(height: 28),
              ReceiptInputOption(
                icon: Icons.edit_note_rounded,
                label: context.l10n.enterManually,
                onTap: () => Navigator.pop(
                  context,
                  ReceiptInputAction.manualEntry,
                ),
              ),
              const SizedBox(height: 12),
              ReceiptInputOption(
                icon: Icons.note_add_outlined,
                label: context.l10n.importFile,
                onTap: () => Navigator.pop(
                  context,
                  ReceiptInputAction.importFile,
                ),
              ),
              const SizedBox(height: 12),
              ReceiptInputOption(
                icon: Icons.document_scanner_outlined,
                label: context.l10n.scanReceipt,
                onTap: () => Navigator.pop(
                  context,
                  ReceiptInputAction.scanReceipt,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
