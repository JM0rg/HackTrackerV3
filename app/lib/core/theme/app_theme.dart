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
  const AppRadii({
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  final double sm;
  final double md;

  /// Cards and fields.
  final double lg;

  /// Sheets and the largest surfaces.
  final double xl;

  static const defaults = AppRadii(sm: 6, md: 10, lg: 18, xl: 28);

  @override
  AppRadii copyWith({double? sm, double? md, double? lg, double? xl}) {
    return AppRadii(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  AppRadii lerp(ThemeExtension<AppRadii>? other, double t) {
    if (other is! AppRadii) return this;
    return AppRadii(
      sm: AppSpacing.lerpDouble(sm, other.sm, t),
      md: AppSpacing.lerpDouble(md, other.md, t),
      lg: AppSpacing.lerpDouble(lg, other.lg, t),
      xl: AppSpacing.lerpDouble(xl, other.xl, t),
    );
  }
}

class AppTheme {
  /// [fontFamily] is for tests only: the widget tester has no platform font,
  /// so goldens would render every glyph as a box. Production passes nothing
  /// and gets SF Pro or Roboto.
  static ThemeData light({String? fontFamily}) =>
      _base(Brightness.light, AppPalette.light, fontFamily);
  static ThemeData dark({String? fontFamily}) =>
      _base(Brightness.dark, AppPalette.dark, fontFamily);

  static ThemeData _base(
    Brightness brightness,
    AppPalette p,
    String? fontFamily,
  ) {
    final colors = AppColors.fromPalette(p);
    final textTheme = AppTypography.textTheme(
      p.text,
      p.muted,
    ).apply(fontFamily: fontFamily ?? AppTypography.family);
    final overlay = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
          );

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

    // Hairlines, not borders: a separator you can barely see.
    final hairline = p.text.withValues(alpha: 0.06);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      fontFamily: fontFamily ?? AppTypography.family,
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
        titleTextStyle: textTheme.headlineSmall,
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
      // Capsules. The primary action is the only filled thing on a screen.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          minimumSize: const Size(64, 52),
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.text,
          backgroundColor: p.surfaceHigh,
          minimumSize: const Size(64, 52),
          side: BorderSide.none,
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: textTheme.labelLarge,
        ),
      ),
      // Fields are filled surfaces, not outlined boxes.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceHigh,
        labelStyle: textTheme.bodyMedium?.copyWith(color: p.muted),
        hintStyle: textTheme.bodyMedium?.copyWith(color: p.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.defaults.lg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.defaults.lg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.defaults.lg),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.defaults.lg),
        ),
      ),
      dividerTheme: DividerThemeData(color: hairline, space: 1, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceHigh,
        selectedColor: p.accent.withValues(alpha: 0.18),
        labelStyle: textTheme.labelMedium!,
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.accent,
        foregroundColor: p.onAccent,
        elevation: 0,
        shape: const StadiumBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.defaults.xl),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.defaults.xl),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return p.text;
            return p.muted;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return p.surface;
            return p.surfaceHigh;
          }),
          side: const WidgetStatePropertyAll(BorderSide.none),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.defaults.sm + 3),
            ),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return p.accent;
          return p.surfaceHigh;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.muted,
        textColor: p.text,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodySmall,
      ),
      extensions: [AppSpacing.defaults, AppRadii.defaults, colors],
    );
  }
}
