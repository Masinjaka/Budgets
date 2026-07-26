import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:budgets/l10n/generated/app_localizations_en.dart';
import 'package:flutter/widgets.dart';

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppLocalizationsEn();
}
