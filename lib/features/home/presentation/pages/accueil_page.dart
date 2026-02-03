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
import 'package:budgets/widgets/permission_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final _notificationPermissionPromptedProvider =
    StateProvider<bool>((ref) => false);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTransactions = ref.watch(transactionsProvider);
    final selectedCategories = ref.watch(selectedCategoriesProvider);
    final dateRange = ref.watch(dateRangeProvider);
    final prompted = ref.watch(_notificationPermissionPromptedProvider);
    if (!prompted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final alreadyPrompted =
            ref.read(_notificationPermissionPromptedProvider);
        if (alreadyPrompted) return;
        ref.read(_notificationPermissionPromptedProvider.notifier).state = true;
        await _maybeRequestNotificationPermission(context, ref);
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomGreetingAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            // physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                    height: 15.h), // Adjusted for AppBar height + Safe Area
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
        return transactionDate.isAfter(dateRange!.start) &&
            transactionDate
                .isBefore(dateRange!.end.add(const Duration(days: 1)));
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
    await showDialog<void>(
      context: context,
      builder: (context) {
        return PermissionRequestDialog(
          title: 'Activer les notifications',
          message:
              'Vous avez bloqué les notifications. Ouvrez les réglages pour '
              'les autoriser.',
          allowText: 'Ouvrir les réglages',
          denyText: 'Annuler',
          onAllow: () {
            openAppSettings();
            Navigator.of(context).pop();
          },
          onDeny: () => Navigator.of(context).pop(),
        );
      },
    );
    return;
  }

  if (!context.mounted) return;
  final allow = await showDialog<bool>(
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
