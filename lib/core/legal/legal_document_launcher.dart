import 'package:url_launcher/url_launcher.dart';

abstract interface class LegalDocumentLauncher {
  Future<void> openPrivacyPolicy();

  Future<void> openTermsAndConditions();
}

class UrlLegalDocumentLauncher implements LegalDocumentLauncher {
  const UrlLegalDocumentLauncher();

  static final Uri privacyPolicyUri = Uri.parse(
    'https://drala-landing-page.vercel.app/privacy',
  );
  static final Uri termsAndConditionsUri = Uri.parse(
    'https://drala-landing-page.vercel.app/terms',
  );

  @override
  Future<void> openPrivacyPolicy() => _open(privacyPolicyUri);

  @override
  Future<void> openTermsAndConditions() => _open(termsAndConditionsUri);

  Future<void> _open(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      throw StateError('Could not open $uri');
    }
  }
}
