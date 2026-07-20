import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/home/domain/models/receipt_input_result.dart';
import 'package:budgets/features/home/presentation/services/receipt_input_service.dart';
import 'package:budgets/features/home/presentation/widgets/receipt_input_bottom_sheet.dart';
import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.onSubmit,
    required this.isSubmitting,
    required this.onManualEntryRequested,
    this.isQuotaExhausted = false,
    this.receiptInputService = const ReceiptInputService(),
    super.key,
  });

  final Future<bool> Function(String message) onSubmit;
  final bool isSubmitting;
  final Future<void> Function() onManualEntryRequested;
  final bool isQuotaExhausted;
  final ReceiptInputService receiptInputService;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.isQuotaExhausted) {
      await widget.onManualEntryRequested();
      return;
    }
    final message = _controller.text.trim();
    if (message.isEmpty || widget.isSubmitting) return;
    FocusScope.of(context).unfocus();
    if (await widget.onSubmit(message) && mounted) {
      _controller.clear();
    }
  }

  Future<void> _showReceiptOptions() async {
    final action = await ReceiptInputBottomSheet.show(context);
    if (action == null || !mounted) return;
    if (action == ReceiptInputAction.manualEntry) {
      await widget.onManualEntryRequested();
      return;
    }
    try {
      final result = switch (action) {
        ReceiptInputAction.manualEntry => null,
        ReceiptInputAction.importFile =>
          await widget.receiptInputService.importFile(),
        ReceiptInputAction.scanReceipt =>
          await widget.receiptInputService.scanReceipt(),
      };
      if (result == null || result.isEmpty || !mounted) return;
      _showResult(result);
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  void _showResult(ReceiptInputResult result) {
    final label = switch (result.source) {
      ReceiptInputSource.importedFile => 'File imported',
      ReceiptInputSource.scannedReceipt => 'Receipt scanned',
    };
    showInfoToast(context, '$label and ready for AI extraction.');
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
            onPressed: widget.isSubmitting ? null : _showReceiptOptions,
            icon: const Icon(Icons.add_rounded, size: 26),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 51, height: 46),
            tooltip: 'Add receipt',
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !widget.isSubmitting,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'What did you spend money on today',
                hintStyle: TextStyle(color: Color(0xFF5F5F5F), fontSize: 12),
              ),
              textInputAction: TextInputAction.send,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            key: Key(
              widget.isQuotaExhausted ? 'manual-entry-send' : 'ai-send',
            ),
            onPressed: widget.isSubmitting
                ? null
                : widget.isQuotaExhausted
                    ? widget.onManualEntryRequested
                    : _submit,
            icon: widget.isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    widget.isQuotaExhausted
                        ? Icons.edit_note_rounded
                        : Icons.send_outlined,
                    size: 27,
                  ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 53, height: 46),
            tooltip: widget.isQuotaExhausted ? 'Manual entry' : 'Send',
          ),
        ],
      ),
    );
  }
}
