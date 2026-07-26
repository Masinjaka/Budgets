import 'package:budgets/features/envelopes/data/repositories/supabase_envelope_repository.dart';
import 'package:budgets/features/envelopes/data/services/envelope_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockEnvelopeService extends Mock implements EnvelopeService {}

void main() {
  group('SupabaseEnvelopeRepository', () {
    late _MockEnvelopeService service;
    late SupabaseEnvelopeRepository repository;

    setUp(() {
      service = _MockEnvelopeService();
      repository = SupabaseEnvelopeRepository(service);
    });

    test('reads the funded envelope remaining balance', () async {
      when(() => service.envelopes(any())).thenAnswer(
        (_) async => [
          {
            'id': 'envelope-1',
            'name': 'Food',
            'category_id': 'food',
            'amount': 100000,
            'remaining_amount': 90000,
            'overspent_amount': 0,
            'currency_code': 'MGA',
            'categories': {
              'name': 'Foods & Drinks',
              'emoji': '🍔',
              'color': 'FFFF9800',
            },
          },
        ],
      );
      final result = await repository.envelopesForMonth(DateTime(2026, 7));

      expect(result.single.spent, 10000);
      expect(result.single.remaining, 90000);
      expect(result.single.progress, 0.1);
    });

    test('keeps the budget fixed and exposes envelope overspending', () async {
      when(() => service.envelopes(any())).thenAnswer(
        (_) async => [
          {
            'id': 'envelope-1',
            'name': 'Food',
            'category_id': 'food',
            'amount': 100000,
            'remaining_amount': 0,
            'overspent_amount': 25000,
            'currency_code': 'MGA',
            'categories': {'name': 'Food'},
          },
        ],
      );

      final result = await repository.envelopesForMonth(DateTime(2026, 7));

      expect(result.single.amount, 100000);
      expect(result.single.spent, 125000);
      expect(result.single.overspentAmount, 25000);
      expect(result.single.isExceeded, isTrue);
    });
  });
}
