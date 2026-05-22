import 'package:flutter/material.dart';

import 'app_theme_extension.dart';

/// Builds the [ThemeData] for each brightness, wiring the [AppThemeExtension]
/// tokens into Material's [ColorScheme] so stock widgets stay coherent.
abstract final class AppTheme {
  static ThemeData light() =>
      _build(AppThemeExtension.light(), Brightness.light);
  static ThemeData dark() => _build(AppThemeExtension.dark(), Brightness.dark);

  static ThemeData _build(AppThemeExtension ext, Brightness brightness) {
    final c = ext.colors;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: c.primary,
          brightness: brightness,
        ).copyWith(
          surface: c.surface,
          primary: c.primary,
          onPrimary: c.onPrimary,
          error: c.danger,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surface,
      extensions: [ext],
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
