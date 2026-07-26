import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/home/domain/models/receipt_input_result.dart';
import 'package:budgets/features/home/presentation/services/receipt_input_service.dart';
import 'package:budgets/features/home/presentation/widgets/chat_input_suggestions.dart';
import 'package:budgets/features/home/presentation/widgets/chat_send_button.dart';
import 'package:budgets/features/home/presentation/widgets/chat_suggestions_reveal.dart';
import 'package:budgets/features/home/presentation/widgets/receipt_input_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.onSubmit,
    required this.isSubmitting,
    required this.onManualEntryRequested,
    this.onReceiptSubmit,
    this.isQuotaExhausted = false,
    this.receiptInputService = const ReceiptInputService(),
    super.key,
  });
  final Future<bool> Function(String message) onSubmit;
  final bool isSubmitting;
  final Future<void> Function() onManualEntryRequested;
  final Future<bool> Function(ReceiptInputResult input)? onReceiptSubmit;
  final bool isQuotaExhausted;
  final ReceiptInputService receiptInputService;
  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController(), _focusNode = FocusNode();
  bool _isProcessingReceipt = false;
  @override
  void initState() {
    super.initState();
    _controller.addListener(_refreshComposer);
    _focusNode.addListener(_refreshComposer);
  }

  void _refreshComposer() => setState(() {});
  @override
  void dispose() {
    _controller.removeListener(_refreshComposer);
    _focusNode.removeListener(_refreshComposer);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _useSuggestion(String suggestion) {
    _controller.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
    _focusNode.requestFocus();
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
      setState(() => _isProcessingReceipt = true);
      final result = switch (action) {
        ReceiptInputAction.manualEntry => null,
        ReceiptInputAction.importFile =>
          await widget.receiptInputService.importFile(),
        ReceiptInputAction.scanReceipt =>
          await widget.receiptInputService.scanReceipt(),
      };
      if (result == null || result.isEmpty || !mounted) return;
      final submit = widget.onReceiptSubmit;
      if (submit == null) {
        _showResult(result);
      } else {
        await submit(result);
      }
    } on StateError catch (error) {
      if (mounted) showAppToast(context, error.message);
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _isProcessingReceipt = false);
    }
  }

  void _showResult(ReceiptInputResult result) {
    final label = result.source == ReceiptInputSource.importedFile
        ? 'File imported'
        : 'Receipt scanned';
    showInfoToast(context, '$label and ready for AI extraction.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = widget.isSubmitting || _isProcessingReceipt;
    final showSuggestions =
        _focusNode.hasFocus && _controller.text.trim().isEmpty && !isBusy;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChatSuggestionsReveal(
          visible: showSuggestions,
          child: ChatInputSuggestions(
            suggestions: [
              context.l10n.expenseSuggestion,
              context.l10n.incomeSuggestion,
              context.l10n.transferSuggestion,
            ],
            onSelected: _useSuggestion,
          ),
        ),
        Container(
          key: const Key('chat-input-container'),
          constraints: const BoxConstraints(minHeight: 46, maxHeight: 110),
          margin: const EdgeInsets.only(left: 28, right: 26),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: isBusy ? null : _showReceiptOptions,
                icon: const Icon(Icons.add_rounded, size: 26),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 51, height: 46),
                tooltip: context.l10n.addReceipt,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !isBusy,
                  minLines: 1,
                  maxLines: 4,
                  cursorColor: theme.colorScheme.inverseSurface,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintText: context.l10n.chatHint,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: AppTypography.supporting,
                    ),
                  ),
                  textInputAction: TextInputAction.newline,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),
              ChatSendButton(
                key: Key(
                  widget.isQuotaExhausted ? 'manual-entry-send' : 'ai-send',
                ),
                isBusy: isBusy,
                isManualEntry: widget.isQuotaExhausted,
                onPressed: isBusy
                    ? null
                    : widget.isQuotaExhausted
                        ? widget.onManualEntryRequested
                        : _submit,
                tooltip: widget.isQuotaExhausted
                    ? context.l10n.manualEntry
                    : context.l10n.send,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
