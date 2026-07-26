import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_choice_tile.dart';
import 'package:budgets/features/settings/presentation/widgets/settings_page_shell.dart';
import 'package:budgets/widgets/custom_search_bar.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CurrencySelectionPage extends ConsumerStatefulWidget {
  const CurrencySelectionPage({super.key});

  @override
  ConsumerState<CurrencySelectionPage> createState() =>
      _CurrencySelectionPageState();
}

class _CurrencySelectionPageState extends ConsumerState<CurrencySelectionPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _pendingCode;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearch)
      ..dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query != _query) setState(() => _query = query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyControllerProvider);
    return SettingsPageShell(
      title: context.l10n.currency,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
          child: Column(
            children: [
              ReusableSearchBar(
                controller: _searchController,
                hintText: context.l10n.searchCurrency,
                onSearchFocused: () {},
                onSearchUnfocused: () {},
                onClearSearch: _searchController.clear,
                isSearchFocused: false,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: state.when(
                  data: (value) => _currencyList(value.code, value.rates.keys),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text(context.l10n.errorWithMessage('$error')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _currencyList(String selectedCode, Iterable<String> available) {
    final codes = <String>{'MGA', ...available}
        .where((code) => code.toLowerCase().contains(_query))
        .toList()
      ..sort();
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 28),
      itemCount: codes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final code = codes[index];
        return Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: SettingsChoiceTile(
            title: code,
            subtitle: NumberFormat.simpleCurrency(name: code).currencySymbol,
            leading: const Icon(Icons.currency_exchange_outlined, size: 20),
            trailing: _indicator(code, selectedCode),
            onTap: () => _select(code),
          ),
        );
      },
    );
  }

  Widget? _indicator(String code, String selectedCode) {
    if (_pendingCode == code) {
      return const SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return code == selectedCode
        ? const Icon(Icons.check_circle, color: Colors.green)
        : null;
  }

  Future<void> _select(String code) async {
    if (_pendingCode != null) return;
    setState(() => _pendingCode = code);
    try {
      await ref.read(currencyControllerProvider.notifier).setCurrency(code);
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    } finally {
      if (mounted) setState(() => _pendingCode = null);
    }
  }
}
