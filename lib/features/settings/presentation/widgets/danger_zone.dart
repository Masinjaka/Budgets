import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/settings/presentation/view_models/danger_zone_view_model.dart';
import 'package:budgets/features/settings/presentation/widgets/danger_action_card.dart';
import 'package:budgets/features/settings/presentation/widgets/destructive_confirmation_dialog.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_menu_group.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_section_title.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class DangerZone extends StatelessWidget {
  const DangerZone({
    required this.viewModel,
    required this.accountEmail,
    required this.onDataDeleted,
    required this.onAccountDeleted,
    super.key,
  });

  final DangerZoneViewModel viewModel;
  final String accountEmail;
  final VoidCallback onDataDeleted;
  final VoidCallback onAccountDeleted;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSectionTitle(context.l10n.dangerZone),
          const SizedBox(height: 12),
          SettingsMenuGroup(
            items: [
              DangerActionCard(
                actionKey: const Key('delete-all-data-button'),
                title: context.l10n.deleteAllData,
                description: context.l10n.deleteAllDataSummary,
                icon: Icons.delete_sweep_outlined,
                isLoading: viewModel.busyAction == DangerZoneAction.deleteData,
                onTap: viewModel.isBusy ? null : () => _deleteData(context),
              ),
              DangerActionCard(
                actionKey: const Key('delete-account-button'),
                title: context.l10n.deleteAccount,
                description: context.l10n.deleteAccountSummary,
                icon: Icons.person_off_outlined,
                isLoading:
                    viewModel.busyAction == DangerZoneAction.deleteAccount,
                onTap: viewModel.isBusy ? null : () => _deleteAccount(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteData(BuildContext context) async {
    final confirmation = await showDialog<String>(
      context: context,
      builder: (_) => DestructiveConfirmationDialog(
        title: context.l10n.deleteAllDataQuestion,
        description: context.l10n.deleteAllDataDetails,
        expectedConfirmation: context.l10n.deleteKeyword,
        instruction: context.l10n.typeDeleteToConfirm,
      ),
    );
    if (confirmation == null || !context.mounted) return;
    try {
      await viewModel.deleteAllData(confirmation);
      if (!context.mounted) return;
      showSuccessToast(context, context.l10n.allDataDeleted);
      onDataDeleted();
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmation = await showDialog<String>(
      context: context,
      builder: (_) => DestructiveConfirmationDialog(
        title: context.l10n.deleteAccountQuestion,
        description: context.l10n.deleteAccountDetails,
        expectedConfirmation: accountEmail,
        instruction: context.l10n.typeValueToConfirm(accountEmail),
      ),
    );
    if (confirmation == null || !context.mounted) return;
    try {
      await viewModel.deleteAccount(confirmation);
      if (!context.mounted) return;
      showSuccessToast(context, context.l10n.accountDeleted);
      onAccountDeleted();
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
    }
  }
}
