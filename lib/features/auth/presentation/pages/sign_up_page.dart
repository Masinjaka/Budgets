import 'package:budgets/features/auth/presentation/controllers/auth_controller.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
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
      body: SafeArea(child: _buildForm(context)),
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
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20.5.sp,
                        ),
                      ),
                      IconButton(onPressed: () => context.pop(), icon: Icon(Icons.close,size: 20.sp,),),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Commençons d’abord par vous créer un compte',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15.5.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextField(
                    title: Text(
                      "Nom d'utilisateur",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5.sp,
                      ),
                    ),
                    hint: 'username',
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 2.h),
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
                    validator: const <String, String>{"type": "password"},
                  ),
                  SizedBox(height: 2.h),
                  CustomTextField(
                    title: Text(
                      'Confirmer le mot de passe',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5.sp,
                      ),
                    ),
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

  Widget _buildBottomPart(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            text: 'Suivant',
            isLoading: _isLoading,
            onPressed: () async {
              if (!_formKey.currentState!.validate()) return;
              if (_passwordController.text != _confirmpasswordController.text) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vérifier le mot de passe')));
                return;
              }
                
              setState(() => _isLoading = true);
              try {
                await ref.read(authControllerProvider.notifier).signUp(
                      email: _emailController.text.trim(),
                      password: _passwordController.text,
                      username: _usernameController.text.trim(),
                    );
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                context.push('/upload-profile-photo');
              } catch (_) {}
              setState(() => _isLoading = false);
            },
          ),
        ],
      ),
    );
  }
}
