class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1100;
  
  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < tablet;
  static bool isDesktop(double width) => width >= tablet;
}
