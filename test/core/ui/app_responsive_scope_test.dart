import 'package:budgets/core/ui/app_responsive_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('normalizes small platform text and scales wider phones',
      (tester) async {
    double? scaledFontSize;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(412, 915),
          textScaler: TextScaler.linear(0.8),
        ),
        child: AppResponsiveScope(
          child: Builder(
            builder: (context) {
              scaledFontSize = MediaQuery.textScalerOf(context).scale(10);
              return const Directionality(
                textDirection: TextDirection.ltr,
                child: Text('Responsive text'),
              );
            },
          ),
        ),
      ),
    );

    expect(scaledFontSize, closeTo(10.56, 0.02));
  });

  testWidgets('caps large-window typography growth', (tester) async {
    double? scaledFontSize;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(1200, 900),
          textScaler: TextScaler.linear(1),
        ),
        child: AppResponsiveScope(
          child: Builder(
            builder: (context) {
              scaledFontSize = MediaQuery.textScalerOf(context).scale(10);
              return const Directionality(
                textDirection: TextDirection.ltr,
                child: Text('Responsive text'),
              );
            },
          ),
        ),
      ),
    );

    expect(scaledFontSize, 11);
  });
}
