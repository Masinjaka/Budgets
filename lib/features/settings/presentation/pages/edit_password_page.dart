import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_page_shell.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditPasswordPage extends ConsumerStatefulWidget {
  const EditPasswordPage({super.key});

  @override
  ConsumerState<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends ConsumerState<EditPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (_, next) {
      next.whenOrNull(error: (error, _) => showErrorToast(context, error));
    });
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SettingsPageShell(
        title: context.l10n.changePassword,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
            children: [
              _field(
                title: context.l10n.currentPassword,
                hint: context.l10n.enterCurrentPassword,
                controller: _currentController,
              ),
              const SizedBox(height: 20),
              _field(
                title: context.l10n.newPassword,
                hint: context.l10n.enterNewPassword,
                controller: _newController,
              ),
              const SizedBox(height: 20),
              _field(
                title: context.l10n.confirmPassword,
                hint: context.l10n.confirmNewPassword,
                controller: _confirmController,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: context.l10n.save,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  CustomTextField _field({
    required String title,
    required String hint,
    required TextEditingController controller,
  }) {
    return CustomTextField(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w800,
        ),
      ),
      hint: hint,
      controller: controller,
      keyboardType: TextInputType.visiblePassword,
      isPassword: true,
      validator: const {'type': 'password'},
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_newController.text != _confirmController.text) {
      showInfoToast(context, context.l10n.passwordsDoNotMatch);
      return;
    }
    if (_currentController.text == _newController.text) {
      showInfoToast(context, context.l10n.passwordMustDiffer);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).changePassword(
            currentPassword: _currentController.text,
            newPassword: _newController.text,
          );
      if (!mounted) return;
      showSuccessToast(context, context.l10n.passwordUpdated);
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
