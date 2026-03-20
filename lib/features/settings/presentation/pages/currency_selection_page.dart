import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/ui/glass_flexible_space.dart';
import 'package:budgets/features/settings/presentation/widgets/setting_card.dart';
import 'package:budgets/features/settings/presentation/widgets/setting_section.dart';
import 'package:budgets/widgets/custom_search_bar.dart';
import 'package:budgets/widgets/skeleton/currency_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CurrencySelectionPage extends ConsumerStatefulWidget {
  const CurrencySelectionPage({super.key});

  @override
  ConsumerState<CurrencySelectionPage> createState() =>
      _CurrencySelectionPageState();
}

class _CurrencySelectionPageState
    extends ConsumerState<CurrencySelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _pendingCode;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    final next = _searchController.text.trim();
    if (next == _query) return;
    setState(() => _query = next);
  }

  String _currencySymbol(String code) {
    final formatter = NumberFormat.simpleCurrency(name: code);
    return formatter.currencySymbol;
  }

  String _formatLastUpdated(DateTime? fetchedAt) {
    if (fetchedAt == null) return 'Date inconnue';
    return DateFormat('d MMM yyyy • HH:mm', 'fr_FR').format(fetchedAt.toLocal());
  }

  Widget _buildSelectedIndicator(BuildContext context) {
    final green = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;
    return Container(
      width: 5.w,
      height: 5.w,
      decoration: BoxDecoration(
        color: green,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        size: 16.sp,
        color: surface,
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return SizedBox(
      width: 5.w,
      height: 5.w,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassFlexibleSpace(),
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Devise',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: currencyState.when(
                data: (state) {
                  final codes = <String>{'MGA', ...state.rates.keys}.toList()
                    ..sort();
                  final filtered = _query.isEmpty
                      ? codes
                      : codes
                          .where((code) =>
                              code.toLowerCase().contains(_query.toLowerCase()))
                          .toList();
                  final lastUpdated = _formatLastUpdated(state.fetchedAt);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: ReusableSearchBar(
                          controller: _searchController,
                          hintText: 'Rechercher une devise (ex: USD, EUR)',
                          onSearchFocused: () {},
                          onSearchUnfocused: () {},
                          onClearSearch: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          isSearchFocused: false,
                        ),
                      ),
                      SettingSection(
                        title: 'Préférences',
                        children: [
                          SizedBox(height: 1.h),
                          ...filtered.map((code) {
                            final symbol = _currencySymbol(code);
                            final selected = code == state.code;
                            final isPending = _pendingCode == code;
                            return Padding(
                              padding: EdgeInsets.only(bottom: 1.h),
                              child: SettingCard(
                                title: code,
                                iconData: Icons.currency_exchange_outlined,
                                onTap: () async {
                                  if (_pendingCode != null) return;
                                  setState(() => _pendingCode = code);
                                  await ref
                                      .read(currencyControllerProvider.notifier)
                                      .setCurrency(code);
                                  if (mounted) {
                                    setState(() => _pendingCode = null);
                                  }
                                },
                                showSuffixSettingChoice: true,
                                settingChoice: symbol,
                                showTrailingArrow: false,
                                trailingWidget: selected
                                    ? (isPending
                                        ? _buildLoadingIndicator(context)
                                        : _buildSelectedIndicator(context))
                                    : (isPending
                                        ? _buildLoadingIndicator(context)
                                        : const SizedBox.shrink()),
                              ),
                            );
                          }),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Dernière mise à jour: $lastUpdated',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  );
                },
                loading: () => const CurrencyPageSkeleton(),
                error: (error, stack) => Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Center(child: Text('Erreur: $error')),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
