import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const family = 'IBMPlexSans';

  static TextTheme textTheme(Color text, Color muted) {
    TextStyle base(double size, FontWeight weight, {double spacing = 0, double height = 1.25}) {
      return TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        height: height,
        color: text,
      );
    }

    return TextTheme(
      displaySmall: base(32, FontWeight.w600, spacing: -0.6, height: 1.15),
      headlineMedium: base(26, FontWeight.w600, spacing: -0.4, height: 1.2),
      headlineSmall: base(22, FontWeight.w600, spacing: -0.3),
      titleLarge: base(20, FontWeight.w600, spacing: -0.2),
      titleMedium: base(17, FontWeight.w500, spacing: -0.15),
      titleSmall: base(15, FontWeight.w500, spacing: -0.1),
      bodyLarge: base(17, FontWeight.w400, height: 1.4),
      bodyMedium: base(15, FontWeight.w400, height: 1.4),
      bodySmall: base(13, FontWeight.w400, height: 1.35).copyWith(color: muted),
      labelLarge: base(15, FontWeight.w600, spacing: 0.1),
      labelMedium: base(13, FontWeight.w500, spacing: 0.15),
      labelSmall: base(11, FontWeight.w500, spacing: 0.2).copyWith(color: muted),
    );
  }
}
