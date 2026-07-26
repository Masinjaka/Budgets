// ignore_for_file: use_build_context_synchronously

import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (e, st) {
          showErrorToast(context, e);
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Réinitialisation',
          style: TextStyle(fontSize: AppTypography.title),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                title: Text(
                  'Email',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: AppTypography.body,
                  ),
                ),
                hint: 'example@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 24),
              CustomButton(
                text: 'Envoyer le lien',
                isLoading: _isLoading,
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isLoading = true);
                  try {
                    await ref
                        .read(authControllerProvider.notifier)
                        .resetPassword(
                          email: _emailController.text.trim(),
                        );
                    if (!mounted) return;
                    showSuccessToast(context, 'Email envoyé');
                    context.push(
                      '/verify-reset-code',
                      extra: _emailController.text.trim(),
                    );
                  } catch (_) {}
                  setState(() => _isLoading = false);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
