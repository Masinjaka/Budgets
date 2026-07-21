import 'package:budgets/core/navigation/auth_router_refresh.dart';
import 'package:budgets/features/auth/presentation/pages/login_page.dart';
import 'package:budgets/features/auth/presentation/pages/reset_password_page.dart';
import 'package:budgets/features/auth/presentation/pages/sign_up_page.dart';
import 'package:budgets/features/auth/presentation/pages/upload_profile_photo_page.dart';
import 'package:budgets/features/auth/presentation/pages/verify_reset_code_page.dart';
import 'package:budgets/features/home/presentation/pages/chat_home_page.dart';
import 'package:budgets/features/onboarding/presentation/pages/getting_started_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppNavigation {
  AppNavigation({
    required bool Function() isSignedIn,
    required Stream<Object?> authChanges,
  })  : _isSignedIn = isSignedIn,
        _refresh = AuthRouterRefresh(authChanges) {
    router = GoRouter(
      initialLocation: _isSignedIn() ? '/home' : '/getting-started',
      refreshListenable: _refresh,
      redirect: _redirect,
      routes: [
        GoRoute(
          path: '/getting-started',
          builder: (_, __) => const GettingStartedPage(),
        ),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/signup', builder: (_, __) => const SignUpPage()),
        GoRoute(
          path: '/reset-password',
          builder: (_, __) => const ResetPasswordPage(),
        ),
        GoRoute(
          path: '/verify-reset-code',
          redirect: (_, state) =>
              state.extra is String ? null : '/reset-password',
          builder: (_, state) => VerifyResetCodePage(
            email: state.extra! as String,
          ),
        ),
        GoRoute(
          path: '/upload-profile-photo',
          builder: (_, __) => const UploadProfilePhotoPage(),
        ),
        GoRoute(path: '/home', builder: (_, __) => const ChatHomePage()),
      ],
    );
  }

  factory AppNavigation.supabase(SupabaseClient client) => AppNavigation(
        isSignedIn: () => client.auth.currentSession != null,
        authChanges: client.auth.onAuthStateChange,
      );

  final bool Function() _isSignedIn;
  final AuthRouterRefresh _refresh;
  late final GoRouter router;

  static const _publicPaths = {
    '/getting-started',
    '/login',
    '/signup',
    '/reset-password',
    '/verify-reset-code',
  };

  String? _redirect(BuildContext context, GoRouterState state) {
    final isSignedIn = _isSignedIn();
    final isPublic = _publicPaths.contains(state.matchedLocation);
    if (!isSignedIn && !isPublic) return '/getting-started';
    if (isSignedIn && isPublic) return '/home';
    return null;
  }

  void dispose() {
    router.dispose();
    _refresh.dispose();
  }
}
