import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const ml = 20.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
  static const xxxl = 48.0;
  static const bottomNavigationClearance = 96.0;
}

class AppRadii {
  const AppRadii._();

  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;

  static BorderRadius get card => BorderRadius.circular(md);
  static BorderRadius get sheet => BorderRadius.circular(lg);
  static BorderRadius get pill => BorderRadius.circular(999);
}

class AppElevation {
  const AppElevation._();

  static const none = 0.0;
  static const low = 1.0;
  static const medium = 3.0;
}

class AppIconSizes {
  const AppIconSizes._();

  static const sm = 18.0;
  static const md = 24.0;
  static const lg = 32.0;
  static const empty = 48.0;
}

class AppBreakpoints {
  const AppBreakpoints._();

  static const tablet = 700.0;
  static const desktop = 1040.0;
  static const readableMaxWidth = 1040.0;
}

class AppDurations {
  const AppDurations._();

  static const fast = Duration(milliseconds: 160);
  static const standard = Duration(milliseconds: 240);
  static const emphasized = Duration(milliseconds: 360);
}

class AppCurves {
  const AppCurves._();

  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubic;
}

EdgeInsets responsivePagePadding(BoxConstraints constraints) {
  final side = constraints.maxWidth > AppBreakpoints.readableMaxWidth
      ? (constraints.maxWidth - AppBreakpoints.readableMaxWidth) / 2 +
            AppSpacing.md
      : AppSpacing.md;
  return EdgeInsets.fromLTRB(
    side,
    AppSpacing.md,
    side,
    AppSpacing.bottomNavigationClearance,
  );
}
