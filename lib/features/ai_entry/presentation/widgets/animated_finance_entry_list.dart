import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/finance_entry_item.dart';
import 'package:flutter/material.dart';

class AnimatedFinanceEntryList extends StatefulWidget {
  const AnimatedFinanceEntryList({
    required this.entries,
    super.key,
  });

  final List<FinanceEntry> entries;

  @override
  State<AnimatedFinanceEntryList> createState() =>
      _AnimatedFinanceEntryListState();
}

class _AnimatedFinanceEntryListState extends State<AnimatedFinanceEntryList> {
  static const _duration = Duration(milliseconds: 280);
  final _listKey = GlobalKey<AnimatedListState>();
  late final List<FinanceEntry> _entries = [...widget.entries];

  @override
  void didUpdateWidget(covariant AnimatedFinanceEntryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _removeMissingEntries();
    _insertNewEntries();
    _updateExistingEntries();
  }

  void _removeMissingEntries() {
    final nextIds = widget.entries.map((entry) => entry.id).toSet();
    for (var index = _entries.length - 1; index >= 0; index--) {
      if (nextIds.contains(_entries[index].id)) continue;
      final removed = _entries.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _transition(removed, animation),
        duration: _duration,
      );
    }
  }

  void _insertNewEntries() {
    final currentIds = _entries.map((entry) => entry.id).toSet();
    for (var index = 0; index < widget.entries.length; index++) {
      final entry = widget.entries[index];
      if (currentIds.add(entry.id)) {
        _entries.insert(index, entry);
        _listKey.currentState?.insertItem(index, duration: _duration);
      }
    }
  }

  void _updateExistingEntries() {
    final nextById = {for (final entry in widget.entries) entry.id: entry};
    for (var index = 0; index < _entries.length; index++) {
      _entries[index] = nextById[_entries[index].id] ?? _entries[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _entries.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index, animation) {
        return _transition(_entries[index], animation);
      },
    );
  }

  Widget _transition(FinanceEntry entry, Animation<double> animation) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );
    return SizeTransition(
      sizeFactor: curved,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: curved,
        child: FinanceEntryItem(
          key: ValueKey('finance-entry-${entry.id}'),
          entry: entry,
        ),
      ),
    );
  }
}
