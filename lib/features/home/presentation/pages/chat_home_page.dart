import 'package:budgets/features/home/presentation/widgets/home_dashboard.dart';
import 'package:budgets/features/home/presentation/widgets/home_drawer.dart';
import 'package:budgets/features/settings/presentation/pages/settings_with_back_page.dart';
import 'package:flutter/material.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({this.today, super.key});

  final DateTime? today;

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 250);
  static const _flingVelocity = 500.0;
  late final AnimationController _drawerController;
  late final DateTime _today;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );
    _today = DateUtils.dateOnly(widget.today ?? DateTime.now());
    _selectedDate = _today;
  }

  void _openDrawer() => _animateDrawerTo(1);

  void _closeDrawer() => _animateDrawerTo(0);

  void _animateDrawerTo(double target) {
    final distance = (target - _drawerController.value).abs();
    if (distance == 0) return;
    _drawerController.animateTo(
      target,
      duration: Duration(
        milliseconds: (_animationDuration.inMilliseconds * distance)
            .round()
            .clamp(1, _animationDuration.inMilliseconds),
      ),
      curve: Curves.easeOutCubic,
    );
  }

  void _updateDrawerDrag(DragUpdateDetails details, double drawerWidth) {
    _drawerController.value =
        (_drawerController.value + details.delta.dx / drawerWidth).clamp(0, 1);
  }

  void _settleDrawer(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final target = velocity.abs() >= _flingVelocity
        ? (velocity > 0 ? 1.0 : 0.0)
        : (_drawerController.value >= 0.5 ? 1.0 : 0.0);
    _animateDrawerTo(target);
  }

  void _selectDate(DateTime date) {
    setState(() => _selectedDate = DateUtils.dateOnly(date));
    _closeDrawer();
  }

  void _openSettings() {
    final navigator = Navigator.of(context);
    _closeDrawer();
    navigator.push(
      MaterialPageRoute<void>(
        builder: (context) => const SettingsWithBackPage(),
      ),
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final proportionalWidth = constraints.maxWidth * 0.825;
          final drawerWidth =
              proportionalWidth > 360 ? 360.0 : proportionalWidth;

          return Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: drawerWidth,
                child: AnimatedBuilder(
                  animation: _drawerController,
                  builder: (context, child) => Transform.translate(
                    key: const Key('drawer-panel'),
                    offset: Offset(
                      drawerWidth * (_drawerController.value - 1),
                      0,
                    ),
                    child: GestureDetector(
                      key: const Key('drawer-drag-surface'),
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (_) => _drawerController.stop(),
                      onHorizontalDragUpdate: (details) =>
                          _updateDrawerDrag(details, drawerWidth),
                      onHorizontalDragEnd: _settleDrawer,
                      onHorizontalDragCancel: () => _animateDrawerTo(
                        _drawerController.value >= 0.5 ? 1 : 0,
                      ),
                      child: child,
                    ),
                  ),
                  child: HomeDrawer(
                    width: drawerWidth,
                    today: _today,
                    selectedDate: _selectedDate,
                    onClose: _closeDrawer,
                    onDateSelected: _selectDate,
                    onSettingsPressed: _openSettings,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _drawerController,
                builder: (context, child) {
                  return Transform.translate(
                    key: const Key('home-page-panel'),
                    offset: Offset(drawerWidth * _drawerController.value, 0),
                    child: GestureDetector(
                      key: const Key('home-drag-surface'),
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (_) => _drawerController.stop(),
                      onHorizontalDragUpdate: (details) =>
                          _updateDrawerDrag(details, drawerWidth),
                      onHorizontalDragEnd: _settleDrawer,
                      onHorizontalDragCancel: () => _animateDrawerTo(
                        _drawerController.value >= 0.5 ? 1 : 0,
                      ),
                      child: child,
                    ),
                  );
                },
                child: HomeDashboard(
                  today: _today,
                  selectedDate: _selectedDate,
                  drawerProgress: _drawerController,
                  onMenuPressed: _openDrawer,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
