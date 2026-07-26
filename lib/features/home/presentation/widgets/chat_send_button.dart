import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';

class ChatSendButton extends StatelessWidget {
  const ChatSendButton({
    required this.isBusy,
    required this.isManualEntry,
    required this.onPressed,
    required this.tooltip,
    super.key,
  });

  final bool isBusy;
  final bool isManualEntry;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: isBusy
            ? const SizedBox.square(
                key: ValueKey('chat-send-loading'),
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : isManualEntry
                ? const Icon(
                    Icons.edit_note_rounded,
                    key: ValueKey('chat-send-manual'),
                    size: 27,
                  )
                : const CircleAvatar(
                    key: ValueKey('chat-send-arrow'),
                    radius: 17,
                    backgroundColor: AppTheme.primaryGreen,
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      size: 22,
                      color: Colors.black,
                    ),
                  ),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 53, height: 46),
      tooltip: tooltip,
    );
  }
}
