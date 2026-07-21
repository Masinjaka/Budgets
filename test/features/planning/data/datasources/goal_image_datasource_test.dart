import 'package:budgets/features/planning/data/datasources/goal_image_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extracts a profile bucket object path from its public URL', () {
    const url = 'https://project.supabase.co/storage/v1/object/public/'
        'profile/goals/user-id/goal.jpg';

    expect(
      extractStoragePathFromUrl(url),
      'goals/user-id/goal.jpg',
    );
  });

  test('rejects URLs outside the profile bucket', () {
    expect(extractStoragePathFromUrl('https://example.com/goal.jpg'), isNull);
    expect(extractStoragePathFromUrl(null), isNull);
  });
}
