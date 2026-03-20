import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/domain/providers/transaction_provider.dart';
import 'package:budgets/widgets/skeleton/home_skeletons.dart';
import 'package:budgets/features/categories/domain/providers/filter_provider.dart';
import 'package:budgets/widgets/custom_transaction_card.dart';
import 'package:budgets/features/home/presentation/widgets/custom_greeting_app_bar.dart';
import 'package:budgets/features/home/presentation/widgets/jumbotron.dart';
import 'package:budgets/features/home/presentation/widgets/section_title.dart';
import 'package:budgets/features/home/presentation/widgets/stats_home_widget.dart';
import 'package:budgets/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:budgets/features/home/domain/providers/notification_permission_provider.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTransactions = ref.watch(transactionsProvider);
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final dateRange = ref.watch(dateRangeProvider);
    final prompted = ref.watch(notificationPermissionPromptedProvider);
    if (!prompted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final alreadyPrompted =
            ref.read(notificationPermissionPromptedProvider);
        if (alreadyPrompted) return;
        ref
            .read(notificationPermissionPromptedProvider.notifier)
            .setPrompted();
        await _maybeRequestNotificationPermission(context, ref);
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: const CustomGreetingAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            // physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: 2.h),
                const Jumbotron(),
                SizedBox(height: 3.h),
                SectionTitle(
                  title: 'Activités récentes',
                  onTap: () {
                    context.go('/transaction-list');
                  },
                ),
                SizedBox(height: 2.h),
                switch (asyncTransactions) {
                  AsyncData(:final value) => _buildTransactionList(
                      context, value, selectedCategories, dateRange),
                  AsyncError(:final error) => Text('error: $error'),
                  _ => const TransactionListSkeleton(),
                },
                SizedBox(height: 3.h),
                SectionTitle(
                  title: 'Vue d\'ensemble',
                  onTap: () {
                    context.go('/stats');
                  },
                ),
                SizedBox(height: 3.h),
                StatsHomeWidget(asyncExpenses: asyncTransactions),
              ],
            ),
          ),
        ),
      ),
    );
  }

  RenderObjectWidget _buildTransactionList(
    BuildContext context,
    List<TransactionModel> transactions,
    List<String?> selectedCategories,
    DateTimeRange? dateRange,
  ) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('Vous n\' avez pas encore de depense'),
      );
    }

    if (selectedCategories.isNotEmpty) {
      transactions = transactions
          .where((transaction) =>
              selectedCategories.contains(transaction.category?.name))
          .toList();
    }

    if (dateRange != null) {
      transactions = transactions.where((transaction) {
        final transactionDate = transaction.date!;
        return transactionDate.isAfter(dateRange.start) &&
            transactionDate
                .isBefore(dateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    transactions.sort((a, b) => b.date!.compareTo(a.date!));

    transactions = transactions.take(4).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: transactions
          .map(
            (e) => TransactionTile(
              designation: e.title ?? "Designation inconnue",
              category: e.category?.name ?? "Categorie inconnue",
              amount: e.amount?.toString() ?? "Montant inconnue",
              date: e.date!,
              categoryColor: (e.category?.color != null)
                  ? Color(int.parse(e.category!.color!, radix: 16))
                  : Theme.of(context).colorScheme.surfaceDim,
              categoryEmoji: e.category?.emoji ?? '❓',
              description: e.description ?? "Aucune description",
              categoryId: e.category?.id ?? "",
              transactionType: e.transactionType?.value ?? "expense",
            ),
          )
          .toList(),
    );
  }
}

Future<void> _maybeRequestNotificationPermission(
  BuildContext context,
  WidgetRef ref,
) async {
  final status = await Permission.notification.status;
  if (status.isGranted) {
    await ref.read(notificationControllerProvider.notifier).registerIfEnabled();
    return;
  }

  if (status.isPermanentlyDenied || status.isRestricted) {
    if (!context.mounted) return;
    final openedSettings = await showAnimatedDialog<bool>(
      context: context,
      builder: (context) {
        return PermissionRequestDialog(
          title: 'Notifications bloquées',
          message:
              'Les notifications ont été bloquées pour cette application. '
              'Pour les réactiver, veuillez accéder aux paramètres de votre '
              'appareil et autoriser les notifications.',
          allowText: 'Ouvrir les paramètres',
          denyText: 'Annuler',
          onAllow: () async {
            await openAppSettings();
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          onDeny: () => Navigator.of(context).pop(false),
        );
      },
    );
    // Re-check permission after returning from settings
    if (openedSettings == true && context.mounted) {
      final newStatus = await Permission.notification.status;
      if (newStatus.isGranted) {
        await ref
            .read(notificationControllerProvider.notifier)
            .registerIfEnabled();
      }
    }
    return;
  }

  if (!context.mounted) return;
  final allow = await showAnimatedDialog<bool>(
    context: context,
    builder: (context) {
      return PermissionRequestDialog(
        title: 'Activer les notifications',
        message:
            'Autorisez les notifications pour recevoir vos rappels quotidiens '
            'et les alertes de budget.',
        allowText: 'Autoriser',
        denyText: 'Refuser',
        onAllow: () => Navigator.of(context).pop(true),
        onDeny: () => Navigator.of(context).pop(false),
      );
    },
  );

  if (allow != true || !context.mounted) {
    return;
  }

  final result = await Permission.notification.request();
  if (!result.isGranted) {
    return;
  }

  await ref.read(notificationControllerProvider.notifier).registerIfEnabled();
}
