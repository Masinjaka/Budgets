import 'package:budgets/pages/auth/module/auth_module.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController = TextEditingController();
  final AuthModule authModule = AuthModule();
  bool _isLoading = false;


  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildForm(),
      bottomNavigationBar: _buildBottomPart(context),
    );
  }

  _buildForm() {
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
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    'Creer un compte',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 23.sp,
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  CustomTextField(
                    title: "Nom d'utilisateur",
                    hint: 'username',
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 1.5.h),
                  CustomTextField(
                    title: 'Email',
                    hint: 'example@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 1.5.h),
                  CustomTextField(
                    title: 'Mot de passe',
                    hint: 'votre mot de passe',
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    validator: const <String, String>{"type": "password"},
                  ),
                  SizedBox(height: 1.5.h),
                  CustomTextField(
                    title: 'Confirmer le mot de passe',
                    hint: 'votre mot de passe',
                    controller: _confirmpasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    isPassword: true,
                    validator: const <String, String>{"type": "password"},
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildBottomPart(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: 'Se connecter',
            style: TextStyle(
              fontSize: 15.5.sp,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if(!mounted) return;

                context.go('/login');
              },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
          child: CustomButton(
            text: 'Creer un compte',
            isLoading: _isLoading,
            onPressed: () async {
              // start authenticating
              setState(() => _isLoading = true);
              await authModule.signUp(
                context: context,
                ref: ref,
                email: _emailController.text.trim(),
                password: _passwordController.text,
                username: _usernameController.text.trim(),
                confirmedPassword: _confirmpasswordController.text,
                formKey: _formKey,
              );
              setState(() => _isLoading = false);
              // end authenticating
            },
          ),
        ),
      ],
    );
  }
}