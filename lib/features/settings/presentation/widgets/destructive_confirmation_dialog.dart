import 'package:budgets/core/theme.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class DestructiveConfirmationDialog extends StatefulWidget {
  const DestructiveConfirmationDialog({
    required this.title,
    required this.description,
    required this.expectedConfirmation,
    required this.instruction,
    super.key,
  });

  final String title;
  final String description;
  final String expectedConfirmation;
  final String instruction;

  @override
  State<DestructiveConfirmationDialog> createState() =>
      _DestructiveConfirmationDialogState();
}

class _DestructiveConfirmationDialogState
    extends State<DestructiveConfirmationDialog> {
  final _controller = TextEditingController();
  var _matches = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateMatch);
  }

  void _updateMatch() {
    final matches = _controller.text.trim() == widget.expectedConfirmation;
    if (matches != _matches) setState(() => _matches = matches);
  }

  void _confirm() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  void dispose() {
    _controller.removeListener(_updateMatch);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.description),
            const SizedBox(height: 16),
            CustomTextField(
              key: const Key('danger-confirmation-field'),
              controller: _controller,
              title: Text(
                widget.instruction,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              hint: 'Confirmation',
              fillColor: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              fontSize: 14,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          key: const Key('danger-confirm-button'),
          onPressed: _matches ? _confirm : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.dangerColor,
            foregroundColor: AppTheme.interactiveTextColor,
          ),
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}
