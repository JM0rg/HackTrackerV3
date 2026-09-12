import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/last_play_line.dart';
import 'package:hacktracker/features/scoring/services/game_replay.dart';

/// The game so far, newest first, in whatever room the page has between the
/// readings and the field. Up to [most] at-bats; past that, View all opens
/// the full log. The newest row is the one that can still be undone.
class PlayLog extends StatelessWidget {
  const PlayLog({
    super.key,
    required this.state,
    required this.onUndo,
    required this.onFix,
    required this.onViewAll,
    this.most = 6,
  });

  final FieldModeState state;
  final VoidCallback? onUndo;
  final ValueChanged<ReplayedPa>? onFix;
  final VoidCallback onViewAll;
  final int most;

  /// One at-bat, and the View all line.
  static const rowHeight = 38.0;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final muted = context.text.bodySmall?.copyWith(color: field.muted);
    final pas = state.replay.pas.reversed.toList();

    if (pas.isEmpty) {
      if (state.newestIsTheirHalf) {
        return Align(
          alignment: Alignment.topCenter,
          child: TextButton.icon(
            onPressed: onUndo,
            icon: Icon(Icons.undo, size: 18, color: field.muted),
            label: Text('Their half is in the book', style: muted),
          ),
        );
      }
      // A team game is scored in order, so the order is known. A personal
      // game only ever sees your own trips to the plate, and the first of
      // them is not the first of the game.
      if (state.personal) return const SizedBox.shrink();
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text('First batter of the game', style: muted),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, room) {
        final scaler = MediaQuery.textScalerOf(context);
        final row = scaler.scale(rowHeight);
        final fit = (room.maxHeight / row).floor();
        // Room for the rows that fit, and one line for the rest if needed.
        var shown = fit.clamp(0, most);
        final more = pas.length > shown;
        if (more && shown == fit && shown > 0) shown -= 1;
        if (shown <= 0) return const SizedBox.shrink();

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < shown && i < pas.length; i++)
              SizedBox(
                height: row,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: _Row(
                    state: state,
                    pa: pas[i],
                    newest: i == 0,
                    onUndo: i == 0 ? onUndo : null,
                    onFix: onFix,
                  ),
                ),
              ),
            if (pas.length > shown)
              SizedBox(
                height: row,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const Key('view-all'),
                    onPressed: onViewAll,
                    style: TextButton.styleFrom(
                      foregroundColor: field.muted,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: const Size(0, 32),
                      textStyle: context.text.bodySmall,
                    ),
                    child: Text('View all ${pas.length}'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.state,
    required this.pa,
    required this.newest,
    required this.onUndo,
    required this.onFix,
  });

  final FieldModeState state;
  final ReplayedPa pa;
  final bool newest;
  final VoidCallback? onUndo;
  final ValueChanged<ReplayedPa>? onFix;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final muted = context.text.bodySmall?.copyWith(color: field.muted);
    // The newest play is the one still in hand: it is lit, and it is the only
    // one that can be taken back. Everything above it is already history.
    final said = context.text.bodySmall?.copyWith(
      color: newest ? field.on : field.muted,
      fontWeight: newest ? FontWeight.w500 : FontWeight.w400,
    );
    final out = pa.effective.recordsOut;
    final tone = out ? field.onOut : field.accent;
    final order = state.slots.indexWhere((s) => s.playerId == pa.playerId);
    final who = state.playerById(pa.playerId);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: newest ? field.surfaceHigh.withValues(alpha: .55) : null,
        borderRadius: BorderRadius.circular(11),
      ),
      child: InkWell(
        key: newest ? const Key('last-play') : Key('pa-${pa.paId}'),
        onTap: onFix == null ? null : () => onFix!(pa),
        borderRadius: BorderRadius.circular(11),
        child: Row(
          children: [
            // Only the newest play can be taken back; the rest keep the space
            // so the tags line up down the column.
            SizedBox(
              width: 34,
              child: newest
                  ? IconButton(
                      key: const Key('undo'),
                      onPressed: onUndo,
                      tooltip: 'Undo',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.undo_rounded, size: 17),
                      color: field.bg,
                      style: IconButton.styleFrom(backgroundColor: field.on),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: tone.withValues(alpha: newest ? .20 : .12),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                pa.effective.label,
                style: context.text.labelMedium?.copyWith(
                  color: tone,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (!state.personal && who != null) ...[
              Text(
                order < 0 ? '' : '${order + 1}',
                style: muted?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                who.firstName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(
                  color: newest ? field.on : field.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                LastPlayLine.describe(state, pa, named: state.personal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: said,
              ),
            ),
            if (onFix != null)
              Icon(Icons.edit_outlined, color: field.muted, size: 14),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
