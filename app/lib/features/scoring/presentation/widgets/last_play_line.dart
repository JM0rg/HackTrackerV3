import 'package:hacktracker/core/domain/models/contact_location.dart';
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

  /// "Mike singled", "Jess flied out". When it is you, just the play. With
  /// [named] off, just the verb: for a log that already shows the name.
  static String describe(
    FieldModeState state,
    ReplayedPa pa, {
    bool named = true,
  }) {
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
      play = named ? '$who $verb' : verb;
    }
    final extra = <String>[];
    if (state.personal) {
      if (pa.rbi > 0) extra.add('${pa.rbi} RBI');
      if (pa.batterScored && r != PaResult.homer) extra.add('you scored');
    } else if (pa.runs > 0) {
      extra.add('${pa.runs} run${pa.runs == 1 ? '' : 's'}');
    }
    // On an out the verb already carries it ("flied out"); on a hit it does
    // not, so the ball gets named.
    final kind = pa.outKind;
    if (kind != null && !r.recordsOut) extra.add(kind.label);
    final location = ContactLocation.parse(pa.hitLocation);
    if (location?.located == true) extra.add(location!.sprayRegion!);
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
      if (state.newestIsTheirHalf) {
        return SizedBox(
          height: 44,
          child: Center(
            child: TextButton.icon(
              onPressed: onUndo,
              icon: Icon(Icons.undo, size: 18, color: field.muted),
              label: Text('Their half is in the book', style: muted),
            ),
          ),
        );
      }
      // A team game is scored batter by batter, so the order is known. A
      // personal game only ever sees your own trips to the plate, and the
      // first of them is not the first of the game.
      return SizedBox(
        height: 44,
        child: Center(
          child: state.personal
              ? const SizedBox.shrink()
              : Text('First batter of the game', style: muted),
        ),
      );
    }
    // A line in the dugout, not a box: undo, the play, and the way to fix it.
    return InkWell(
      key: const Key('last-play'),
      onTap: onFix == null ? null : () => onFix!(pa),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            IconButton(
              key: const Key('undo'),
              onPressed: onUndo,
              tooltip: 'Undo',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.undo_rounded, size: 18),
              color: field.on,
              style: IconButton.styleFrom(backgroundColor: field.surfaceHigh),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (pa.effective.recordsOut ? field.onOut : field.accent)
                    .withValues(alpha: .12),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                pa.effective.label,
                style: context.text.labelMedium?.copyWith(
                  color: pa.effective.recordsOut ? field.onOut : field.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                describe(state, pa),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: muted,
              ),
            ),
            if (onFix != null)
              Icon(Icons.edit_outlined, color: field.muted, size: 15),
          ],
        ),
      ),
    );
  }
}
