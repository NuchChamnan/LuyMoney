import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

/// Quick responsive sizing helper — use via context extension.
/// Example: context.rSize(120) → 120 on phone, 140 on tablet, 160 on desktop
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Scale a size relative to screen width (base = 390pt phone)
  double rSize(double size) => size * (screenWidth / 390).clamp(0.8, 1.4);

  /// Responsive font size
  double rFont(double size) => size * (screenWidth / 390).clamp(0.85, 1.3);

  /// Responsive padding
  EdgeInsets rPadding({double h = 24, double v = 16}) =>
      EdgeInsets.symmetric(horizontal: rSize(h), vertical: rSize(v));

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return ScreenSize.desktop;
    if (width >= 600) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == ScreenSize.mobile;
  static bool isTablet(BuildContext context) =>
      of(context) == ScreenSize.tablet;
  static bool isDesktop(BuildContext context) =>
      of(context) == ScreenSize.desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// Adaptive grid that switches from 1 column on mobile to 2 on tablet, 3 on desktop.
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final cols = ResponsiveLayout.isDesktop(context)
        ? 3
        : ResponsiveLayout.isTablet(context)
            ? 2
            : 1;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: cols,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      childAspectRatio: 1.2,
      children: children,
    );
  }
}
