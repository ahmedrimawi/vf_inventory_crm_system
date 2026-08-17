import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 700;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return width >= 700 && width < 1100;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 1100;
  }

  static double getNavWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 700) {
      return 0;
    }

    if (width < 1100) {
      return 240;
    }

    return 270;
  }
}
