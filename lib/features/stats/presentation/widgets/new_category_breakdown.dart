import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewCategoryBreakdown extends ConsumerStatefulWidget {
  final Map<String, double> expensesByCategory;
  final Map<String, double> incomeByCategory;
  final Map<String, String> categoryColors;
  final Map<String, String> categoryEmojis;

  const NewCategoryBreakdown({
    super.key,
    required this.expensesByCategory,
    required this.incomeByCategory,
    required this.categoryColors,
    required this.categoryEmojis,
  });

  @override
  ConsumerState<NewCategoryBreakdown> createState() =>
      _NewCategoryBreakdownState();
}

class _NewCategoryBreakdownState extends ConsumerState<NewCategoryBreakdown> {
  bool _showExpenses = true;
  final GlobalKey _cardKey = GlobalKey();

  void _switchTab(bool showExpenses) {
    if (_showExpenses == showExpenses) return;
    setState(() => _showExpenses = showExpenses);
  }

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';
    final rate = currencyState?.rateFor(currencyCode) ?? 1.0;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final progressColor = isDarkMode ? Colors.white : Colors.black;

    // Get current data based on toggle
    final currentData =
        _showExpenses ? widget.expensesByCategory : widget.incomeByCategory;

    // Calculate total
    final total = currentData.values.fold(0.0, (sum, amount) => sum + amount);

    // Sort by amount descending
    final sortedEntries = currentData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      key: _cardKey,
      height: 36.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(6.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Catégories',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: textColor?.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.5.h),
          // Tabs styled like transaction page
          Container(
            width: 90.w,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(50),
            ),
            padding: EdgeInsets.all(1.w),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchTab(true),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: _showExpenses
                            ? primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          'Dépenses',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: _showExpenses
                                ? Theme.of(context).colorScheme.onPrimary
                                : textColor?.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _switchTab(false),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: !_showExpenses
                            ? primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          'Revenus',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: !_showExpenses
                                ? Theme.of(context).colorScheme.onPrimary
                                : textColor?.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // Donut chart + category list
          Expanded(
            child: sortedEntries.isEmpty
                ? Center(
                    child: Text(
                      _showExpenses
                          ? 'Aucune dépense ce mois'
                          : 'Aucun revenu ce mois',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: textColor?.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final halfWidth = (constraints.maxWidth - 3.w) / 2;
                      final donutSize = halfWidth.clamp(5.h, 7.h).toDouble();
                      return Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: double.infinity,
                              child: _buildDonutChart(
                                context: context,
                                entries: sortedEntries,
                                surfaceColor: surfaceColor,
                                size: donutSize,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black,
                                    Colors.black,
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.12, 0.88, 1.0],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstIn,
                              child: ListView.separated(
                                padding:
                                    EdgeInsets.only(top: 0.6.h, bottom: 2.h),
                                itemCount: sortedEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = sortedEntries[index];
                                  final percentage = total > 0
                                      ? (entry.value / total * 100)
                                      : 0.0;
                                  final emoji =
                                      widget.categoryEmojis[entry.key] ?? '💰';

                                  return _buildCategoryRow(
                                    emoji: emoji,
                                    name: entry.key,
                                    amount: entry.value,
                                    percentage: percentage,
                                    textColor: textColor,
                                    rate: rate,
                                    currencyCode: currencyCode,
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 1.2.h),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChart({
    required BuildContext context,
    required List<MapEntry<String, double>> entries,
    required Color surfaceColor,
    required double size,
  }) {
    final sections = entries.map((entry) {
      final baseColor =
          _parseColor(widget.categoryColors[entry.key] ?? '#10B981');
      final color = _applyMochaAccent(baseColor, entry.key);
      return PieChartSectionData(
        value: entry.value,
        title: '',
        color: color,
        radius: size * 0.34,
        titleStyle: const TextStyle(fontSize: 0),
        borderSide: BorderSide(color: surfaceColor, width: 1),
      );
    }).toList();

    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: PieChart(
          PieChartData(
            startDegreeOffset: 270,
            sections: sections,
            sectionsSpace: 0,
            centerSpaceRadius: size * 0.52,
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow({
    required String emoji,
    required String name,
    required double amount,
    required double percentage,
    required double rate,
    required String currencyCode,
    Color? textColor,
  }) {
    final baseColor = _parseColor(widget.categoryColors[name] ?? '#10B981');
    final dotColor = _applyMochaAccent(baseColor, name);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 2.2.w,
          height: 2.2.w,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 2.5.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.4.h),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: formatAmountValue(convertFromMga(amount, rate)),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: textColor,
                      ),
                    ),
                    TextSpan(
                      text: '  $currencyCode',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor?.withValues(alpha: 0.7),
                      ),
                    ),
                    TextSpan(
                      text: '  •  ${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: textColor?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hexColor) {
    final cleaned = hexColor.replaceAll('#', '').padLeft(8, 'FF');
    return Color(int.parse(cleaned, radix: 16));
  }

  Color _applyMochaAccent(Color base, String key) {
    final mocha = _catppuccinMochaColor(key);
    return Color.lerp(base, mocha, 0.28) ?? base;
  }

  Color _catppuccinMochaColor(String key) {
    const palette = [
      Color(0xFFF5E0DC), // rosewater
      Color(0xFFF2CDCD), // flamingo
      Color(0xFFF5C2E7), // pink
      Color(0xFFCBA6F7), // mauve
      Color(0xFFF38BA8), // red
      Color(0xFFEBA0AC), // maroon
      Color(0xFFFAB387), // peach
      Color(0xFFF9E2AF), // yellow
      Color(0xFFA6E3A1), // green
      Color(0xFF94E2D5), // teal
      Color(0xFF89DCEB), // sky
      Color(0xFF74C7EC), // sapphire
      Color(0xFF89B4FA), // blue
      Color(0xFFB4BEFE), // lavender
    ];
    final index = key.hashCode.abs() % palette.length;
    return palette[index];
  }
}
