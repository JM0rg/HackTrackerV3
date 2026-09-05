import 'package:flutter/material.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'package:hacktracker/features/scoring/services/game_replay.dart';

/// What was just filed, in words. The arrow undoes it; the words open the fix
/// sheet.
class LastPlayLine extends StatelessWidget {
  const LastPlayLine({
    super.key,
    required this.state,
    required this.onUndo,
    required this.onFix,
  });

  final FieldModeState state;
  final VoidCallback? onUndo;
  final ValueChanged<ReplayedPa>? onFix;

  /// "Mike singled", "Jess flied out". When it is you, just the play.
  static String describe(FieldModeState state, ReplayedPa pa) {
    final r = pa.effective;
    final String play;
    if (state.personal) {
      play = switch (r) {
        PaResult.single => 'Single',
        PaResult.double => 'Double',
        PaResult.triple => 'Triple',
        PaResult.homer => 'Home run',
        PaResult.walk => 'Walk',
        PaResult.strikeout => 'Struck out',
        PaResult.sacFly => 'Sac fly',
        PaResult.out => _cap(pa.outKind?.verb ?? 'out'),
        PaResult.fieldersChoice => "Fielder's choice",
        PaResult.reachOnError => 'Reached on an error',
      };
    } else {
      final who = state.playerById(pa.playerId)?.firstName ?? 'Batter';
      final verb = switch (r) {
        PaResult.single => 'singled',
        PaResult.double => 'doubled',
        PaResult.triple => 'tripled',
        PaResult.homer => 'homered',
        PaResult.walk => 'walked',
        PaResult.strikeout => 'struck out',
        PaResult.sacFly => 'sac fly',
        PaResult.out => pa.outKind?.verb ?? 'out',
        PaResult.fieldersChoice => "reached on a fielder's choice",
        PaResult.reachOnError => 'reached on an error',
      };
      play = '$who $verb';
    }
    final extra = <String>[];
    if (state.personal) {
      if (pa.rbi > 0) extra.add('${pa.rbi} RBI');
      if (pa.batterScored && r != PaResult.homer) extra.add('you scored');
    } else if (pa.runs > 0) {
      extra.add('${pa.runs} run${pa.runs == 1 ? '' : 's'}');
    }
    return [play, ...extra].join(' · ');
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final pa = state.lastPa;
    final muted = context.text.bodySmall?.copyWith(color: field.muted);

    if (pa == null) {
      final text = state.newestIsTheirHalf
          ? 'Their half is in the book'
          : 'First batter of the game';
      return SizedBox(
        height: 30,
        child: Center(
          child: state.newestIsTheirHalf
              ? TextButton.icon(
                  onPressed: onUndo,
                  icon: Icon(Icons.undo, size: 16, color: field.muted),
                  label: Text(text, style: muted),
                )
              : Text(text, style: muted),
        ),
      );
    }

    final isOut = pa.effective.recordsOut;
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            key: const Key('undo'),
            onPressed: onUndo,
            tooltip: 'Undo',
            iconSize: 18,
            color: field.muted,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 30),
            icon: const Icon(Icons.undo),
          ),
          Flexible(
            child: InkWell(
              key: const Key('last-play'),
              onTap: onFix == null ? null : () => onFix!(pa),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${pa.effective.label}  ',
                        style: muted?.copyWith(
                          color: isOut ? field.onOut : field.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: describe(state, pa),
                        style: muted?.copyWith(
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.dotted,
                          decorationColor: field.muted,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
