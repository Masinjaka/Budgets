// ignore_for_file: use_build_context_synchronously

import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/auth/presentation/widgets/reset_code_otp_row.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class VerifyResetCodePage extends ConsumerStatefulWidget {
  const VerifyResetCodePage({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyResetCodePage> createState() =>
      _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends ConsumerState<VerifyResetCodePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _otpFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Nouveau mot de passe',
            style: TextStyle(fontSize: AppTypography.title),
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Un code a été envoyé à',
                      style: const TextStyle(
                        fontSize: AppTypography.body,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: const TextStyle(
                        fontSize: AppTypography.body,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 32),
                    Text(
                      'Code de vérification',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: AppTypography.body,
                      ),
                    ),
                    SizedBox(height: 8),
                    ResetCodeOtpRow(
                      controllers: _otpControllers,
                      focusNodes: _otpFocusNodes,
                    ),
                    SizedBox(height: 24),
                    CustomTextField(
                      title: Text(
                        'Nouveau mot de passe',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: AppTypography.body,
                        ),
                      ),
                      hint: 'Votre nouveau mot de passe',
                      controller: _newPasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      isPassword: true,
                      validator: const <String, String>{"type": "password"},
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      title: Text(
                        'Confirmer le mot de passe',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: AppTypography.body,
                        ),
                      ),
                      hint: 'Confirmer votre nouveau mot de passe',
                      controller: _confirmPasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      isPassword: true,
                      validator: const <String, String>{"type": "password"},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: CustomButton(
            text: 'Réinitialiser',
            isLoading: _isLoading,
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              if (_otpCode.length != 6) {
                showInfoToast(
                  context,
                  'Veuillez entrer le code à 6 chiffres',
                );
                return;
              }

              if (_newPasswordController.text !=
                  _confirmPasswordController.text) {
                showInfoToast(
                  context,
                  'Les mots de passe ne correspondent pas',
                );
                return;
              }

              setState(() => _isLoading = true);
              try {
                await ref
                    .read(authControllerProvider.notifier)
                    .verifyOtpAndResetPassword(
                      email: widget.email,
                      otp: _otpCode,
                      newPassword: _newPasswordController.text,
                    );

                if (!mounted) return;
                showSuccessToast(
                  context,
                  'Mot de passe réinitialisé avec succès',
                );
                context.go('/login');
              } catch (e) {
                if (mounted) showErrorToast(context, e);
              }
              if (mounted) setState(() => _isLoading = false);
            },
          ),
        ),
      ),
    );
  }
}
