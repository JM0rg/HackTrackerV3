import 'package:hacktracker/features/scoring/presentation/widgets/runner_resolution_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/models/out_kind.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/last_play_line.dart';
import 'package:hacktracker/features/scoring/services/game_replay.dart';

const _sprayZones = [
  'P',
  'C',
  '1B',
  '2B',
  'SS',
  '3B',
  'LF',
  'LCF',
  'CF',
  'RCF',
  'RF',
];
const _contact = ['weak', 'medium', 'hard'];

Future<T?> _sheet<T>(BuildContext context, WidgetBuilder builder) {
  final field = context.colors.field;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: field.surface,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    useSafeArea: true,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(context.themeRadii.lg + 8),
      ),
    ),
    builder: (context) => SingleChildScrollView(child: builder(context)),
  );
}

class _Frame extends StatelessWidget {
  const _Frame({required this.title, this.subtitle, required this.children});

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final spacing = context.themeSpacing;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.md,
          spacing.sm,
          spacing.md,
          spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 34,
                height: 4,
                decoration: BoxDecoration(
                  color: field.lineStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              title,
              style: context.text.titleMedium?.copyWith(color: field.on),
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  subtitle!,
                  style: context.text.bodySmall?.copyWith(color: field.muted),
                ),
              ),
            SizedBox(height: spacing.sm),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    this.sub,
    required this.on,
    required this.onTap,
    this.danger = false,
    super.key,
  });

  final String label;
  final String? sub;
  final bool on;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    return Semantics(
      button: true,
      selected: on,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.themeRadii.md + 2),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: on ? field.surfaceHigh : null,
            borderRadius: BorderRadius.circular(context.themeRadii.md + 2),
            border: Border.all(
              color: on ? field.accent : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: context.text.bodyMedium?.copyWith(
                    color: danger ? field.onOut : field.on,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (sub != null)
                Text(
                  sub!,
                  style: context.text.labelSmall?.copyWith(
                    color: field.muted,
                    letterSpacing: 0.6,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.on,
    required this.onTap,
    this.tone,
    super.key,
  });

  final String label;
  final bool on;
  final VoidCallback onTap;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    return Semantics(
      button: true,
      selected: on,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.themeRadii.md),
        child: Container(
          height: 38,
          constraints: const BoxConstraints(minWidth: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? field.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(context.themeRadii.md),
            border: Border.all(
              color: on ? field.accent : field.lineStrong,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: context.text.labelMedium?.copyWith(
              color: on ? field.onAccent : (tone ?? field.on),
              fontWeight: FontWeight.w700,
              fontFeatures: tabularFigures,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _sectionLabel(BuildContext context, String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 6, left: 2),
    child: Text(
      text,
      style: context.text.labelSmall?.copyWith(
        color: context.colors.field.muted,
        letterSpacing: 1.4,
      ),
    ),
  );
}

/// Fix one play, in words. Stays live: every tap writes, the sheet re-reads.
Future<void> showFixSheet(
  BuildContext context, {
  required String gameId,
  required String paId,
}) {
  return _sheet<void>(context, (_) => _FixSheet(gameId: gameId, paId: paId));
}

class _FixSheet extends ConsumerWidget {
  const _FixSheet({required this.gameId, required this.paId});

  final String gameId;
  final String paId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fieldModeProvider(gameId)).valueOrNull;
    final pa = state?.replay.pas.where((p) => p.paId == paId).firstOrNull;
    if (state == null || pa == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return const SizedBox(height: 120);
    }
    final repo = ref.read(scoringRepositoryProvider);
    final game = state.game;
    final field = context.colors.field;
    final r = pa.requested;
    final team = !state.personal;

    Future<void> change(PaResult to) =>
        repo.changePaResult(game: game, paId: paId, result: to);

    final children = <Widget>[];

    if (team) {
      if (r == PaResult.single ||
          r == PaResult.reachOnError ||
          r == PaResult.fieldersChoice) {
        children.add(
          _Option(
            key: const Key('fix-error'),
            label: 'On an error',
            sub: 'ROE',
            on: r == PaResult.reachOnError,
            onTap: () => change(
              r == PaResult.reachOnError
                  ? PaResult.single
                  : PaResult.reachOnError,
            ),
          ),
        );
        children.add(
          _Option(
            key: const Key('fix-runnerOut'),
            label: 'Runner forced out',
            sub: 'FC',
            on: r == PaResult.fieldersChoice,
            onTap: () => change(
              r == PaResult.fieldersChoice
                  ? PaResult.single
                  : PaResult.fieldersChoice,
            ),
          ),
        );
      }
      if (r == PaResult.out ||
          r == PaResult.strikeout ||
          r == PaResult.sacFly) {
        final runScored =
            r == PaResult.sacFly || (r == PaResult.out && pa.runs > 0);
        children.add(_sectionLabel(context, 'HOW'));
        children.add(_outKindRow(context, repo, game, paId, pa));
        children.add(
          _Option(
            key: const Key('fix-runScored'),
            label: 'A run scored on it',
            sub: runScored
                ? (r == PaResult.sacFly ? 'SF' : 'OUT + RBI')
                : (pa.outKind == OutKind.ground ? 'RBI' : 'SF'),
            on: runScored,
            onTap: () => repo.setRunScoredOnOut(
              game: game,
              paId: paId,
              scored: !runScored,
            ),
          ),
        );
      }
    } else {
      if (r.earnsRbi) {
        final min = GameReplay.personalMinRbi(r);
        children.add(_sectionLabel(context, 'RBI'));
        children.add(
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var n = min; n <= GameReplay.personalMaxRbi; n++)
                _Chip(
                  key: Key('rbi-$n'),
                  label: '$n',
                  on: pa.rbi == n,
                  onTap: () =>
                      repo.setRunsOnPlay(game: game, paId: paId, runs: n),
                ),
            ],
          ),
        );
        children.add(const SizedBox(height: 6));
      }
      if (r.reachesBase && r != PaResult.homer) {
        children.add(
          _Option(
            key: const Key('fix-me'),
            label: 'I came around to score',
            on: pa.batterScored,
            onTap: () => repo.setBatterScored(
              game: game,
              paId: paId,
              scored: !pa.batterScored,
            ),
          ),
        );
      }
      if (r == PaResult.out ||
          r == PaResult.strikeout ||
          r == PaResult.sacFly) {
        children.add(_sectionLabel(context, 'HOW'));
        children.add(_outKindRow(context, repo, game, paId, pa));
      }
    }

    if (team) {
      children.add(
        TextButton.icon(
          onPressed: () =>
              showRunnerResolution(context, state: state, paId: paId),
          icon: const Icon(Icons.alt_route_rounded),
          label: const Text('Adjust runners & outs'),
        ),
      );
      children.add(
        DropdownButtonFormField<String>(
          key: ValueKey('batter-${pa.playerId}'),
          initialValue: state.roster.any((p) => p.id == pa.playerId)
              ? pa.playerId
              : null,
          decoration: const InputDecoration(labelText: 'Batter credited'),
          items: [
            for (final player in state.roster)
              DropdownMenuItem(
                value: player.id,
                child: Text('${player.firstName} ${player.lastName}'.trim()),
              ),
          ],
          onChanged: (id) async {
            if (id == null || id == pa.playerId) return;
            try {
              await repo.changeBatter(game: game, paId: paId, playerId: id);
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not change batter: $error')),
                );
              }
            }
          },
        ),
      );
    }
    children.add(_sectionLabel(context, 'CHANGE IT TO'));
    children.add(
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final to in const [
            PaResult.single,
            PaResult.double,
            PaResult.triple,
            PaResult.homer,
            PaResult.walk,
            PaResult.out,
          ])
            _Chip(
              key: Key('to-${to.wire}'),
              label: to.label,
              on: r == to,
              tone: to.isHit
                  ? field.accent
                  : (to == PaResult.out ? field.onOut : null),
              onTap: () => change(to),
            ),
        ],
      ),
    );

    if (team && state.settings.modules.capturesDetail) {
      if (state.settings.modules.spray || state.settings.modules.fielding) {
        children.add(_sectionLabel(context, 'WHERE IT WENT'));
        children.add(
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final zone in _sprayZones)
                _Chip(
                  label: zone,
                  on: pa.hitLocation == zone,
                  onTap: () => repo.setPaDetail(
                    game: game,
                    paId: paId,
                    hitLocation: pa.hitLocation == zone ? null : zone,
                    qualityOfContact: pa.qualityOfContact,
                  ),
                ),
            ],
          ),
        );
      }
      if (state.settings.modules.contact) {
        children.add(_sectionLabel(context, 'CONTACT'));
        children.add(
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final q in _contact)
                _Chip(
                  label: q,
                  on: pa.qualityOfContact == q,
                  onTap: () => repo.setPaDetail(
                    game: game,
                    paId: paId,
                    hitLocation: pa.hitLocation,
                    qualityOfContact: pa.qualityOfContact == q ? null : q,
                  ),
                ),
            ],
          ),
        );
      }
    }

    children.add(const SizedBox(height: 10));
    children.add(
      _Option(
        key: const Key('fix-delete'),
        label: 'Delete this play',
        on: false,
        danger: true,
        onTap: () async {
          await repo.deletePa(game: game, paId: paId);
          if (context.mounted) Navigator.pop(context);
        },
      ),
    );
    children.add(const SizedBox(height: 6));
    children.add(
      SizedBox(
        height: 44,
        child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: field.on,
            side: BorderSide(color: field.lineStrong),
          ),
          child: Text(
            'Done',
            style: context.text.bodyMedium?.copyWith(color: field.on),
          ),
        ),
      ),
    );

    return _Frame(
      title: '${pa.effective.label}  ${LastPlayLine.describe(state, pa)}',
      subtitle: team
          ? '${pa.half == 'top' ? 'Top' : 'Bottom'} ${pa.inning}'
          : null,
      children: children,
    );
  }
}

