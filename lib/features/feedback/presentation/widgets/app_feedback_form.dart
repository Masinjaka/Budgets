import 'dart:async';

import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

class AppFeedbackForm extends StatefulWidget {
  const AppFeedbackForm({
    required this.onSubmit,
    required this.scrollController,
    super.key,
  });

  final OnSubmit onSubmit;
  final ScrollController? scrollController;

  @override
  State<AppFeedbackForm> createState() => _AppFeedbackFormState();
}

class _AppFeedbackFormState extends State<AppFeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);
    await widget.onSubmit(_controller.text.trim());
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          children: [
            if (widget.scrollController != null)
              const FeedbackSheetDragHandle(),
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                child: Form(
                  key: _formKey,
                  child: CustomTextField(
                    key: const Key('feedback-text-field'),
                    title: Text(
                      context.l10n.feedbackPrompt,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    hint: context.l10n.feedbackHint,
                    controller: _controller,
                    minLines: 3,
                    maxLines: 5,
                    borderRadius: BorderRadius.circular(16),
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.all(14),
                    validator: {
                      'type': 'required',
                      'error': context.l10n.feedbackRequired,
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              key: const Key('feedback-submit-button'),
              text: context.l10n.sendFeedback,
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : () => unawaited(_submit()),
            ),
          ],
        ),
      ),
    );
  }
}
