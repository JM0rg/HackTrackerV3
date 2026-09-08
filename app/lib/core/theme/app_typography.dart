import 'package:flutter/material.dart';

abstract final class AppTypography {
  /// The platform's own face: SF Pro on iOS, Roboto on Android. It is what
  /// every app the user already trusts is set in, and it gets Dynamic Type
  /// for free. Null means "use the system default".
  static const String? family = null;

  static TextTheme textTheme(Color text, Color muted) {
    TextStyle base(
      double size,
      FontWeight weight, {
      double tracking = 0,
      double height = 1.25,
    }) {
      return TextStyle(
        fontSize: size,
        fontWeight: weight,
        // Tracking as a fraction of size, the way display type is drawn.
        letterSpacing: size * tracking,
        height: height,
        color: text,
      );
    }

    return TextTheme(
      // Numerals that carry a screen.
      displayLarge: base(64, FontWeight.w800, tracking: -0.055, height: 0.95),
      displayMedium: base(52, FontWeight.w800, tracking: -0.05, height: 1),
      displaySmall: base(40, FontWeight.w800, tracking: -0.045, height: 1),
      headlineLarge: base(32, FontWeight.w700, tracking: -0.04, height: 1.05),
      headlineMedium: base(28, FontWeight.w700, tracking: -0.035, height: 1.1),
      headlineSmall: base(22, FontWeight.w700, tracking: -0.03, height: 1.15),
      titleLarge: base(20, FontWeight.w700, tracking: -0.025),
      titleMedium: base(17, FontWeight.w600, tracking: -0.02),
      titleSmall: base(15, FontWeight.w600, tracking: -0.015),
      bodyLarge: base(17, FontWeight.w400, tracking: -0.01, height: 1.4),
      bodyMedium: base(15, FontWeight.w400, tracking: -0.005, height: 1.4),
      bodySmall: base(13, FontWeight.w400, height: 1.35).copyWith(color: muted),
      labelLarge: base(16, FontWeight.w600, tracking: -0.01),
      labelMedium: base(13, FontWeight.w600),
      labelSmall: base(11, FontWeight.w500).copyWith(color: muted),
    );
  }
}
