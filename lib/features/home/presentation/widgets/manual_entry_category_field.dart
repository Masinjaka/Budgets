import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/ai_entry/domain/models/manual_entry_category.dart';
import 'package:flutter/material.dart';

class ManualEntryCategoryField extends StatelessWidget {
  const ManualEntryCategoryField({
    required this.categories,
    required this.value,
    required this.onChanged,
    this.label = 'Category',
    super.key,
  });

  final List<ManualEntryCategory> categories;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;

  static const cardWidth = 108.0;
  static const cardHeight = 82.0;
  static const selectedScale = 1.04;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTypography.body,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: cardHeight,
          child: categories.isEmpty
              ? _emptyCategory(context)
              : ListView.separated(
                  key: const Key('manual-category-list'),
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 7),
                  itemBuilder: (_, index) =>
                      _categoryCard(context, categories[index]),
                ),
        ),
      ],
    );
  }

  Widget _emptyCategory(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(17),
        ),
        child: const _CategoryContent(
          emoji: '🧾',
          name: 'Other',
          selected: false,
        ),
      ),
    );
  }

  Widget _categoryCard(
    BuildContext context,
    ManualEntryCategory category,
  ) {
    final selected = value == category.id;
    final backgroundColor = Theme.of(context).cardColor;
    return Align(
      child: AnimatedScale(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        scale: selected ? selectedScale : 1,
        child: Semantics(
          selected: selected,
          button: true,
          child: InkWell(
            key: Key('manual-category-${category.id}'),
            borderRadius: BorderRadius.circular(17),
            onTap: () => onChanged(category.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: selected
                      ? _selectedBorder(context, backgroundColor)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: _CategoryContent(
                emoji: category.emoji,
                name: category.name,
                selected: selected,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _selectedBorder(BuildContext context, Color background) => Color.lerp(
        background,
        Theme.of(context).colorScheme.inverseSurface,
        0.32,
      )!;
}

class _CategoryContent extends StatelessWidget {
  const _CategoryContent({
    required this.emoji,
    required this.name,
    required this.selected,
  });

  final String emoji;
  final String name;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ManualEntryCategoryField.cardWidth,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              alignment:
                  selected ? const Alignment(0, -0.35) : Alignment.topLeft,
              child: Text(emoji, style: const TextStyle(fontSize: 21)),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              alignment:
                  selected ? Alignment.bottomCenter : Alignment.bottomLeft,
              child: Text(
                name,
                textAlign: selected ? TextAlign.center : TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  fontSize: AppTypography.caption,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
