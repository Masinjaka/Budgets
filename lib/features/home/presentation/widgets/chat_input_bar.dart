import 'package:budgets/features/home/domain/models/receipt_input_result.dart';
import 'package:budgets/features/home/presentation/services/receipt_input_service.dart';
import 'package:budgets/features/home/presentation/widgets/receipt_input_bottom_sheet.dart';
import 'package:flutter/material.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    this.receiptInputService = const ReceiptInputService(),
    super.key,
  });

  final ReceiptInputService receiptInputService;

  Future<void> _showReceiptOptions(BuildContext context) async {
    final action = await ReceiptInputBottomSheet.show(context);
    if (action == null || !context.mounted) return;

    try {
      final result = switch (action) {
        ReceiptInputAction.importFile => await receiptInputService.importFile(),
        ReceiptInputAction.scanReceipt =>
          await receiptInputService.scanReceipt(),
      };
      if (result == null || result.isEmpty || !context.mounted) return;
      _showResult(context, result);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not add receipt: $error')),
      );
    }
  }

  void _showResult(BuildContext context, ReceiptInputResult result) {
    final label = switch (result.source) {
      ReceiptInputSource.importedFile => 'File imported',
      ReceiptInputSource.scannedReceipt => 'Receipt scanned',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label and ready for AI extraction.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      margin: const EdgeInsets.only(left: 28, right: 26),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E3E3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showReceiptOptions(context),
            icon: const Icon(Icons.add_rounded, size: 26),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 51, height: 46),
            tooltip: 'Add receipt',
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: TextField(
              style: TextStyle(fontSize: 12),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'What did you spend money on today',
                hintStyle: TextStyle(color: Color(0xFF5F5F5F), fontSize: 12),
              ),
              textInputAction: TextInputAction.send,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send_outlined, size: 27),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 53, height: 46),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}
