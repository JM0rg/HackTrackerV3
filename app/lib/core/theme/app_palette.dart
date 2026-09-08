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

  /// Brighter labels and basepaths against a solid black field.
  static const outdoor = FieldPalette(
    bg: Color(0xFF000000),
    surface: Color(0xFF101010),
    surfaceHigh: Color(0xFF242424),
    border: Color(0xFF8C8C8C),
    on: Color(0xFFFFFFFF),
    muted: Color(0xFFE0E0E0),
    accent: Color(0xFF61FF9E),
    onAccent: Color(0xFF002B13),
    out: Color(0xFF40140D),
    onOut: Color(0xFFFFB7A8),
    outBorder: Color(0xFFFF806A),
    outDeep: Color(0xFF210800),
    line: Color(0xFF8C8C8C),
    lineStrong: Color(0xFFBFBFBF),
    glow: Color(0xFF000000),
  );

  static const scoreboard = FieldPalette(
    bg: Color(0xFF0B0D0F),
    surface: Color(0xFF15181C),
    surfaceHigh: Color(0xFF1E2227),
    border: Color(0xFF2A2F36),
    on: Color(0xFFF2F4F6),
    muted: Color(0xFF9AA3AE),
    accent: Color(0xFF3DDC84),
    onAccent: Color(0xFF062A17),
    out: Color(0xFF3A1A15),
    onOut: Color(0xFFFF8A7A),
    outBorder: Color(0xFF52251E),
    outDeep: Color(0xFF24100C),
    line: Color(0xFF22282E),
    lineStrong: Color(0xFF2A3036),
    glow: Color(0xFF123D26),
  );
}

/// Raw color tokens. A tonal ladder, not a set of outlined boxes: depth comes
/// from [bg] → [surface] → [surfaceHigh], and [border] is reserved for the
/// few controls that genuinely need an edge.
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

  /// iOS grouped greys: page, card, inset. Cards lift with a soft shadow
  /// instead of a stroke.
  static const light = AppPalette(
    bg: Color(0xFFF2F2F7),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFE9E9EE),
    accent: Color(0xFF0E7A46),
    onAccent: Color(0xFFFFFFFF),
    text: Color(0xFF0A0A0A),
    muted: Color(0xFF6E6E73),
    border: Color(0xFFD9D9DE),
    danger: Color(0xFFB2331F),
    success: Color(0xFF0E7A46),
    fieldBg: Color(0xFF0B0D0F),
    fieldOn: Color(0xFFF2F4F6),
  );

  /// The primary. A sports app under lights.
  static const dark = AppPalette(
    bg: Color(0xFF0B0D0F),
    surface: Color(0xFF15181C),
    surfaceHigh: Color(0xFF1E2227),
    accent: Color(0xFF3DDC84),
    onAccent: Color(0xFF062A17),
    text: Color(0xFFF2F4F6),
    muted: Color(0xFF9AA3AE),
    border: Color(0xFF2A2F36),
    danger: Color(0xFFFF8A7A),
    success: Color(0xFF3DDC84),
    fieldBg: Color(0xFF0B0D0F),
    fieldOn: Color(0xFFF2F4F6),
  );
}
