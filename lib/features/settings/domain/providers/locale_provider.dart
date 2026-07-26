import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'selected_locale';
const supportedAppLocales = [Locale('en'), Locale('fr')];

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  var _changedByUser = false;

  @override
  Locale build() {
    _load();
    return _supported(PlatformDispatcher.instance.locale);
  }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_localeKey);
    if (languageCode != null && !_changedByUser) {
      state = _supported(Locale(languageCode));
    }
  }

  Future<void> setLocale(Locale locale) async {
    _changedByUser = true;
    state = _supported(locale);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_localeKey, state.languageCode);
  }

  Locale _supported(Locale locale) =>
      locale.languageCode == 'fr' ? const Locale('fr') : const Locale('en');
}
