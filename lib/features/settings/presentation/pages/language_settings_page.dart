import 'package:budgets/features/settings/domain/providers/locale_provider.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_choice_tile.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_menu_group.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_page_shell.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = context.l10n;
    final selected = ref.watch(localeProvider).languageCode;
    return SettingsPageShell(
      title: localizations.language,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
        children: [
          SettingsMenuGroup(
            items: [
              _choice(ref, selected, 'en', localizations.english, '🇬🇧'),
              _choice(ref, selected, 'fr', localizations.french, '🇫🇷'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _choice(
    WidgetRef ref,
    String selected,
    String languageCode,
    String label,
    String emoji,
  ) =>
      SettingsChoiceTile(
        title: label,
        leading: Text(emoji, style: const TextStyle(fontSize: 20)),
        trailing: selected == languageCode
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: () =>
            ref.read(localeProvider.notifier).setLocale(Locale(languageCode)),
      );
}
