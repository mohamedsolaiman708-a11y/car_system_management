import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Helper to get a value based on screen size
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  required T desktop,
}) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 1200) return desktop;
  if (width >= 600) return tablet ?? mobile;
  return mobile;
}

/// Wraps page content with proper max-width on desktop
/// and responsive horizontal padding.
/// On desktop: centered with max 1100px, side padding 40px
/// On tablet: side padding 24px
/// On mobile: side padding 16px
class ResponsivePageLayout extends StatelessWidget {
  final Widget child;
  final double desktopMaxWidth;
  final bool centerOnDesktop;

  const ResponsivePageLayout({
    super.key,
    required this.child,
    this.desktopMaxWidth = 1100,
    this.centerOnDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double horizontalPadding;
      if (constraints.maxWidth >= 1200) {
        horizontalPadding = 40;
      } else if (constraints.maxWidth >= 600) {
        horizontalPadding = 24;
      } else {
        horizontalPadding = 16;
      }

      final content = Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: child,
      );

      if (centerOnDesktop && constraints.maxWidth >= 1200) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: desktopMaxWidth),
            child: content,
          ),
        );
      }
      return content;
    });
  }
}

/// On desktop: places children in a 2-column side-by-side Row
/// On mobile/tablet: stacks children vertically
class ResponsiveFormRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveFormRow({
    super.key,
    required this.children,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 700) {
        // Desktop / wide tablet: side by side
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i < children.length - 1) SizedBox(width: spacing),
            ],
          ],
        );
      }
      // Mobile: stacked
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) SizedBox(height: spacing),
          ],
        ],
      );
    });
  }
}

/// Responsive grid that adjusts column count based on screen width
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 4,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.childAspectRatio = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      int columns;
      if (constraints.maxWidth >= 1200) {
        columns = desktopColumns;
      } else if (constraints.maxWidth >= 600) {
        columns = tabletColumns;
      } else {
        columns = mobileColumns;
      }

      return GridView.count(
        crossAxisCount: columns,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        children: children,
      );
    });
  }
}

/// Two-panel desktop layout: left = main content, right = summary/sidebar
/// On mobile: stacks them vertically (summary goes to bottom)
class ResponsiveTwoPanel extends StatelessWidget {
  final Widget main;
  final Widget side;
  final double sideWidth;
  final bool sideFirst; // put side before main on desktop

  const ResponsiveTwoPanel({
    super.key,
    required this.main,
    required this.side,
    this.sideWidth = 340,
    this.sideFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 1000) {
        final panels = [
          Expanded(child: main),
          const SizedBox(width: 24),
          SizedBox(width: sideWidth, child: side),
        ];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sideFirst ? panels.reversed.toList() : panels,
        );
      }
      // Mobile/tablet: stacked
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          main,
          const SizedBox(height: 24),
          side,
        ],
      );
    });
  }
}
