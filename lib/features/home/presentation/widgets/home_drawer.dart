import 'package:budgets/features/home/presentation/widgets/resume_date_calendar.dart';
import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    required this.width,
    required this.today,
    required this.selectedDate,
    required this.onClose,
    required this.onDateSelected,
    required this.onSettingsPressed,
    super.key,
  });

  final double width;
  final DateTime today;
  final DateTime selectedDate;
  final VoidCallback onClose;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFFEFEFE),
          border: Border(
            right: BorderSide(color: Color(0xFFCECECE), width: 3),
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(top: 44, bottom: 39),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded, size: 29),
                  constraints: const BoxConstraints.tightFor(
                    width: 72,
                    height: 48,
                  ),
                  padding: EdgeInsets.zero,
                  tooltip: 'Close menu',
                ),
              ),
              const SizedBox(height: 17),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _menuRow(Icons.mail_outline_rounded, 'Envelope'),
                      const SizedBox(height: 11),
                      _menuRow(Icons.pie_chart_outline_rounded, 'Stats'),
                      const SizedBox(height: 29),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22),
                        child: Text(
                          'Resume from a specific date',
                          style: TextStyle(
                            color: Color(0xFF606060),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ResumeDateCalendar(
                        today: today,
                        selectedDay: selectedDate,
                        onDaySelected: onDateSelected,
                      ),
                    ],
                  ),
                ),
              ),
              _menuRow(
                Icons.settings_outlined,
                'Settings',
                key: const Key('drawer-settings-button'),
                onTap: onSettingsPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuRow(
    IconData icon,
    String label, {
    Key? key,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: 25,
          child: Row(
            children: [
              Icon(icon, size: 22, color: Colors.black),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
