import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/models/contact_location.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/core/widgets/scorebook_surface.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/contact_field.dart';
import 'package:hacktracker/features/stats/data/contact_chart_repository.dart';

final _chartRows = StreamProvider.autoDispose
    .family<
      List<PlateAppearance>,
      ({String? team, String? person, String? game, String? competition})
    >(
      (ref, args) => ContactChartRepository(ref.watch(databaseProvider)).watch(
        teamId: args.team,
        personId: args.person,
        gameId: args.game,
        competitionId: args.competition,
      ),
    );

class SprayChartScreen extends ConsumerStatefulWidget {
  const SprayChartScreen({
    super.key,
    this.teamId,
    this.gameId,
    this.competitionId,
  });
  final String? teamId, gameId, competitionId;
  @override
  ConsumerState<SprayChartScreen> createState() => _SprayChartScreenState();
}

class _SprayChartScreenState extends ConsumerState<SprayChartScreen> {
  String? _player, _game, _competition;
  String _filter = 'All';
  @override
  void initState() {
    super.initState();
    _competition = widget.competitionId;
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meStreamProvider).valueOrNull;
    final personal = widget.teamId == null && widget.gameId == null;
    final rows = ref.watch(
      _chartRows((
        team: widget.teamId,
        person: personal ? me?.id : null,
        game: widget.gameId,
        competition: _competition,
      )),
    );
    final teams = ref.watch(teamsStreamProvider).valueOrNull ?? <Team>[];
    final competitions = [
      for (final t in teams)
        ...ref.watch(competitionsStreamProvider(t.id)).valueOrNull ??
            <Competition>[],
    ];
    final roster = widget.gameId != null
        ? ref.watch(gamePlayersStreamProvider(widget.gameId!)).valueOrNull ??
              <Player>[]
        : widget.teamId != null
        ? ref.watch(playersStreamProvider(widget.teamId!)).valueOrNull ??
              <Player>[]
        : <Player>[];
    final names = {
      for (final p in roster) p.id: '${p.firstName} ${p.lastName}'.trim(),
    };
    return AppScaffold(
      title: personal ? 'Your spray chart' : 'Spray chart',
      body: rows.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('Could not load locations: $e')),
        data: (all) {
          final games = all.map((p) => p.gameId).toSet().toList();
          final selected = all
              .where(
                (p) =>
                    (_game == null || p.gameId == _game) &&
                    (_player == null || p.playerId == _player),
              )
              .toList();
          final balls = selected
              .where(
                (p) =>
                    p.result != PaResult.walk.wire &&
                    p.result != PaResult.strikeout.wire,
              )
              .toList();
          final located = balls
              .where(
                (p) => ContactLocation.parse(p.hitLocation)?.located == true,
              )
              .toList();
          final visible = located.where((p) {
            final hit = PaResult.fromWire(p.effectiveResult ?? p.result).isHit;
            return _filter == 'All' || (_filter == 'Hits' ? hit : !hit);
          }).toList();
          final points = [
            for (final p in visible)
              (
                location: ContactLocation.parse(p.hitLocation)!,
                hit: PaResult.fromWire(p.effectiveResult ?? p.result).isHit,
              ),
          ];
          final details = [
            for (final p in located) ContactLocation.parse(p.hitLocation)!,
          ];
          int direction(String d) =>
              details.where((p) => p.direction == d).length;
          final sided = details.where((p) => p.bats != null).toList();
          final pull = sided
              .where(
                (p) => p.direction == (p.bats == 'right' ? 'Left' : 'Right'),
              )
              .length;
          final opposite = sided
              .where(
                (p) => p.direction == (p.bats == 'right' ? 'Right' : 'Left'),
              )
              .length;
          final precise = details.where((p) => p.hasPoint).toList();
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (widget.gameId == null) ...[
                DropdownButtonFormField<String>(
                  initialValue: _competition ?? '',
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Season / tournament',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All competitions'),
                    ),
                    for (final c in competitions.where(
                      (c) => widget.teamId == null || c.teamId == widget.teamId,
                    ))
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() {
                    _competition = v == '' ? null : v;
                    _game = null;
                  }),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: ValueKey('$_competition-$_game'),
                  initialValue: games.contains(_game) ? _game : '',
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Game'),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('All games')),
                    for (final id in games)
                      DropdownMenuItem(
                        value: id,
                        child: _GameName(id: id),
                      ),
                  ],
                  onChanged: (v) => setState(() => _game = v == '' ? null : v),
                ),
              ],
              if (roster.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: '',
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Batter'),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('All batters'),
                    ),
                    for (final p in roster)
                      DropdownMenuItem(value: p.id, child: Text(names[p.id]!)),
                  ],
                  onChanged: (v) =>
                      setState(() => _player = v == '' ? null : v),
                ),
              ],
              const SizedBox(height: 18),
              Text(
                '${located.length} of ${balls.length} batted balls located',
                style: context.text.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final f in ['All', 'Hits', 'Other outcomes'])
                    ChoiceChip(
                      label: Text(f),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ScorebookSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ContactField(marks: points),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // The marks sit on turf, so the key uses the
                        // field's colours, not the page's.
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: context.colors.field.accent,
                        ),
                        const Text('Hit'),
                        Icon(
                          Icons.close,
                          size: 14,
                          color: context.colors.field.muted,
                        ),
                        const Text('Other outcome'),
                      ],
                    ),
                    Text(
                      '${points.where((p) => p.location.hasPoint).length} pins · ${points.where((p) => !p.location.hasPoint).length} area-only observations',
                      style: context.text.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    const Text('Estimated locations, not measured distances.'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (balls.isEmpty)
                const Text(
                  'No batted balls yet. Walks and strikeouts do not count toward location coverage.',
                ),
              if (details.isNotEmpty) ...[
                Text(
                  'Left ${direction('Left')} · Middle ${direction('Middle')} · Right ${direction('Right')}',
                  style: context.text.titleMedium,
                ),
                if (precise.isNotEmpty)
                  Text(
                    'Shallow / infield ${precise.where((p) => p.depth! < .55).length} · Mid ${precise.where((p) => p.depth! >= .55 && p.depth! <= .82).length} · Deep ${precise.where((p) => p.depth! > .82).length}',
                  ),
                if (sided.isNotEmpty)
                  Text(
                    'Pull $pull · Straight ${sided.length - pull - opposite} · Opposite $opposite (${sided.length} with known batting side)',
                  ),
                const SizedBox(height: 16),
                const ScorebookLabel('Recent located plays · up to 100'),
                for (final p in visible.reversed.take(100))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${names[p.playerId] ?? 'You'} · ${PaResult.fromWire(p.effectiveResult ?? p.result).label}',
                    ),
                    subtitle: Text(
                      '${ContactLocation.parse(p.hitLocation)!.label}${ContactLocation.parse(p.hitLocation)!.flight == null ? '' : ' · ${ContactLocation.parse(p.hitLocation)!.flight}'}',
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _GameName extends ConsumerWidget {
  const _GameName({required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = ref.watch(gameStreamProvider(id)).valueOrNull;
    return Text(
      g == null
          ? 'Game'
          : '${(g.startsAt ?? g.createdAt).toLocal().toString().substring(0, 10)} · ${g.opponentName ?? 'Team game'}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
