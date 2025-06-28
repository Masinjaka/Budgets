
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Category filter provider
final selectedCategoriesProvider = StateProvider<List<String>>((ref) {
  return [];
},);

// DateRangeProvider
final dateRangeProvider = StateProvider<DateTimeRange?>((ref) => null,);