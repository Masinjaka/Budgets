import 'package:budgets/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashModule {

  SplashModule();

  /// function to listen for auth session
  /// this will navigate to screens depending on either the user is logged in or not
  void listeToSession(WidgetRef ref, BuildContext context) async {

    await Future.delayed(const Duration(seconds: 2));

    supabase.auth.onAuthStateChange.listen(
      (data) {
        
        if(!context.mounted) return;
        
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        switch (event) {
          case AuthChangeEvent.signedIn:
            // Navigate to home screen
            context.go('/home');
            break;
          case AuthChangeEvent.signedOut:
            // Navigate to login screen
            context.go('/login');
            break;
          case AuthChangeEvent.initialSession:
            String pagePath = session!=null ? '/home' : '/login';

            context.go(pagePath);
            break;
          default:
        }

      },
    );
  }
}
