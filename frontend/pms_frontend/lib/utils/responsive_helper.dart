import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Screen size breakpoints
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Dynamic spacing
  static double spacing(BuildContext context) {
    if (isMobile(context)) return 8.0;
    if (isTablet(context)) return 16.0;
    return 24.0;
  }

  // Dynamic font sizes
  static double headerFontSize(BuildContext context) {
    if (isMobile(context)) return 24.0;
    if (isTablet(context)) return 28.0;
    return 32.0;
  }

  static double bodyFontSize(BuildContext context) {
    if (isMobile(context)) return 12.0;
    if (isTablet(context)) return 14.0;
    return 16.0;
  }

  static double tableFontSize(BuildContext context) {
    if (isMobile(context)) return 10.0;
    if (isTablet(context)) return 12.0;
    return 14.0;
  }

  // Dynamic container sizes
  static double containerWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isMobile(context)) return screenWidth * 0.95;
    if (isTablet(context)) return screenWidth * 0.85;
    return screenWidth * 0.75;
  }

  // Dynamic grid columns
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  // Dynamic widget sizes
  static double iconSize(BuildContext context) {
    if (isMobile(context)) return 20.0;
    if (isTablet(context)) return 24.0;
    return 30.0;
  }

  static EdgeInsets containerPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(10.0);
    }
    if (isTablet(context)) {
      return const EdgeInsets.all(16.0);
    }
    return const EdgeInsets.all(20.0);
  }

  // Navbar height
  static double navbarHeight(BuildContext context) {
    if (isMobile(context)) return 100.0;
    if (isTablet(context)) return 125.0;
    return 150.0;
  }

  // Card dimensions
  static double cardWidth(BuildContext context) {
    if (isMobile(context)) return 300.0;
    if (isTablet(context)) return 400.0;
    return 450.0;
  }

  static double cardHeight(BuildContext context) {
    if (isMobile(context)) return 300.0;
    if (isTablet(context)) return 400.0;
    return 450.0;
  }

  // Card layout helpers
  static double cardSpacing(BuildContext context) {
    if (isMobile(context)) return 10.0;
    if (isTablet(context)) return 15.0;
    return 20.0;
  }

  static EdgeInsets cardPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(8.0);
    if (isTablet(context)) return const EdgeInsets.all(12.0);
    return const EdgeInsets.all(16.0);
  }

  static double cardIconSize(BuildContext context) {
    if (isMobile(context)) return 80.0;
    if (isTablet(context)) return 120.0;
    return 150.0;
  }

  static double cardTitleFontSize(BuildContext context) {
    if (isMobile(context)) return 14.0;
    if (isTablet(context)) return 16.0;
    return 18.0;
  }

  // Dynamic card dimensions based on screen size
  static double getCardWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isMobile(context)) {
      return (screenWidth - 60) / 1; // Single column with margins
    }
    if (isTablet(context)) {
      return (screenWidth - 90) / 2; // Two columns with margins
    }
    return (screenWidth - 120) / 3; // Three columns with margins
  }

  static double getCardHeight(BuildContext context) {
    if (isMobile(context)) return 150.0;
    if (isTablet(context)) return 180.0;
    return 200.0;
  }

  // Layout helpers for grids
  static int getCardCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  static double getChildAspectRatio(BuildContext context) {
    if (isMobile(context)) return 2.5; // Wider cards on mobile
    if (isTablet(context)) return 1.8;
    return 1.5; // More square on desktop
  }

  // Table columns visibility
  static List<String> getVisibleColumns(BuildContext context, List<String> allColumns) {
    if (isMobile(context)) {
      // Show only essential columns on mobile
      return allColumns.take(3).toList();
    }
    if (isTablet(context)) {
      // Show most columns on tablet
      return allColumns.take(5).toList();
    }
    // Show all columns on desktop
    return allColumns;
  }
}