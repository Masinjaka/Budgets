import 'package:budgets/core/utils/response_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RpcParseResult', () {
    test('stores success and error message', () {
      const result = RpcParseResult(true, null);
      expect(result.success, true);
      expect(result.errorMessage, null);

      const resultWithError = RpcParseResult(false, 'Some error');
      expect(resultWithError.success, false);
      expect(resultWithError.errorMessage, 'Some error');
    });
  });

  group('parseRpcAddExpenseResponse', () {
    group('null response', () {
      test('returns success for null response', () {
        final result = parseRpcAddExpenseResponse(null);
        expect(result.success, true);
        expect(result.errorMessage, null);
      });
    });

    group('boolean response', () {
      test('returns success for true', () {
        final result = parseRpcAddExpenseResponse(true);
        expect(result.success, true);
        expect(result.errorMessage, null);
      });

      test('returns failure for false', () {
        final result = parseRpcAddExpenseResponse(false);
        expect(result.success, false);
        expect(result.errorMessage, null);
      });
    });

    group('Map response', () {
      test('parses success key', () {
        final result = parseRpcAddExpenseResponse({'success': true});
        expect(result.success, true);

        final failResult = parseRpcAddExpenseResponse({'success': false});
        expect(failResult.success, false);
      });

      test('parses ok key', () {
        final result = parseRpcAddExpenseResponse({'ok': true});
        expect(result.success, true);

        final failResult = parseRpcAddExpenseResponse({'ok': false});
        expect(failResult.success, false);
      });

      test('parses error_message key', () {
        final result = parseRpcAddExpenseResponse(
            {'success': false, 'error_message': 'Something went wrong'});
        expect(result.success, false);
        expect(result.errorMessage, 'Something went wrong');
      });

      test('parses error key', () {
        final result = parseRpcAddExpenseResponse(
            {'success': false, 'error': 'Database error'});
        expect(result.success, false);
        expect(result.errorMessage, 'Database error');
      });

      test('prefers error_message over error', () {
        final result = parseRpcAddExpenseResponse({
          'success': false,
          'error_message': 'Specific error',
          'error': 'Generic error'
        });
        expect(result.errorMessage, 'Specific error');
      });

      test('extracts boolean value from map values', () {
        final result = parseRpcAddExpenseResponse({'result': true});
        expect(result.success, true);

        final failResult = parseRpcAddExpenseResponse({'result': false});
        expect(failResult.success, false);
      });

      test('extracts string error from map values', () {
        final result = parseRpcAddExpenseResponse(
            {'result': false, 'message': 'Error occurred'});
        expect(result.errorMessage, 'Error occurred');
      });
    });

    group('List response', () {
      test('parses list with Map as first element', () {
        final result = parseRpcAddExpenseResponse([
          {'success': true}
        ]);
        expect(result.success, true);

        final failResult = parseRpcAddExpenseResponse([
          {'success': false, 'error_message': 'Failed'}
        ]);
        expect(failResult.success, false);
        expect(failResult.errorMessage, 'Failed');
      });

      test('parses list with nested list [bool, text]', () {
        final result = parseRpcAddExpenseResponse([
          [true, 'Success message']
        ]);
        expect(result.success, true);
        expect(result.errorMessage, 'Success message');

        final failResult = parseRpcAddExpenseResponse([
          [false, 'Error message']
        ]);
        expect(failResult.success, false);
        expect(failResult.errorMessage, 'Error message');
      });

      test('parses list with boolean as first element', () {
        final result = parseRpcAddExpenseResponse([true]);
        expect(result.success, true);

        final failResult = parseRpcAddExpenseResponse([false]);
        expect(failResult.success, false);
      });

      test('handles empty list', () {
        final result = parseRpcAddExpenseResponse([]);
        expect(result.success, true);
      });
    });

    group('edge cases', () {
      test('handles complex nested structure', () {
        final result = parseRpcAddExpenseResponse([
          {
            'success': false,
            'error_message': 'Transaction failed',
            'data': null
          }
        ]);
        expect(result.success, false);
        expect(result.errorMessage, 'Transaction failed');
      });

      test('handles map with only non-boolean, non-string values', () {
        final result = parseRpcAddExpenseResponse({'count': 5, 'id': 123});
        expect(result.success, true);
      });
    });
  });
}
