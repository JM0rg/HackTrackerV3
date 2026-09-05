import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';

/// Who is up and how their day is going. In a personal game you know who you
/// are, so the day itself takes the space. Swipe it down to undo, sideways to
/// move through the order.
class BatterCard extends StatefulWidget {
  const BatterCard({
    super.key,
    required this.state,
    required this.height,
    required this.onUndo,
    required this.onNext,
    required this.onPrevious,
  });

  final FieldModeState state;
  final double height;
  final VoidCallback? onUndo;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  @override
  State<BatterCard> createState() => _BatterCardState();
}

class _BatterCardState extends State<BatterCard> {
  Offset _offset = Offset.zero;
  bool _swiping = false;

  void _end() {
    final dx = _offset.dx;
    final dy = _offset.dy;
    setState(() {
      _offset = Offset.zero;
      _swiping = false;
    });
    if (dy > 60 && dx.abs() < 50) {
      widget.onUndo?.call();
    } else if (dx < -60) {
      widget.onNext?.call();
    } else if (dx > 60) {
      widget.onPrevious?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final batter = state.batter;
    final pull = Offset(_offset.dx * 0.6, _offset.dy.clamp(0, 400) * 0.5);
    final fade = 1 -
        ((_offset.dx.abs() / 300) + (_offset.dy.clamp(0, 400) / 300))
            .clamp(0.0, 0.5);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) => setState(() => _swiping = true),
      onPanUpdate: (d) => setState(() => _offset += d.delta),
      onPanEnd: (_) => _end(),
      onPanCancel: _end,
      child: SizedBox(
        height: widget.height,
        child: AnimatedContainer(
          duration: _swiping ? Duration.zero : const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(pull.dx, pull.dy, 0),
          child: Opacity(
            opacity: fade,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 340),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.12, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.center,
                children: [...previous, ?current],
              ),
              child: KeyedSubtree(
                key: ValueKey('batter-${state.batterIndex}-${batter?.id}'),
                child: state.personal
                    ? _YourDay(state: state, hero: !state.tracksScore)
                    : _Batter(state: state),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Team game: jersey, name, and the day so far.
class _Batter extends StatelessWidget {
  const _Batter({required this.state});

  final FieldModeState state;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final batter = state.batter;
    final line = batter == null ? null : state.lineFor(batter.id);
    final jersey = batter?.jerseyNumber;
    final name = batter == null
        ? 'No lineup'
        : '${batter.firstName} ${batter.lastName}'.trim();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (jersey != null && jersey.isNotEmpty)
          Text(
            '#$jersey',
            style: context.text.labelSmall?.copyWith(
              color: field.muted,
              letterSpacing: 1.6,
              fontFeatures: tabularFigures,
            ),
          ),
        Text(
          name,
          key: const Key('card-first'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.headlineSmall?.copyWith(
            color: field.on,
            fontSize: 27,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.7,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        if (batter == null || line == null)
          Text(
            'Pick a batting order to start',
            style: context.text.bodySmall?.copyWith(color: field.muted),
          )
        else
          _DayLine(
            hits: line.hits,
            atBats: line.atBats,
            results: line.results,
            rbi: state.replay.pas
                .where((p) => p.playerId == batter.id)
                .fold<int>(0, (a, p) => a + p.rbi),
            runs: null,
            size: 15,
          ),
      ],
    );
  }
}

/// Personal game: no name. Your day is the thing. With no score to show it
/// is the biggest thing on the screen, and the opponent sits under it.
class _YourDay extends StatelessWidget {
  const _YourDay({required this.state, required this.hero});

  final FieldModeState state;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final batter = state.batter;
    final line = batter == null ? null : state.lineFor(batter.id);
    final pas = state.replay.pas;
    final rbi = pas.fold<int>(0, (a, p) => a + p.rbi);
    final runs = pas.fold<int>(0, (a, p) => a + p.runsScored);
    final opponent = state.game.opponentName?.trim();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'YOUR DAY',
          key: const Key('your-day'),
          style: context.text.labelSmall?.copyWith(
            color: field.muted,
            letterSpacing: 2.4,
            fontSize: hero ? 11 : 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        if (line == null)
          Text(
            'Nothing yet',
            style: context.text.headlineSmall?.copyWith(
              color: field.on,
              fontWeight: FontWeight.w700,
            ),
          )
        else
          _DayLine(
            hits: line.hits,
            atBats: line.atBats,
            results: line.results,
            rbi: rbi,
            runs: runs,
            size: hero ? 44 : 26,
            splitCounts: true,
          ),
        if (hero) ...[
          const SizedBox(height: 12),
          Container(
            key: const Key('opponent-pill'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: field.surfaceHigh,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              opponent == null || opponent.isEmpty
                  ? 'PERSONAL GAME'
                  : 'VS ${opponent.toUpperCase()}',
              style: context.text.labelSmall?.copyWith(
                color: field.on,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// "2 for 3" in bold, hit types as small tags, RBI and runs as words.
class _DayLine extends StatelessWidget {
  const _DayLine({
    required this.hits,
    required this.atBats,
    required this.results,
    required this.rbi,
    required this.runs,
    required this.size,
    this.splitCounts = false,
  });

  final int hits;
  final int atBats;
  final List<String> results;
  final int rbi;
  final int? runs;
  final double size;

  /// Put RBI and runs on their own line under the big line.
  final bool splitCounts;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final counts = <String>[
      if (splitCounts || rbi > 0) '$rbi RBI',
      if (runs != null && (splitCounts || runs! > 0))
        '$runs run${runs == 1 ? '' : 's'}',
    ];
    final muted = context.text.bodyMedium?.copyWith(color: field.muted, fontSize: 13.5);

    final main = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$hits for $atBats',
          style: context.text.titleMedium?.copyWith(
            color: field.on,
            fontSize: size,
            fontWeight: FontWeight.w700,
            letterSpacing: size > 40 ? -1.5 : (size > 20 ? -0.6 : 0),
            fontFeatures: tabularFigures,
          ),
        ),
        for (final r in results) _Tag(label: r),
        if (!splitCounts && counts.isNotEmpty) ...[
          Text('  ·  ', style: muted),
          Text(counts.join('  ·  '), style: muted),
        ],
      ],
    );

    if (!splitCounts) return FittedBox(fit: BoxFit.scaleDown, child: main);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(fit: BoxFit.scaleDown, child: main),
        const SizedBox(height: 4),
        Text(counts.join('  ·  '), style: muted),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final homer = label == 'HR';
    return Container(
      margin: const EdgeInsets.only(left: 5),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: homer ? field.accent : field.lineStrong,
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        style: context.text.labelSmall?.copyWith(
          color: field.accent,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
