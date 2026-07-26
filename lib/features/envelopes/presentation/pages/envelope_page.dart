import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/month_navigation.dart';
import 'package:budgets/features/envelopes/data/repositories/supabase_envelope_repository.dart';
import 'package:budgets/features/envelopes/data/services/envelope_service.dart';
import 'package:budgets/features/envelopes/domain/repositories/envelope_repository.dart';
import 'package:budgets/features/envelopes/presentation/view_models/envelope_view_model.dart';
import 'package:budgets/features/envelopes/presentation/widgets/add_envelope_sheet.dart';
import 'package:budgets/features/envelopes/presentation/widgets/envelope_list_panel.dart';
import 'package:budgets/features/envelopes/presentation/widgets/envelope_summary_card.dart';
import 'package:budgets/features/home/domain/errors/wallet_selection_required_exception.dart';
import 'package:budgets/features/home/presentation/widgets/wallet_source_sheet.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnvelopePage extends StatefulWidget {
  const EnvelopePage({
    this.repository,
    this.initialMonth,
    this.initialEnvelopeId,
    this.displayCurrency,
    super.key,
  });

  final EnvelopeRepository? repository;
  final DateTime? initialMonth;
  final String? initialEnvelopeId;
  final CurrencyState? displayCurrency;

  @override
  State<EnvelopePage> createState() => _EnvelopePageState();
}

class _EnvelopePageState extends State<EnvelopePage> {
  late final EnvelopeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EnvelopeViewModel(
      widget.repository ??
          SupabaseEnvelopeRepository(
            EnvelopeService(Supabase.instance.client),
          ),
      widget.initialMonth ?? DateTime.now(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      await _viewModel.load();
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  Future<void> _changeMonth(int offset) async {
    try {
      await _viewModel.changeMonth(offset);
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  Future<void> _showAddSheet() async {
    if (_viewModel.availableCategories.isEmpty) {
      showInfoToast(context, context.l10n.createExpenseCategoryFirst);
      return;
    }
    await AddEnvelopeSheet.show(
      context,
      categories: _viewModel.availableCategories,
      month: _viewModel.month,
      onSave: _addEnvelope,
      currencyState: widget.displayCurrency,
    );
  }

  Future<void> _addEnvelope(
    String name,
    String categoryId,
    int amount,
  ) async {
    try {
      try {
        await _viewModel.add(
          name: name,
          categoryId: categoryId,
          amount: amount,
        );
      } on WalletSelectionRequiredException catch (error) {
        if (!mounted) rethrow;
        final walletId = await WalletSourceSheet.show(
          context,
          wallets: _viewModel.wallets,
          requiredAmount: error.requiredAmount,
        );
        if (walletId == null) rethrow;
        await _viewModel.add(
          name: name,
          categoryId: categoryId,
          amount: amount,
          walletId: walletId,
        );
      }
    } catch (error) {
      if (mounted) showErrorToast(context, error);
      rethrow;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          context.l10n.envelope,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            key: const Key('add-envelope-button'),
            onPressed: _showAddSheet,
            icon: const Icon(Icons.add_rounded),
            tooltip: context.l10n.addEnvelope,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading && _viewModel.envelopes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return LayoutBuilder(
            builder: (context, constraints) => RefreshIndicator(
              onRefresh: _load,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: constraints.maxWidth.clamp(0.0, 760.0),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: MonthNavigation(
                          month: _viewModel.month,
                          onPrevious: () => _changeMonth(-1),
                          onNext: () => _changeMonth(1),
                          canGoNext: _canGoForward,
                        ),
                      ),
                      const SizedBox(height: 20),
                      EnvelopeSummaryCard(
                        budget: _viewModel.totalBudget,
                        spent: _viewModel.totalSpent,
                        currencyCode: _currencyCode,
                        displayCurrency: widget.displayCurrency,
                      ),
                      const SizedBox(height: 28),
                      EnvelopeListPanel(
                        envelopes: _viewModel.envelopes,
                        onDelete: _viewModel.delete,
                        displayCurrency: widget.displayCurrency,
                        targetEnvelopeId: widget.initialEnvelopeId,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String get _currencyCode => _viewModel.envelopes.isEmpty
      ? 'MGA'
      : _viewModel.envelopes.first.currencyCode;

  bool get _canGoForward {
    final now = DateTime.now();
    return _viewModel.month.isBefore(DateTime(now.year, now.month));
  }
}
