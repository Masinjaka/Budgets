import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/core/legal/legal_document_launcher.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/auth/presentation/widgets/legal_consent_checkbox.dart';
import 'package:budgets/features/auth/presentation/widgets/sign_up_submit_bar.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({
    this.legalLauncher = const UrlLegalDocumentLauncher(),
    super.key,
  });

  final LegalDocumentLauncher legalLauncher;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _hasAcceptedLegalTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildForm(context)),
      bottomNavigationBar: SignUpSubmitBar(
        isLoading: _isLoading,
        isEnabled: _hasAcceptedLegalTerms,
        onPressed: _submit,
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Créer un compte',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppTypography.title,
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.close,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Commençons d’abord par vous créer un compte',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppTypography.body,
                    ),
                  ),
                  SizedBox(height: 64),
                  CustomTextField(
                    title: Text(
                      "Nom d'utilisateur",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: AppTypography.body,
                      ),
                    ),
                    hint: 'username',
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    title: Text(
                      'Email',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: AppTypography.body,
                      ),
                    ),
                    hint: 'example@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    title: Text(
                      'Mot de passe',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: AppTypography.body,
                      ),
                    ),
                    hint: 'votre mot de passe',
                    controller: _passwordController,
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
                    hint: 'votre mot de passe',
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    validator: const <String, String>{"type": "password"},
                  ),
                  const SizedBox(height: 32),
                  LegalConsentCheckbox(
                    value: _hasAcceptedLegalTerms,
                    launcher: widget.legalLauncher,
                    onChanged: (value) {
                      setState(() => _hasAcceptedLegalTerms = value);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      showInfoToast(context, 'Vérifiez la correspondance du mot de passe');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim(),
          );
      if (mounted) context.push('/upload-profile-photo');
    } catch (error, stackTrace) {
      debugPrint('[SignUpPage] signUp submission error: $error');
      debugPrint('[SignUpPage] signUp submission stackTrace: $stackTrace');
      if (mounted) showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
