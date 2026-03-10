import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/core/ui/app_toast.dart';
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
          debugPrint('[LoginPage] Auth state error: $e');
          debugPrint('[LoginPage] Auth state stackTrace: $st');
          if (!mounted) return;
          showErrorToast(context, e);
        },
      );
    });

    return Scaffold(
      body: SafeArea(child: _buildForm(context)),
      bottomNavigationBar: _buildBottomPart(),
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
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Se connecter',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20.5.sp,
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.close,
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Connectez-vous et gérez votre drala comme un pro',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15.5.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
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
                  SizedBox(height: 2.h),
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
                  SizedBox(height: 2.5.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text.rich(
                      TextSpan(
                        text: 'Mot de passe oublié?',
                        style: TextStyle(
                          fontSize: 15.5.sp,
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

  Widget _buildBottomPart() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: CustomButton(
            text: 'Se connecter',
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;

              setState(() => _isLoading = true);
              try {
                debugPrint('[LoginPage] Submit pressed - signIn started');
                await ref.read(authControllerProvider.notifier).signIn(
                      email: _emailController.text.trim(),
                      password: _passwordController.text,
                    );
                debugPrint(
                    '[LoginPage] signIn completed - navigating to /home');
                if (!mounted) return;
                context.go('/home');
              } catch (e, st) {
                debugPrint('[LoginPage] signIn submission error: $e');
                debugPrint('[LoginPage] signIn submission stackTrace: $st');
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }
}
