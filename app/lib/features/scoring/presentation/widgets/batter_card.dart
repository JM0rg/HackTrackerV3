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
    this.height,
    required this.onUndo,
    required this.onNext,
    required this.onPrevious,
  });

  final FieldModeState state;

  /// Null inside the floating header, where the capsule takes its height from
  /// what is in it.
  final double? height;
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
    final fade =
        1 -
        ((_offset.dx.abs() / 300) + (_offset.dy.clamp(0, 400) / 300)).clamp(
          0.0,
          0.5,
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) => setState(() => _swiping = true),
      onPanUpdate: (d) => setState(() => _offset += d.delta),
      onPanEnd: (_) => _end(),
      onPanCancel: () => setState(() {
        _offset = Offset.zero;
        _swiping = false;
      }),
      child: SizedBox(
        height: widget.height,
        child: AnimatedContainer(
          duration: _swiping || MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(pull.dx, pull.dy, 0),
          child: Opacity(
            opacity: fade,
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 340),
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
                    ? _YourDay(state: state)
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

    // A line in the dugout: no box, no label. The name under the plate is
    // the batter; nothing needs to say so.
    final next = state.onDeck;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: field.accent.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            jersey?.isNotEmpty == true
                ? jersey!
                : batter?.firstName.characters.firstOrNull ?? '—',
            style: context.text.titleMedium?.copyWith(
              color: field.accent,
              fontWeight: FontWeight.w800,
              fontFeatures: tabularFigures,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                key: const Key('card-first'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleLarge?.copyWith(
                  color: field.on,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.4,
                ),
              ),
              const SizedBox(height: 3),
              if (batter == null || line == null)
                Text(
                  'Pick a batting order to start',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                  size: 13.5,
                ),
            ],
          ),
        ),
        if (next != null) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'next',
                style: context.text.bodySmall?.copyWith(color: field.muted),
              ),
              Text(
                next.firstName,
                key: const Key('next-up'),
                style: context.text.bodyMedium?.copyWith(
                  color: field.on,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Personal game keeping team score: your day, as a line in the dugout. With
/// no team score the day is the scoreboard instead, and lives beyond the wall.
class _YourDay extends StatelessWidget {
  const _YourDay({required this.state});

  final FieldModeState state;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final batter = state.batter;
    final line = batter == null ? null : state.lineFor(batter.id);
    final pas = state.replay.pas;
    final rbi = pas.fold<int>(0, (a, p) => a + p.rbi);
    final runs = pas.fold<int>(0, (a, p) => a + p.runsScored);

    return Row(
      key: const Key('your-day'),
      children: [
        Expanded(
          child: line == null
              ? Text(
                  'Your first at-bat',
                  style: context.text.titleMedium?.copyWith(color: field.on),
                )
              : _DayLine(
                  hits: line.hits,
                  atBats: line.atBats,
                  results: line.results,
                  rbi: rbi,
                  runs: runs,
                  size: 22,
                ),
        ),
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
  });

  final int hits;
  final int atBats;
  final List<String> results;
  final int rbi;
  final int? runs;
  final double size;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final counts = <String>[
      if (rbi > 0) '$rbi RBI',
      if (runs != null && runs! > 0) '$runs run${runs == 1 ? '' : 's'}',
    ];
    final muted = context.text.bodyMedium?.copyWith(
      color: field.muted,
      fontSize: 13.5,
    );

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
        if (counts.isNotEmpty) ...[
          Text('  ·  ', style: muted),
          Text(counts.join('  ·  '), style: muted),
        ],
      ],
    );

    return FittedBox(fit: BoxFit.scaleDown, child: main);
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
