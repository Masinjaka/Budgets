import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.drawerProgress,
    required this.onMenuPressed,
    super.key,
  });

  final Animation<double> drawerProgress;
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: drawerProgress,
            builder: (context, child) => IgnorePointer(
              ignoring: drawerProgress.value > 0,
              child: Opacity(
                key: const Key('burger-menu-opacity'),
                opacity: 1 - drawerProgress.value,
                child: child,
              ),
            ),
            child: IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu_rounded, size: 30),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: 80,
                height: 48,
              ),
              tooltip: 'Menu',
            ),
          ),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '1 000 000 Ar',
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('All time', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 3),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 15),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Transform.translate(
              offset: const Offset(4, 0),
              child: const Icon(Icons.notifications_none_rounded, size: 29),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 80, height: 48),
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }
}
