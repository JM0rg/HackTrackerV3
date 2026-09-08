import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/database/app_database.dart';

/// Runs by inning, the way a scorebook shows them. Visitors on top.
class LineScore extends StatelessWidget {
  const LineScore({super.key, required this.innings, required this.game});

  final List<GameInning> innings;
  final Game game;

  @override
  Widget build(BuildContext context) {
    if (innings.isEmpty) return const SizedBox.shrink();
    final sorted = [...innings]..sort((a, b) => a.inning.compareTo(b.inning));
    final colors = context.colors;
    final labelStyle = context.text.labelSmall;
    final valueStyle = context.text.bodyMedium;
    final weAreHome = game.homeAway == 'home';

    Widget cell(String text, {bool header = false, bool bold = false}) {
      return Container(
        width: 30,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: context.themeSpacing.xs),
        child: Text(
          text,
          style: header
              ? labelStyle
              : valueStyle?.copyWith(
                  fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                ),
        ),
      );
    }

    Widget row(String label, List<int> values, int total, {bool bold = false}) {
      return Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: valueStyle?.copyWith(
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                color: bold ? colors.accent : null,
              ),
            ),
          ),
          for (final value in values) cell('$value'),
          cell('$total', bold: true),
        ],
      );
    }

    final them = row(game.opponentName ?? 'Them', [
      for (final line in sorted) line.theirRuns,
    ], game.theirRuns);
    final us = row(
      'Us',
      [for (final line in sorted) line.ourRuns],
      game.ourRuns,
      bold: true,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 72),
              for (final line in sorted) cell('${line.inning}', header: true),
              cell('R', header: true),
            ],
          ),
          if (weAreHome) ...[them, us] else ...[us, them],
        ],
      ),
    );
  }
}
