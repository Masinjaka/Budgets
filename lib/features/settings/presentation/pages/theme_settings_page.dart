import 'package:budgets/features/settings/domain/providers/theme_provider.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_choice_tile.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_menu_group.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_page_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);
    return SettingsPageShell(
      title: context.l10n.theme,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
        children: [
          SettingsMenuGroup(
            items: [
              _choice(ref, current, ThemeMode.light, ThemeOptions.light,
                  context.l10n.light, Icons.light_mode_outlined),
              _choice(ref, current, ThemeMode.dark, ThemeOptions.dark,
                  context.l10n.dark, Icons.dark_mode_outlined),
              _choice(ref, current, ThemeMode.system, ThemeOptions.system,
                  context.l10n.system, Icons.brightness_auto_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _choice(
    WidgetRef ref,
    ThemeMode current,
    ThemeMode mode,
    ThemeOptions option,
    String label,
    IconData icon,
  ) {
    return SettingsChoiceTile(
      title: label,
      leading: Icon(icon, size: 20),
      trailing: current == mode
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () => ref.read(themeProvider.notifier).setTheme(option),
    );
  }
}
