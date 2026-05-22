import 'package:flutter/material.dart';

import 'app_theme_extension.dart';

/// Ergonomic accessors for design tokens. These are the ONLY sanctioned way to
/// read colors, spacing, radii, and text styles in widget code.
extension ThemeContextExtensions on BuildContext {
  AppThemeExtension get _ext => Theme.of(this).extension<AppThemeExtension>()!;

  AppColors get colors => _ext.colors;
  AppSpacing get themeSpacing => _ext.spacing;
  AppRadii get themeRadii => _ext.radii;
  AppTextTokens get text => _ext.text;
}
