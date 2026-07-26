import 'package:budgets/features/home/presentation/widgets/drawer_profile_button.dart';
import 'package:budgets/features/user/domain/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reloads the profile after returning from settings',
      (tester) async {
    var photoUrl = 'https://example.com/first.jpg';
    var loadCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DrawerProfileButton(
            onPressed: () async {
              photoUrl = 'https://example.com/updated.jpg';
            },
            profileLoader: () async {
              loadCount++;
              return UserModel(profilePhoto: photoUrl);
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(_avatar(tester).imageUrl, 'https://example.com/first.jpg');
    expect(loadCount, 1);

    await tester.tap(find.byKey(const Key('drawer-profile-button')));
    await tester.pump();
    await tester.pump();

    expect(_avatar(tester).imageUrl, 'https://example.com/updated.jpg');
    expect(loadCount, 2);
  });
}

CachedNetworkImage _avatar(WidgetTester tester) =>
    tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
