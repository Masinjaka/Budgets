abstract final class AppBreakpoints {
  static const double persistentNavigation = 600;
  static const double expanded = 1024;
  static const double collapsedSidebarWidth = 68;

  static bool usesPersistentNavigation(double width) =>
      width >= persistentNavigation;

  static double sidebarWidth(double width) => width >= expanded ? 360 : 320;

  static double mobileDrawerWidth(double width) {
    final proportionalWidth = width * 0.825;
    return proportionalWidth > 360 ? 360 : proportionalWidth;
  }
}
