import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filter_provider.g.dart';

// Category filter provider
@riverpod
class SelectedCategories extends _$SelectedCategories {
  @override
  List<String> build() => [];

  void update(List<String> categories) {
    state = categories;
  }

  void clear() {
    state = [];
  }
}

// DateRangeProvider
@riverpod
class DateRange extends _$DateRange {
  @override
  DateTimeRange? build() => null;

  void update(DateTimeRange? range) {
    state = range;
  }

  void clear() {
    state = null;
  }
}
