import 'package:budgets/features/home/presentation/widgets/receipt_input_option.dart';
import 'package:flutter/material.dart';

enum ReceiptInputAction { importFile, scanReceipt }

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
        height: 176,
        padding: const EdgeInsets.fromLTRB(28, 13, 28, 0),
        decoration: const BoxDecoration(
          color: Color(0xFFFEFEFE),
          borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
          boxShadow: [
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
              Center(
                child: Container(
                  width: 53,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2D2D2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              ReceiptInputOption(
                icon: Icons.note_add_outlined,
                label: 'Import file',
                onTap: () => Navigator.pop(
                  context,
                  ReceiptInputAction.importFile,
                ),
              ),
              const SizedBox(height: 12),
              ReceiptInputOption(
                icon: Icons.document_scanner_outlined,
                label: 'Scan receipt',
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
