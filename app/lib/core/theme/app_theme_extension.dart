import 'package:flutter/material.dart';

/// Color tokens. Reference via `context.colors.*` — never hardcode a [Color].
@immutable
class AppColors {
  const AppColors({
    required this.surface,
    required this.surfaceAlt,
    required this.primary,
    required this.onPrimary,
    required this.text,
    required this.secondaryText,
    required this.border,
    required this.danger,
    required this.success,
  });

  final Color surface;
  final Color surfaceAlt;
  final Color primary;
  final Color onPrimary;
  final Color text;
  final Color secondaryText;
  final Color border;
  final Color danger;
  final Color success;

  static const AppColors light = AppColors(
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF4F6F5),
    primary: Color(0xFF2E7D32),
    onPrimary: Color(0xFFFFFFFF),
    text: Color(0xFF14201A),
    secondaryText: Color(0xFF5C6B63),
    border: Color(0xFFDCE3DF),
    danger: Color(0xFFC62828),
    success: Color(0xFF2E7D32),
  );

  static const AppColors dark = AppColors(
    surface: Color(0xFF121714),
    surfaceAlt: Color(0xFF1B221E),
    primary: Color(0xFF4CAF50),
    onPrimary: Color(0xFF08130C),
    text: Color(0xFFE8EFEA),
    secondaryText: Color(0xFF9AA8A0),
    border: Color(0xFF2A332D),
    danger: Color(0xFFEF5350),
    success: Color(0xFF66BB6A),
  );

  AppColors lerp(AppColors other, double t) {
    return AppColors(
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      text: Color.lerp(text, other.text, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      border: Color.lerp(border, other.border, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

/// Spacing scale in logical pixels. Reference via `context.themeSpacing.*`.
@immutable
class AppSpacing {
  const AppSpacing();

  final double xs = 4;
  final double sm = 8;
  final double md = 16;
  final double lg = 24;
  final double xl = 32;
}

/// Corner-radius scale. Reference via `context.themeRadii.*`.
@immutable
class AppRadii {
  const AppRadii();

  final double sm = 8;
  final double md = 12;
  final double lg = 20;
}

/// Text-style tokens. Reference via `context.text.*`.
@immutable
class AppTextTokens {
  const AppTextTokens({
    required this.titleL,
    required this.titleM,
    required this.body,
    required this.label,
    required this.caption,
  });

  final TextStyle titleL;
  final TextStyle titleM;
  final TextStyle body;
  final TextStyle label;
  final TextStyle caption;

  factory AppTextTokens.forColor(Color text, Color secondary) {
    return AppTextTokens(
      titleL: TextStyle(
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      titleM: TextStyle(
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      body: TextStyle(fontSize: 15, height: 1.4, color: text),
      label: TextStyle(
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      caption: TextStyle(fontSize: 12, height: 1.3, color: secondary),
    );
  }

  AppTextTokens lerp(AppTextTokens other, double t) {
    return AppTextTokens(
      titleL: TextStyle.lerp(titleL, other.titleL, t)!,
      titleM: TextStyle.lerp(titleM, other.titleM, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}

/// The single [ThemeExtension] carrying all design tokens. `ThemeExtension`
/// mandates hand-rolled [copyWith]/[lerp] — the documented exception to the
/// no-hand-rolled-copyWith rule.
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.colors,
    required this.spacing,
    required this.radii,
    required this.text,
  });

  final AppColors colors;
  final AppSpacing spacing;
  final AppRadii radii;
  final AppTextTokens text;

  factory AppThemeExtension.light() => AppThemeExtension(
    colors: AppColors.light,
    spacing: const AppSpacing(),
    radii: const AppRadii(),
    text: AppTextTokens.forColor(
      AppColors.light.text,
      AppColors.light.secondaryText,
    ),
  );

  factory AppThemeExtension.dark() => AppThemeExtension(
    colors: AppColors.dark,
    spacing: const AppSpacing(),
    radii: const AppRadii(),
    text: AppTextTokens.forColor(
      AppColors.dark.text,
      AppColors.dark.secondaryText,
    ),
  );

  @override
  AppThemeExtension copyWith({
    AppColors? colors,
    AppSpacing? spacing,
    AppRadii? radii,
    AppTextTokens? text,
  }) {
    return AppThemeExtension(
      colors: colors ?? this.colors,
      spacing: spacing ?? this.spacing,
      radii: radii ?? this.radii,
      text: text ?? this.text,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      colors: colors.lerp(other.colors, t),
      spacing: const AppSpacing(),
      radii: const AppRadii(),
      text: text.lerp(other.text, t),
    );
  }
}