/// Fly · Ground · Line · K. The same row the diamond offers after a flick.
Widget _outKindRow(
  BuildContext context,
  ScoringRepository repo,
  Game game,
  String paId,
  ReplayedPa pa,
) {
  final field = context.colors.field;
  final isK = pa.requested == PaResult.strikeout;
  return Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final kind in OutKind.values)
        _Chip(
          key: Key('fix-kind-${kind.wire}'),
          label: kind.label,
          on: !isK && pa.outKind == kind,
          tone: field.onOut,
          onTap: () => repo.setOutKind(game: game, paId: paId, kind: kind),
        ),
      _Chip(
        key: const Key('fix-kind-k'),
        label: 'K',
        on: isK,
        tone: field.onOut,
        onTap: () => repo.setOutKind(game: game, paId: paId, kind: null),
      ),
    ],
  );
}

/// Every entry in the game, newest at the bottom.
Future<void> showLogSheet(BuildContext context, {required String gameId}) {
  return _sheet<void>(context, (_) => _LogSheet(gameId: gameId));
}

class _LogSheet extends ConsumerWidget {
  const _LogSheet({required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fieldModeProvider(gameId)).valueOrNull;
    if (state == null) return const SizedBox(height: 120);
    final field = context.colors.field;

    final rows = <(int sequence, Widget)>[];
    for (final pa in state.replay.pas) {
      final isOut = pa.effective.recordsOut;
      rows.add((
        pa.sequence,
        ListTile(
          key: Key('log-${pa.paId}'),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: SizedBox(
            width: 34,
            child: Text(
              pa.effective.label,
              style: context.text.labelMedium?.copyWith(
                color: isOut ? field.onOut : field.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            LastPlayLine.describe(state, pa),
            style: context.text.bodyMedium?.copyWith(color: field.on),
          ),
          trailing: state.personal
              ? null
              : Text(
                  '${pa.half == 'top' ? 'T' : 'B'}${pa.inning}',
                  style: context.text.labelSmall?.copyWith(color: field.muted),
                ),
          onTap: () {
            Navigator.pop(context);
            showFixSheet(context, gameId: gameId, paId: pa.paId);
          },
        ),
      ));
    }
    for (final event in state.events) {
      rows.add((
        event.sequence,
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: SizedBox(
            width: 34,
            child: Icon(Icons.swap_vert, size: 16, color: field.muted),
          ),
          title: Text(
            'Their half · ${event.runs} run${event.runs == 1 ? '' : 's'}',
            style: context.text.bodyMedium?.copyWith(color: field.muted),
          ),
        ),
      ));
    }
    rows.sort((a, b) => b.$1.compareTo(a.$1));

    final count = state.replay.plateAppearanceCount;
    return _Frame(
      title: 'This game',
      subtitle: rows.isEmpty
          ? null
          : '$count plate appearance${count == 1 ? '' : 's'}',
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.55,
          ),
          child: ListView(
            reverse: true,
            shrinkWrap: true,
            children: [for (final row in rows) row.$2],
          ),
        ),
      ],
    );
  }
}

enum GameMenuAction { endGame, editLineup, boxScore, switchScope }

Future<GameMenuAction?> showGameMenu(
  BuildContext context,
  FieldModeState state,
) {
  return _sheet<GameMenuAction>(context, (ctx) {
    final field = ctx.colors.field;
    Widget item(IconData icon, String title, GameMenuAction action) {
      return ListTile(
        onTap: () => Navigator.pop(ctx, action),
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: field.muted),
        title: Text(
          title,
          style: ctx.text.bodyLarge?.copyWith(color: field.on),
        ),
      );
    }

    return _Frame(
      title: 'Game',
      children: [
        item(Icons.table_chart_outlined, 'Box score', GameMenuAction.boxScore),
        if (!state.personal)
          item(Icons.list_alt, 'Edit lineup', GameMenuAction.editLineup),
        if (state.personal)
          item(
            Icons.swap_horiz,
            state.tracksScore ? 'Stop keeping team scores' : 'Keep team scores',
            GameMenuAction.switchScope,
          ),
        item(Icons.flag_outlined, 'End game', GameMenuAction.endGame),
      ],
    );
  });
}
