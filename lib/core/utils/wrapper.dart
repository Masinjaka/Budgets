import 'package:flutter/material.dart';

class Wrapper {
  // Calls the provided function inside a try-catch block
  static T execute<T>(T Function() function) {
    try {
      return function();
    } catch (e, stackTrace) {
      // Handle the error or log it
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow; // Optionally rethrow the error
    }
  }

  static Stream<T> executeStream<T>(Stream<T> Function() function) {
    try {
      return function().handleError((e, stackTrace) {
        debugPrint('Stream Error: $e');
        debugPrint('StackTrace: $stackTrace');
      });
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      return Stream.error(e, stackTrace);
    }
  }
}
