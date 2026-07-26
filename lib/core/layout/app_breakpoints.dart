abstract final class AppBreakpoints {
  static const double persistentNavigation = 600;
  static const double expanded = 1024;
  static const double collapsedSidebarWidth = 68;
  static const double mobileDrawerFraction = 0.95;

  static bool usesPersistentNavigation(double width) =>
      width >= persistentNavigation;

  static double sidebarWidth(double width) => width >= expanded ? 360 : 320;

  static double mobileDrawerWidth(double width) =>
      width * mobileDrawerFraction;
}
