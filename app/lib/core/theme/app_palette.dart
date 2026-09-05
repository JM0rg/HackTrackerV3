import 'package:flutter/material.dart';

/// Field Mode stays a dark scoreboard in both app themes, so it carries its own
/// token set rather than following the light palette.
@immutable
class FieldPalette {
  const FieldPalette({
    required this.bg,
    required this.surface,
    required this.surfaceHigh,
    required this.border,
    required this.on,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.out,
    required this.onOut,
    required this.outBorder,
    required this.outDeep,
    required this.line,
    required this.lineStrong,
    required this.glow,
  });

  final Color bg;
  final Color surface;
  final Color surfaceHigh;
  final Color border;
  final Color on;
  final Color muted;

  /// Hits and confirming actions.
  final Color accent;
  final Color onAccent;

  /// Outs. A separate hue so a hit and an out never read alike at a glance.
  final Color out;
  final Color onOut;
  final Color outBorder;

  /// Bottom of the opponent-half card's gradient.
  final Color outDeep;

  /// Basepaths and quiet strokes, then the slightly stronger fence.
  final Color line;
  final Color lineStrong;

  /// Top of the scoreboard's vignette.
  final Color glow;

  static const scoreboard = FieldPalette(
    bg: Color(0xFF050806),
    surface: Color(0xFF111814),
    surfaceHigh: Color(0xFF1A221C),
    border: Color(0xFF24302A),
    on: Color(0xFFE6F0EA),
    muted: Color(0xFF8A988F),
    accent: Color(0xFF3DDC84),
    onAccent: Color(0xFF04140A),
    out: Color(0xFF4A2119),
    onOut: Color(0xFFFFB3A7),
    outBorder: Color(0xFF5A2A25),
    outDeep: Color(0xFF2A130F),
    line: Color(0xFF223029),
    lineStrong: Color(0xFF2E3C34),
    glow: Color(0xFF0C140F),
  );
}

/// Raw color tokens. No widgets, no ThemeData.
@immutable
class AppPalette {
  const AppPalette({
    required this.bg,
    required this.surface,
    required this.surfaceHigh,
    required this.accent,
    required this.onAccent,
    required this.text,
    required this.muted,
    required this.border,
    required this.danger,
    required this.success,
    required this.fieldBg,
    required this.fieldOn,
  });

  final Color bg;
  final Color surface;
  final Color surfaceHigh;
  final Color accent;
  final Color onAccent;
  final Color text;
  final Color muted;
  final Color border;
  final Color danger;
  final Color success;
  final Color fieldBg;
  final Color fieldOn;

  static const light = AppPalette(
    bg: Color(0xFFF3F6F4),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFE7EEE9),
    accent: Color(0xFF0E7A46),
    onAccent: Color(0xFFFFFFFF),
    text: Color(0xFF0D1611),
    muted: Color(0xFF5C6B63),
    border: Color(0xFFD4DDD8),
    danger: Color(0xFFC62828),
    success: Color(0xFF0E7A46),
    fieldBg: Color(0xFF070A08),
    fieldOn: Color(0xFFE6F0EA),
  );

  static const dark = AppPalette(
    bg: Color(0xFF070A08),
    surface: Color(0xFF111814),
    surfaceHigh: Color(0xFF1A221C),
    accent: Color(0xFF3DDC84),
    onAccent: Color(0xFF04140A),
    text: Color(0xFFE6F0EA),
    muted: Color(0xFF7E8C84),
    border: Color(0xFF24302A),
    danger: Color(0xFFFF6B6B),
    success: Color(0xFF3DDC84),
    fieldBg: Color(0xFF050806),
    fieldOn: Color(0xFFE6F0EA),
  );
}
