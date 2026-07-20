import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SubcategoryWriter {
  const SubcategoryWriter(this._client);

  final SupabaseClient _client;

  Future<void> replace({
    required String transactionId,
    required String categoryId,
    required Map<String, String>? amounts,
  }) async {
    await _client
        .from('subcategory_expenses')
        .delete()
        .eq('transaction_id', transactionId);
    if (amounts == null || amounts.isEmpty) return;

    for (final entry in amounts.entries) {
      var subcategory = await _client
          .from('subcategories')
          .select('id')
          .eq('name', entry.key)
          .eq('category_id', categoryId)
          .maybeSingle();
      subcategory ??= await _client
          .from('subcategories')
          .insert({
            'id': const Uuid().v4(),
            'name': entry.key,
            'category_id': categoryId,
          })
          .select('id')
          .single();
      await _client.from('subcategory_expenses').insert({
        'id': const Uuid().v4(),
        'transaction_id': transactionId,
        'sub_id': subcategory['id'],
        'amount': num.parse(entry.value),
      });
    }
  }
}
