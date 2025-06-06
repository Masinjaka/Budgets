import 'package:budgets/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AuthModule {
  AuthModule();

  // Sign in
  Future<void> signIn({
    required String email,
    required String password,
    required BuildContext context,
    required WidgetRef ref,
    required GlobalKey<FormState> formKey,
  }) async {
    if (formKey.currentState!.validate()) {
      try {
        await ref
            .read(authProvider.notifier)
            .signInWithEmailAndPassword(email, password);

        final user = await ref.watch(authProvider.future);

        if (user.name != null) {

          debugPrint("User upon login is not null");

          if (!context.mounted) return;
          context.go('/home');
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  // Sign up
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    required String confirmedPassword,
    required BuildContext context,
    required WidgetRef ref,
    required GlobalKey<FormState> formKey,
  }) async {
    if (formKey.currentState!.validate()) {
      if (password != confirmedPassword) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verifier le mot de passe')));
        return;
      }

      try {
        await ref
            .read(authProvider.notifier)
            .signUpWithEmailAndPassword(email, password, username);

        final user = await ref.watch(authProvider.future);

        if (user.name != null) {
          if (!context.mounted) return;
          context.go('/home');
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
