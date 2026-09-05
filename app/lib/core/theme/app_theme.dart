import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';
import 'app_typography.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceHigh,
    required this.accent,
    required this.onAccent,
    required this.text,
    required this.muted,
    required this.danger,
    required this.success,
    required this.border,
    required this.fieldBg,
    required this.fieldOn,
    required this.field,
  });

  final Color bg;
  final Color surface;
  final Color surfaceHigh;
  final Color accent;
  final Color onAccent;
  final Color text;
  final Color muted;
  final Color danger;
  final Color success;
  final Color border;
  final Color fieldBg;
  final Color fieldOn;

  /// Field Mode's own scoreboard tokens. Identical in light and dark.
  final FieldPalette field;

  factory AppColors.fromPalette(AppPalette p) {
    return AppColors(
      bg: p.bg,
      surface: p.surface,
      surfaceHigh: p.surfaceHigh,
      accent: p.accent,
      onAccent: p.onAccent,
      text: p.text,
      muted: p.muted,
      danger: p.danger,
      success: p.success,
      border: p.border,
      fieldBg: p.fieldBg,
      fieldOn: p.fieldOn,
      field: FieldPalette.scoreboard,
    );
  }

  static final light = AppColors.fromPalette(AppPalette.light);
  static final dark = AppColors.fromPalette(AppPalette.dark);

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceHigh,
    Color? accent,
    Color? onAccent,
    Color? text,
    Color? muted,
    Color? danger,
    Color? success,
    Color? border,
    Color? fieldBg,
    Color? fieldOn,
    FieldPalette? field,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      border: border ?? this.border,
      fieldBg: fieldBg ?? this.fieldBg,
      fieldOn: fieldOn ?? this.fieldOn,
      field: field ?? this.field,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      border: Color.lerp(border, other.border, t)!,
      fieldBg: Color.lerp(fieldBg, other.fieldBg, t)!,
      fieldOn: Color.lerp(fieldOn, other.fieldOn, t)!,
      field: other.field,
    );
  }
}

@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  static const defaults = AppSpacing(xs: 4, sm: 8, md: 16, lg: 24, xl: 32);

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      xs: lerpDouble(xs, other.xs, t),
      sm: lerpDouble(sm, other.sm, t),
      md: lerpDouble(md, other.md, t),
      lg: lerpDouble(lg, other.lg, t),
      xl: lerpDouble(xl, other.xl, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

@immutable
class AppRadii extends ThemeExtension<AppRadii> {
  const AppRadii({required this.sm, required this.md, required this.lg});

  final double sm;
  final double md;
  final double lg;

  static const defaults = AppRadii(sm: 6, md: 10, lg: 14);

  @override
  AppRadii copyWith({double? sm, double? md, double? lg}) {
    return AppRadii(sm: sm ?? this.sm, md: md ?? this.md, lg: lg ?? this.lg);
  }

  @override
  AppRadii lerp(ThemeExtension<AppRadii>? other, double t) {
    if (other is! AppRadii) return this;
    return AppRadii(
      sm: AppSpacing.lerpDouble(sm, other.sm, t),
      md: AppSpacing.lerpDouble(md, other.md, t),
      lg: AppSpacing.lerpDouble(lg, other.lg, t),
    );
  }
}

class AppTheme {
  static ThemeData light() => _base(Brightness.light, AppPalette.light);
  static ThemeData dark() => _base(Brightness.dark, AppPalette.dark);

  static ThemeData _base(Brightness brightness, AppPalette p) {
    final colors = AppColors.fromPalette(p);
    final textTheme = AppTypography.textTheme(p.text, p.muted);
    final overlay = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
        : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.accent,
      onSecondary: p.onAccent,
      surface: p.surface,
      onSurface: p.text,
      error: p.danger,
      onError: Colors.white,
      outline: p.border,
      outlineVariant: p.border,
      surfaceContainerLowest: p.bg,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceHigh,
      surfaceContainerHighest: p.surfaceHigh,
    );

    final radius = BorderRadius.circular(AppRadii.defaults.md);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      fontFamily: AppTypography.family,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        foregroundColor: p.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlay,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: p.text),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        elevation: 0,
        height: 64,
        indicatorColor: p.accent.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? p.accent : p.muted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? p.accent : p.muted, size: 22);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: p.border),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        labelStyle: textTheme.bodyMedium?.copyWith(color: p.muted),
        hintStyle: textTheme.bodyMedium?.copyWith(color: p.muted),
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: p.border)),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: p.border)),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: p.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: p.border, space: 1, thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.onAccent;
          return p.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.accent;
          return p.surfaceHigh;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceHigh,
        selectedColor: p.accent.withValues(alpha: 0.18),
        labelStyle: textTheme.labelMedium!,
        side: BorderSide(color: p.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.defaults.sm)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.accent,
        foregroundColor: p.onAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.defaults.lg)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.defaults.lg)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.muted,
        textColor: p.text,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodySmall,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return p.onAccent;
            return p.text;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return p.accent;
            return p.surface;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: p.border)),
        ),
      ),
      extensions: [AppSpacing.defaults, AppRadii.defaults, colors],
    );
  }
}
