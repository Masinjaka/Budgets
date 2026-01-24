import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthenticationUtils {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<void> authenticateAndShow(
    BuildContext context,
    String localizedReason,
    VoidCallback onAuthenticated,
  ) async {
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        // Device doesn't support biometrics, show directly
        onAuthenticated();
        return;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        authMessages: const [],
      );

      if (didAuthenticate) {
        onAuthenticated();
      }
    } on PlatformException catch (e) {
      // Handle authentication errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'authentification: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}