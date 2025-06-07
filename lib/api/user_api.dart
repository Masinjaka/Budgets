import 'package:budgets/core/wrapper.dart';
import 'package:budgets/main.dart';
import 'package:budgets/model/user_model.dart';
import 'package:flutter/foundation.dart';

Future<UserModel> getUser() {
  return Wrapper.execute(() async {
    final response = await supabase.from('user').select().single();

    debugPrint('User response: $response');

    UserModel user = UserModel.fromJson(response);

    return user;
  });
}