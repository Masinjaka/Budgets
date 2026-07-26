import 'package:budgets/core/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeCollapsingSurface extends StatelessWidget {
  const HomeCollapsingSurface({
    required this.collapseProgress,
    required this.header,
    required this.body,
    super.key,
  });

  static const expandedGap = 16.0;
  static const expandedHeaderPadding = 12.0;
  static const expandedRadius = 28.0;
  static const backgroundColor = AppTheme.backgroundLight;

  final ValueListenable<double> collapseProgress;
  final Widget header;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: collapseProgress,
      builder: (context, _) {
        final progress = collapseProgress.value.clamp(0.0, 1.0);
        final radius = expandedRadius * (1 - progress);
        final pageColor = Theme.of(context).scaffoldBackgroundColor;
        final headerColor = Theme.of(context).cardColor;
        return ColoredBox(
          key: const Key('home-collapsing-background'),
          color: Color.lerp(
            headerColor,
            pageColor,
            progress,
          )!,
          child: SafeArea(
            bottom: false,
            minimum: const EdgeInsets.only(top: 44),
            child: Column(
              children: [
                Padding(
                  key: const Key('home-header-vertical-padding'),
                  padding: EdgeInsets.symmetric(
                    vertical: expandedHeaderPadding * (1 - progress),
                  ),
                  child: header,
                ),
                SizedBox(
                  key: const Key('home-header-collapse-gap'),
                  height: expandedGap * (1 - progress),
                ),
                Expanded(
                  child: DecoratedBox(
                    key: const Key('home-content-surface'),
                    decoration: BoxDecoration(
                      color: pageColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(radius),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      minimum: const EdgeInsets.only(bottom: 4),
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
