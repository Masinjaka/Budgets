import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/envelopes/data/repositories/supabase_envelope_repository.dart';
import 'package:budgets/features/envelopes/data/services/envelope_service.dart';
import 'package:budgets/features/envelopes/domain/repositories/envelope_repository.dart';
import 'package:budgets/features/envelopes/presentation/view_models/envelope_view_model.dart';
import 'package:budgets/features/envelopes/presentation/widgets/add_envelope_dialog.dart';
import 'package:budgets/features/envelopes/presentation/widgets/envelope_card.dart';
import 'package:budgets/features/envelopes/presentation/widgets/envelope_empty_state.dart';
import 'package:budgets/features/envelopes/presentation/widgets/envelope_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budgets/features/home/domain/errors/wallet_selection_required_exception.dart';
import 'package:budgets/features/home/presentation/widgets/wallet_source_sheet.dart';

class EnvelopePage extends StatefulWidget {
  const EnvelopePage({this.repository, this.initialMonth, super.key});

  final EnvelopeRepository? repository;
  final DateTime? initialMonth;

  @override
  State<EnvelopePage> createState() => _EnvelopePageState();
}

class _EnvelopePageState extends State<EnvelopePage> {
  late final EnvelopeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final repository = widget.repository ??
        SupabaseEnvelopeRepository(EnvelopeService(Supabase.instance.client));
    _viewModel = EnvelopeViewModel(
      repository,
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

  Future<void> _showAddDialog() async {
    if (_viewModel.availableCategories.isEmpty) {
      showInfoToast(
        context,
        'Create an expense category before adding another envelope.',
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => AddEnvelopeDialog(
        categories: _viewModel.availableCategories,
        onSave: (name, categoryId, amount) async {
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
        },
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFEFE),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Envelopes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            key: const Key('add-envelope-button'),
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add envelope',
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
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
              children: [
                _monthSelector(),
                const SizedBox(height: 18),
                EnvelopeSummaryCard(
                  budget: _viewModel.totalBudget,
                  spent: _viewModel.totalSpent,
                  currencyCode: _viewModel.envelopes.isEmpty
                      ? 'MGA'
                      : _viewModel.envelopes.first.currencyCode,
                ),
                const SizedBox(height: 25),
                const Text(
                  'Monthly envelopes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (_viewModel.envelopes.isEmpty)
                  const EnvelopeEmptyState()
                else
                  ..._viewModel.envelopes.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: EnvelopeCard(
                        envelope: item,
                        onDelete: () => _viewModel.delete(item.id),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _monthSelector() {
    final now = DateTime.now();
    final canGoForward = _viewModel.month.isBefore(
      DateTime(now.year, now.month),
    );
    return Row(
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy').format(_viewModel.month),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          onPressed: canGoForward ? () => _changeMonth(1) : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
