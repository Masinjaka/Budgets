import 'dart:async';
import 'package:budgets/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashModule {
  SplashModule();

  StreamSubscription<AuthState>? _sub;

  /// Listen for auth session and navigate accordingly
  void listeToSession(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));

    // 1) One-shot check
    final hasSession = supabase.auth.currentSession != null;
    if (!context.mounted) return;
    context.go(hasSession ? '/home' : '/getting-started');

    // 2) Subscribe for subsequent auth changes (once)
    _sub ??= supabase.auth.onAuthStateChange.listen((data) {
      if (!context.mounted) return;
      switch (data.event) {
        case AuthChangeEvent.signedIn:
          context.go('/home');
          break;
        case AuthChangeEvent.signedOut:
          context.go('/login');
          break;
        default:
          // ignore other events, including initialSession (already handled)
          break;
      }
    });
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
