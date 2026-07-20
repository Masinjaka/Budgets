import 'package:budgets/core/utils/wrapper.dart';
import 'package:budgets/features/user/domain/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<UserModel> getUser() {
  return Wrapper.execute(() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) throw StateError('No authenticated user');

    final row = await Supabase.instance.client
        .from('user')
        .select('username, profile_photo, currency_code')
        .eq('user_id', uid)
        .single();
    return UserModel.fromJson(row);
  });
}
