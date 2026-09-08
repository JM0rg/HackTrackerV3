import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';

/// The opponent's half as one card. Tap it for a run, swipe up to end it.
class TheirHalfCard extends StatefulWidget {
  const TheirHalfCard({
    super.key,
    required this.state,
    required this.onRun,
    required this.onEnd,
  });

  final FieldModeState state;
  final ValueChanged<int> onRun;
  final VoidCallback onEnd;

  @override
  State<TheirHalfCard> createState() => _TheirHalfCardState();
}

class _TheirHalfCardState extends State<TheirHalfCard> {
  double _dy = 0;
  bool _pop = false;

  void _tap() {
    unawaited(HapticFeedback.lightImpact());
    widget.onRun(1);
    setState(() => _pop = true);
    Future<void>.delayed(const Duration(milliseconds: 170), () {
      if (mounted) setState(() => _pop = false);
    });
  }

  void _end() {
    final dy = _dy;
    setState(() => _dy = 0);
    if (dy < -70) {
      unawaited(HapticFeedback.mediumImpact());
      widget.onEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final replay = widget.state.replay;
    final tally = widget.state.game.theirHalfRuns;
    final opponent = widget.state.game.opponentName ?? 'Them';
    final weAreHome = widget.state.game.homeAway == 'home';
    final backInning = weAreHome ? replay.inning : replay.inning + 1;

    return GestureDetector(
      key: const Key('their-half'),
      behavior: HitTestBehavior.opaque,
      onTap: _tap,
      onVerticalDragUpdate: (d) => setState(() => _dy += d.delta.dy),
      onVerticalDragEnd: (_) => _end(),
      onVerticalDragCancel: () => setState(() => _dy = 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.themeRadii.lg + 8),
          gradient: RadialGradient(
            center: const Alignment(0, -1),
            radius: 1.25,
            colors: [field.out, field.outDeep, field.bg],
            stops: const [0, 0.62, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 18,
              right: 18,
              child: Semantics(
                button: true,
                label: 'One fewer run',
                excludeSemantics: true,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: OutlinedButton(
                    key: const Key('their-minus'),
                    onPressed: tally == 0 ? null : () => widget.onRun(-1),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                      foregroundColor: field.onOut,
                      side: BorderSide(
                        color: field.onOut.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '−',
                      style: context.text.titleLarge?.copyWith(
                        color: field.onOut,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'RUNS THIS HALF',
                    style: context.text.labelSmall?.copyWith(
                      color: field.onOut.withValues(alpha: 0.8),
                      letterSpacing: 3,
                    ),
                  ),
                  AnimatedScale(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 160),
                    scale: _pop && !MediaQuery.disableAnimationsOf(context)
                        ? 1.14
                        : 1,
                    child: Text(
                      '$tally',
                      key: const Key('their-tally'),
                      style: context.text.displaySmall?.copyWith(
                        color: field.onOut,
                        fontSize: 132,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        fontFeatures: tabularFigures,
                      ),
                    ),
                  ),
                  Text(
                    opponent,
                    style: context.text.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 26,
              child: Column(
                children: [
                  Text(
                    'tap anywhere for a run',
                    style: context.text.bodySmall?.copyWith(
                      color: field.onOut.withValues(alpha: 0.85),
                    ),
                  ),
                  Text(
                    '↑ SWIPE UP TO END THEIR HALF · WE BAT ${weAreHome ? 'BOT' : 'TOP'} $backInning',
                    style: context.text.labelSmall?.copyWith(
                      color: field.onOut.withValues(alpha: 0.85),
                      fontSize: 10,
                      letterSpacing: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
