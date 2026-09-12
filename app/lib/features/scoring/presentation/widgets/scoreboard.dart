import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';

/// The scoreboard, where a park keeps it: beyond the centre-field wall. Two
/// numerals, the inning between them, no box — it stands against the sky.
///
/// In a personal game with no team score, your line is the scoreboard.
///
/// Pull it down and hold to end the game; tap it for the log; swipe the
/// situation line to end the half by hand.
class Scoreboard extends StatefulWidget {
  const Scoreboard({
    super.key,
    required this.state,
    required this.onTap,
    required this.onEndGame,
    this.onRun,
    this.onEndHalf,
    this.enabled = true,
  });

  final FieldModeState state;
  final VoidCallback? onTap;
  final VoidCallback onEndGame;
  final ValueChanged<int>? onRun;
  final VoidCallback? onEndHalf;

  /// False while a play is half-answered, so a stray pull cannot end the game
  /// underneath it.
  final bool enabled;

  /// Room the board takes above the fence, at a text scale of one.
  static const height = 96.0;

  @override
  State<Scoreboard> createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  double _pull = 0;
  static const _endThreshold = 90.0;

  void _release() {
    final end = _pull >= _endThreshold;
    setState(() => _pull = 0);
    if (end && widget.enabled) widget.onEndGame();
  }

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final state = widget.state;
    return GestureDetector(
      key: const Key('hero-pull'),
      behavior: HitTestBehavior.translucent,
      onVerticalDragUpdate: (d) =>
          setState(() => _pull = (_pull + d.delta.dy).clamp(0.0, 160.0)),
      onVerticalDragEnd: (_) => _release(),
      onVerticalDragCancel: () => setState(() => _pull = 0),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          AnimatedContainer(
            duration: _pull == 0
                ? const Duration(milliseconds: 180)
                : Duration.zero,
            transform: Matrix4.translationValues(0, _pull * 0.25, 0),
            child: state.tracksScore
                ? _Bug(
                    state: state,
                    onTap: widget.onTap,
                    onRun: widget.onRun,
                    onEndHalf: widget.onEndHalf,
                  )
                : _YourLine(state: state, onTap: widget.onTap),
          ),
          if (_pull > 12)
            Positioned(
              top: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: (_pull / _endThreshold).clamp(0.0, 1.0),
                child: Text(
                  _pull >= _endThreshold
                      ? 'Release to end the game'
                      : 'Pull to end the game',
                  key: const Key('pull-hint'),
                  style: context.text.labelSmall?.copyWith(
                    color: _pull >= _endThreshold ? field.accent : field.muted,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// US · inning · THEM, then where we are.
class _Bug extends StatelessWidget {
  const _Bug({
    required this.state,
    required this.onTap,
    required this.onRun,
    required this.onEndHalf,
  });

  final FieldModeState state;
  final VoidCallback? onTap;
  final ValueChanged<int>? onRun;
  final VoidCallback? onEndHalf;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final r = state.replay;
    final theirs = !r.weBat;
    final opponent = state.game.opponentName?.trim();
    final where = [
      '${r.half == 'top' ? 'Top' : 'Bot'} ${r.inning}',
      if (theirs) 'they bat',
      if (!theirs && !state.personal) '${r.outs} out',
      if (opponent != null && opponent.isNotEmpty) opponent,
    ].join(' · ');

    final numeral = context.text.displaySmall?.copyWith(
      fontSize: 44,
      fontWeight: FontWeight.w800,
      letterSpacing: -2,
      height: 1,
      fontFeatures: tabularFigures,
    );
    final label = context.text.labelSmall?.copyWith(
      color: field.muted,
      letterSpacing: 2,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onRun == null ? null : () => onRun!(1),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 84,
                child: Column(
                  children: [
                    Text(
                      '${r.ourRuns}',
                      key: const Key('us-runs'),
                      style: numeral?.copyWith(color: field.accent),
                    ),
                    const SizedBox(height: 4),
                    Text('US', style: label),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: SizedBox(
                width: 64,
                child: Column(
                  children: [
                    // An icon, not a glyph: not every font has a triangle.
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          theirs
                              ? Icons.arrow_drop_down_rounded
                              : Icons.arrow_drop_up_rounded,
                          size: 22,
                          color: field.accent,
                        ),
                        Text(
                          '${r.inning}',
                          style: context.text.titleMedium?.copyWith(
                            color: field.on,
                            fontWeight: FontWeight.w700,
                            fontFeatures: tabularFigures,
                          ),
                        ),
                      ],
                    ),
                    if (!state.personal) ...[
                      const SizedBox(height: 7),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < 3; i++)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 2.5,
                              ),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < r.outs
                                    ? field.accent
                                    : field.lineStrong,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 84,
              child: Column(
                children: [
                  Text(
                    '${r.theirRuns}',
                    key: const Key('them-runs'),
                    style: numeral?.copyWith(color: field.on),
                  ),
                  const SizedBox(height: 4),
                  Text('THEM', style: label),
                ],
              ),
            ),
          ],
        ),
        GestureDetector(
          key: const Key('situation'),
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          // Swiping the situation line ends the half by hand.
          onHorizontalDragEnd: onEndHalf == null
              ? null
              : (d) {
                  if ((d.primaryVelocity ?? 0).abs() > 150) onEndHalf!();
                },
          child: SizedBox(
            height: 26,
            width: double.infinity,
            child: Center(
              child: Text(
                where,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodySmall?.copyWith(color: field.muted),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A personal game keeping only your own at-bats: your day, where the score
/// would be.
class _YourLine extends StatelessWidget {
  const _YourLine({required this.state, required this.onTap});

  final FieldModeState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final batter = state.batter;
    final line = batter == null ? null : state.lineFor(batter.id);
    final pas = state.replay.pas;
    final rbi = pas.fold<int>(0, (a, p) => a + p.rbi);
    final runs = pas.fold<int>(0, (a, p) => a + p.runsScored);
    final opponent = state.game.opponentName?.trim();
    final under = [
      '$rbi RBI',
      '$runs run${runs == 1 ? '' : 's'}',
      if (opponent != null && opponent.isNotEmpty) opponent,
    ].join('  ·  ');

    final big = context.text.displaySmall?.copyWith(
      fontSize: 44,
      fontWeight: FontWeight.w800,
      letterSpacing: -2,
      height: 1,
      color: field.on,
      fontFeatures: tabularFigures,
    );

    return GestureDetector(
      key: const Key('your-day'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (line == null)
            Text('—', style: big)
          else
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${line.hits}'),
                    TextSpan(
                      text: ' for ',
                      style: big?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.5,
                        color: field.muted,
                      ),
                    ),
                    TextSpan(text: '${line.atBats}'),
                  ],
                ),
                style: big,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            under,
            key: const Key('your-day-line'),
            style: context.text.bodySmall?.copyWith(color: field.muted),
          ),
        ],
      ),
    );
  }
}
