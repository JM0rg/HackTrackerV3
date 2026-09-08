import 'package:hacktracker/features/me/presentation/widgets/scorebook_cards.dart';
import 'package:hacktracker/core/widgets/scorebook_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/models/game_kind.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/domain/models/you_filter.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/games/presentation/widgets/live_card.dart';
import 'package:hacktracker/features/games/presentation/widgets/start_sheet.dart';
import 'package:hacktracker/features/me/services/you_stats.dart';
import 'package:intl/intl.dart';

/// Home. No app bar: your name is the title, the live game is the hero, four
/// numbers sit under it, and every game is a hairline row with your line.
class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(ensureMeProvider);
    final games = ref.watch(myGamesStreamProvider);
    final teams = ref.watch(myTeamsStreamProvider);
    final pas = ref.watch(myPaRowsStreamProvider);
    final filter = ref.watch(youFilterProvider);
    final live = ref.watch(liveGameProvider);
    final lines = ref.watch(myGameLinesProvider);
    final s = context.themeSpacing;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: me.when(
          data: (person) {
            final myTeams = teams.valueOrNull ?? const <Team>[];
            final career = ref
                .read(meRepositoryProvider)
                .careerLine(pas.valueOrNull ?? const [], filter, person.id);
            final all = games.valueOrNull ?? const <Game>[];
            final visible = _filtered(
              all,
              filter,
            ).where((g) => g.id != live?.id).toList();
            final header = _Header(
              person: person,
              games: all.length,
              onEdit: () => _editName(context, ref, person),
            );

            Future<void> start() async {
              final id = await showStartSheet(context);
              if (id != null && context.mounted) context.push('/games/$id');
            }

            // Nothing logged: the invitation owns the screen. No stat row of
            // zeros, no header over an empty list, no filter with nothing to
            // filter.
            if (all.isEmpty && live == null) {
              return ListView(
                padding: EdgeInsets.fromLTRB(s.md, s.sm, s.md, 28),
                children: [
                  header,
                  const SizedBox(height: 24),
                  FirstGameCard(onStart: start),
                ],
              );
            }

            return Stack(
              children: [
                ListView(
                  padding: EdgeInsets.fromLTRB(s.md, s.sm, s.md, 150),
                  children: [
                    header,
                    if (live != null) ...[
                      SizedBox(height: s.lg),
                      LiveCard(game: live, line: lines[live.id]),
                    ],
                    SizedBox(height: s.lg),
                    CareerCard(line: career),
                    if (myTeams.isNotEmpty) ...[
                      SizedBox(height: s.md),
                      _Filters(teams: myTeams, filter: filter, ref: ref),
                    ],
                    if (visible.isNotEmpty) ...[
                      SizedBox(height: s.lg + 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              'Games',
                              style: context.text.titleLarge,
                            ),
                          ),
                          if (myTeams.isNotEmpty)
                            Text(
                              _filterName(filter, myTeams),
                              style: context.text.bodySmall,
                            ),
                        ],
                      ),
                      for (final g in visible)
                        _GameRow(game: g, line: lines[g.id]),
                    ],
                  ],
                ),
                _StartButton(onPressed: start),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Center(child: Text('$e')),
        ),
      ),
    );
  }

  List<Game> _filtered(List<Game> games, YouFilter filter) {
    return switch (filter.kind) {
      YouFilterKind.all => games,
      YouFilterKind.personal =>
        games.where((g) => g.kind == GameKind.personal).toList(),
      YouFilterKind.team =>
        games.where((g) => g.teamId == filter.teamId).toList(),
    };
  }

  String _filterName(YouFilter filter, List<Team> teams) {
    return switch (filter.kind) {
      YouFilterKind.all => 'All',
      YouFilterKind.personal => 'Free agent',
      YouFilterKind.team =>
        teams.where((t) => t.id == filter.teamId).firstOrNull?.name ?? 'Team',
    };
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    Person person,
  ) async {
    final first = TextEditingController(text: person.firstName);
    final last = TextEditingController(text: person.lastName);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          ctx.themeSpacing.md,
          ctx.themeSpacing.md,
          ctx.themeSpacing.md,
          MediaQuery.of(ctx).viewInsets.bottom + ctx.themeSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetGrabber(),
            SizedBox(height: ctx.themeSpacing.md),
            AppTextField(label: 'First name', controller: first),
            SizedBox(height: ctx.themeSpacing.sm),
            AppTextField(label: 'Last name', controller: last),
            SizedBox(height: ctx.themeSpacing.md),
            AppButton(
              label: 'Save',
              onPressed: () async {
                await ref
                    .read(meRepositoryProvider)
                    .updateMe(firstName: first.text, lastName: last.text);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
    first.dispose();
    last.dispose();
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.person,
    required this.games,
    required this.onEdit,
  });

  final Person person;
  final int games;
  final VoidCallback onEdit;

  /// 'Me' is the default nobody has replaced, so it is not a name.
  bool get _named =>
      person.firstName.trim().isNotEmpty && person.firstName != 'Me';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final month = DateFormat.MMMM().format(DateTime.now());
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(context.themeRadii.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _named ? null : colors.surfaceHigh,
                gradient: _named
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.accent,
                          colors.accent.withValues(alpha: 0.55),
                        ],
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: _named
                  ? Text(
                      person.firstName[0].toUpperCase(),
                      style: context.text.titleMedium?.copyWith(
                        color: colors.onAccent,
                      ),
                    )
                  : Icon(Icons.person, size: 22, color: colors.muted),
            ),
            SizedBox(width: context.themeSpacing.sm + 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScorebookLabel('HackTracker'),
                  const SizedBox(height: 5),
                  Text(
                    _named ? person.firstName : 'Set your name',
                    key: const Key('you-name'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _named
                        ? context.text.headlineMedium
                        // A prompt, not a name: it must not outrank the
                        // headline underneath it.
                        : context.text.titleMedium?.copyWith(
                            color: colors.muted,
                          ),
                  ),
                  if (_named && games > 0)
                    Text(
                      '$month · $games game${games == 1 ? '' : 's'}',
                      style: context.text.bodySmall,
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Account & settings',
              icon: Icon(Icons.tune_rounded, color: colors.muted),
              onPressed: () => context.push('/more'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.teams,
    required this.filter,
    required this.ref,
  });

  final List<Team> teams;
  final YouFilter filter;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    void set(YouFilter f) => ref.read(youFilterProvider.notifier).state = f;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Pill(
            label: 'All',
            on: filter.kind == YouFilterKind.all,
            onTap: () => set(const YouFilter.all()),
          ),
          _Pill(
            label: 'Free agent',
            on: filter.kind == YouFilterKind.personal,
            onTap: () => set(const YouFilter.personal()),
          ),
          for (final t in teams)
            _Pill(
              label: t.name,
              on: filter.kind == YouFilterKind.team && filter.teamId == t.id,
              onTap: () => set(YouFilter.team(t.id)),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: on ? colors.accent : colors.surfaceHigh,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                label,
                style: context.text.labelMedium?.copyWith(
                  color: on ? colors.onAccent : colors.muted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameRow extends StatelessWidget {
  const _GameRow({required this.game, required this.line});

  final Game game;
  final GameLine? line;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d = game.startsAt;
    final opponent = game.opponentName;
    final title = opponent != null && opponent.isNotEmpty
        ? opponent
        : (game.kind == GameKind.personal ? 'Pickup' : 'Game');
    final sub = <String>[
      if (game.playedForName != null) game.playedForName!,
      if (game.kind == GameKind.personal && game.scope == GameScope.bat)
        'at-bats only'
      else if (game.status == 'final')
        '${game.ourRuns > game.theirRuns
            ? 'won'
            : game.ourRuns < game.theirRuns
            ? 'lost'
            : 'tied'} ${game.ourRuns}–${game.theirRuns}'
      else
        game.status,
    ];
    return InkWell(
      key: Key('game-${game.id}'),
      onTap: () => context.push('/games/${game.id}'),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border.withValues(alpha: .5)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 38,
                  child: Text(
                    d == null
                        ? ''
                        : DateFormat('MMM\nd').format(d).toUpperCase(),
                    style: context.text.labelSmall?.copyWith(
                      height: 1.15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.text.titleSmall),
                      Text(sub.join(' · '), style: context.text.bodySmall),
                    ],
                  ),
                ),
                if (line != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        line!.summary,
                        style: context.text.titleMedium?.copyWith(
                          color: colors.text,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        [
                          if (line!.results.isNotEmpty) line!.results.join(' '),
                          if (line!.rbi > 0) '${line!.rbi} RBI',
                        ].join(' · '),
                        style: context.text.labelSmall,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One capsule, floating above the tab bar.
class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: context.themeSpacing.md,
      right: context.themeSpacing.md,
      bottom: context.themeSpacing.md,
      child: SizedBox(
        height: 54,
        child: FilledButton(
          key: const Key('start-game'),
          onPressed: onPressed,
          child: const Text('Start a game'),
        ),
      ),
    );
  }
}
