// ignore_for_file: use_build_context_synchronously

import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EditPasswordPage extends ConsumerStatefulWidget {
  const EditPasswordPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditPasswordPageState();
}

class _EditPasswordPageState extends ConsumerState<EditPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (e, st) {
          showErrorToast(context, e);
        },
      );
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Modifier le mot de passe',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 10.h,
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      title: Text(
                        'Mot de passe actuel',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5.sp,
                        ),
                      ),
                      hint: 'Votre mot de passe actuel',
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      isPassword: true,
                      validator: const <String, String>{"type": "password"},
                    ),
                    SizedBox(height: 2.h),
                    CustomTextField(
                      title: Text(
                        'Nouveau mot de passe',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5.sp,
                        ),
                      ),
                      hint: 'Votre nouveau mot de passe',
                      controller: _newPasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      isPassword: true,
                      validator: const <String, String>{"type": "password"},
                    ),
                    SizedBox(height: 2.h),
                    CustomTextField(
                      title: Text(
                        'Confirmer votre mot de passe',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5.sp,
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
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: CustomButton(
            text: 'Sauvegarder',
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              // Check if new passwords match
              if (_newPasswordController.text !=
                  _confirmPasswordController.text) {
                showInfoToast(
                  context,
                  'Les nouveaux mots de passe ne correspondent pas',
                );
                return;
              }

              // Check if new password is different from current
              if (_passwordController.text == _newPasswordController.text) {
                showInfoToast(
                  context,
                  'Le nouveau mot de passe doit être différent de l\'actuel',
                );
                return;
              }

              setState(() => _isLoading = true);
              try {
                await ref.read(authControllerProvider.notifier).changePassword(
                      currentPassword: _passwordController.text,
                      newPassword: _newPasswordController.text,
                    );

                if (!mounted) return;
                showSuccessToast(
                  context,
                  'Mot de passe modifié avec succès',
                );

                if (!mounted) return;
                context.pop();
              } catch (_) {
                // Error handling is done by the listener above
              }
              setState(() => _isLoading = false);
            },
            isLoading: _isLoading,
          ),
        ),
      ),
    );
  }
}
