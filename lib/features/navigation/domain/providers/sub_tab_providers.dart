import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sub_tab_providers.g.dart';

@riverpod
class TransactionSubTab extends _$TransactionSubTab {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

@Riverpod(keepAlive: true)
class PlanningSubTab extends _$PlanningSubTab {
  @override
  int build() => 0;

  void set(int index) => state = index;
}
