import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (e, st) {
          if (!mounted) return;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$e')));
        },
      );
    });

    return Scaffold(
      body: _buildForm(context),
      bottomNavigationBar: _buildBottomPart(context),
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
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    'Connexion',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 23.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  CustomTextField(
                    title: Text(
                      'Email',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5.sp,
                      ),
                    ),
                    hint: 'example@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 1.5.h),
                  CustomTextField(
                    title: Text(
                      'Mot de passe',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5.sp,
                      ),
                    ),
                    hint: 'votre mot de passe',
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                  ),
                  SizedBox(height: 2.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text.rich(
                      TextSpan(
                        text: 'Mot de passe oublié?',
                        style: TextStyle(
                          fontSize: 15.5.sp,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (!mounted) return;
                            context.push('/reset-password');
                          },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPart(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: 'Créer un compte',
            style: TextStyle(
              fontSize: 15.5.sp,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (!mounted) return;
                context.go('/signup');
              },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
          child: CustomButton(
            text: 'Se connecter',
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              setState(() => _isLoading = true);
              try {
                await ref.read(authControllerProvider.notifier).signIn(
                      email: _emailController.text.trim(),
                      password: _passwordController.text,
                    );
                if (!mounted) return;
                context.go('/home');
              } catch (_) {}
              setState(() => _isLoading = false);
            },
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }
}
