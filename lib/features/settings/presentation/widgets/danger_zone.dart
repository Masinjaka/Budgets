import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/settings/presentation/view_models/danger_zone_view_model.dart';
import 'package:budgets/features/settings/presentation/widgets/danger_action_card.dart';
import 'package:budgets/features/settings/presentation/widgets/destructive_confirmation_dialog.dart';
import 'package:budgets/features/settings/presentation/widgets/setting_section.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

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
      builder: (context, _) => SettingSection(
        title: 'Zone de danger',
        children: [
          SizedBox(height: 1.h),
          DangerActionCard(
            actionKey: const Key('delete-all-data-button'),
            title: 'Supprimer toutes mes données',
            description: 'Efface définitivement tout le contenu de l’app.',
            icon: Icons.delete_sweep_outlined,
            isLoading: viewModel.busyAction == DangerZoneAction.deleteData,
            onTap: viewModel.isBusy ? null : () => _deleteData(context),
          ),
          SizedBox(height: 1.h),
          DangerActionCard(
            actionKey: const Key('delete-account-button'),
            title: 'Supprimer mon compte',
            description: 'Efface les données et désactive votre connexion.',
            icon: Icons.person_off_outlined,
            isLoading: viewModel.busyAction == DangerZoneAction.deleteAccount,
            onTap: viewModel.isBusy ? null : () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteData(BuildContext context) async {
    final confirmation = await showDialog<String>(
      context: context,
      builder: (_) => const DestructiveConfirmationDialog(
        title: 'Supprimer toutes les données ?',
        description: 'Transactions, portefeuilles, enveloppes, budgets, '
            'objectifs, historique IA, préférences et fichiers seront '
            'effacés. Votre compte et votre formule seront conservés.',
        expectedConfirmation: 'SUPPRIMER',
        instruction: 'Saisissez SUPPRIMER pour confirmer.',
      ),
    );
    if (confirmation == null || !context.mounted) return;
    try {
      await viewModel.deleteAllData(confirmation);
      if (!context.mounted) return;
      showSuccessToast(context, 'Toutes vos données ont été supprimées.');
      onDataDeleted();
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmation = await showDialog<String>(
      context: context,
      builder: (_) => DestructiveConfirmationDialog(
        title: 'Supprimer définitivement le compte ?',
        description: 'Cette action efface votre compte, votre formule, vos '
            'fichiers et toutes vos données. Elle est irréversible.',
        expectedConfirmation: accountEmail,
        instruction: 'Saisissez $accountEmail pour confirmer.',
      ),
    );
    if (confirmation == null || !context.mounted) return;
    try {
      await viewModel.deleteAccount(confirmation);
      if (!context.mounted) return;
      showSuccessToast(context, 'Votre compte a été supprimé.');
      onAccountDeleted();
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
    }
  }
}
