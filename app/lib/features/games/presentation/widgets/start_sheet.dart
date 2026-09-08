import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/core/widgets/surfaces.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/me/presentation/widgets/personal_team_picker.dart';

/// Start a game from one sheet. Every choice is a chip that remembers what
/// you said last time, so a repeat game is two taps from the tab.
/// Returns the new game's id, or null if dismissed.
Future<String?> showStartSheet(BuildContext context, {String? teamId}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => teamId == null
        ? const _PersonalStartSheet()
        : _TeamStartSheet(teamId: teamId),
  );
}

// ------------------------------------------------------------ personal

class _PersonalStartSheet extends ConsumerStatefulWidget {
  const _PersonalStartSheet();

  @override
  ConsumerState<_PersonalStartSheet> createState() => _PersonalStartSheetState();
}

class _PersonalStartSheetState extends ConsumerState<_PersonalStartSheet> {
  String _scope = GameScope.bat;
  String _homeAway = 'home';
  String? _teamId;
  String? _teamName;
  String? _opponent;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    final last = await ref.read(meRepositoryProvider).lastPersonalGame();
    if (!mounted) return;
    setState(() {
      if (last != null) {
        _scope = last.scope;
        _homeAway = last.homeAway;
        _teamId = last.playedForTeamId;
        _teamName = last.playedForName;
      }
      _loaded = true;
    });
  }

  Future<void> _pickTeam() async {
    final team = await showPersonalTeamPicker(context);
    if (team == null) return;
    setState(() {
      _teamId = team.id;
      _teamName = team.name;
    });
  }

  Future<void> _pickOpponent() async {
    final recent = await ref.read(meRepositoryProvider).recentOpponents();
    if (!mounted) return;
    final name = await showOpponentPicker(context, recent: recent);
    if (name == null) return;
    setState(() => _opponent = name.trim().isEmpty ? null : name.trim());
  }

  Future<void> _start() async {
    final id = await ref.read(meRepositoryProvider).createPersonalGame(
          opponentName: _opponent,
          playedForName: _teamName,
          playedForTeamId: _teamId,
          scope: _scope,
          homeAway: _homeAway,
        );
    if (mounted) Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    final keepsScore = _scope == GameScope.game;
    return _Frame(
      title: 'New game',
      children: [
        SettingsGroup(
          children: [
            SettingsRow(
              key: const Key('scope-switch'),
              title: 'Keep team scores',
              trailing: Switch(
                value: keepsScore,
                onChanged: (v) =>
                    setState(() => _scope = v ? GameScope.game : GameScope.bat),
              ),
            ),
            if (keepsScore)
              SettingsRow(
                key: const Key('home-away'),
                title: 'Your team is',
                trailing: _Segment(
                  left: 'Home',
                  right: 'Away',
                  leftSelected: _homeAway == 'home',
                  onChanged: (left) =>
                      setState(() => _homeAway = left ? 'home' : 'away'),
                ),
              ),
          ],
        ),
        SizedBox(height: spacing.md),
        SettingsGroup(
          children: [
            SettingsRow(
              key: const Key('row-team'),
              title: 'Playing with',
              value: _teamName ?? 'Add',
              onTap: _pickTeam,
            ),
            SettingsRow(
              key: const Key('row-opponent'),
              title: 'Opponent',
              value: _opponent ?? 'Add',
              onTap: _pickOpponent,
            ),
          ],
        ),
        SizedBox(height: spacing.lg),
        SizedBox(
          height: 54,
          child: FilledButton(
            key: const Key('start'),
            onPressed: _loaded ? _start : null,
            child: const Text('Start'),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- team

class _TeamStartSheet extends ConsumerStatefulWidget {
  const _TeamStartSheet({required this.teamId});

  final String teamId;

  @override
  ConsumerState<_TeamStartSheet> createState() => _TeamStartSheetState();
}

class _TeamStartSheetState extends ConsumerState<_TeamStartSheet> {
  String _homeAway = 'home';
  String? _opponentId;
  String? _opponentName;
  String? _park;
  Set<String> _competitionIds = {};
  int _lineupFromLast = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadDefaults();
  }

  Future<void> _loadDefaults() async {
    final tracker = ref.read(trackerRepositoryProvider);
    final last = await tracker.lastTeamGame(widget.teamId);
    if (last != null) {
      _homeAway = last.homeAway;
      _park = last.park;
      _competitionIds = (await tracker.gameCompetitionIds(last.id)).toSet();
      _lineupFromLast = (await tracker.lineup(last.id)).length;
      if (last.opponentId != null) {
        final opponents = await tracker.opponents(widget.teamId);
        for (final o in opponents) {
          if (o.id == last.opponentId) {
            _opponentId = o.id;
            _opponentName = o.name;
          }
        }
      }
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _pickOpponent() async {
    final tracker = ref.read(trackerRepositoryProvider);
    final opponents = await tracker.opponents(widget.teamId);
    if (!mounted) return;
    final picked = await showOpponentPicker(
      context,
      recent: [for (final o in opponents) o.name],
    );
    if (picked == null) return;
    final name = picked.trim();
    if (name.isEmpty) {
      setState(() {
        _opponentId = null;
        _opponentName = null;
      });
      return;
    }
    Opponent? match;
    for (final o in opponents) {
      if (o.name.toLowerCase() == name.toLowerCase()) match = o;
    }
    if (match == null) {
      await tracker.upsertOpponent(teamId: widget.teamId, name: name);
      final refreshed = await tracker.opponents(widget.teamId);
      for (final o in refreshed) {
        if (o.name.toLowerCase() == name.toLowerCase()) match = o;
      }
    }
    if (!mounted) return;
    setState(() {
      _opponentId = match?.id;
      _opponentName = match?.name ?? name;
    });
  }

  Future<void> _pickCompetitions() async {
    final all = await ref.read(trackerRepositoryProvider).watchCompetitions(widget.teamId).first;
    if (!mounted) return;
    final picked = await showCompetitionPicker(context, all: all, selected: _competitionIds);
    if (picked == null) return;
    setState(() => _competitionIds = picked);
  }

  Future<void> _pickPark() async {
    final park = await showTextPrompt(context, title: 'Park', initial: _park);
    if (park == null) return;
    setState(() => _park = park.trim().isEmpty ? null : park.trim());
  }

  Future<void> _start() async {
    final id = await ref.read(trackerRepositoryProvider).createGame(
          teamId: widget.teamId,
          opponentId: _opponentId,
          park: _park,
          startsAt: DateTime.now(),
          homeAway: _homeAway,
          competitionIds: _competitionIds.toList(),
        );
    if (mounted) Navigator.pop(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    final comps = ref.watch(competitionsStreamProvider(widget.teamId)).valueOrNull ??
        const <Competition>[];
    final compNames = [
      for (final c in comps)
        if (_competitionIds.contains(c.id)) c.name,
    ];
    return _Frame(
      title: 'New game',
      children: [
        SettingsGroup(
          children: [
            SettingsRow(
              key: const Key('row-opponent'),
              title: 'Opponent',
              value: _opponentName ?? 'Add',
              onTap: _pickOpponent,
            ),
            SettingsRow(
              key: const Key('home-away'),
              title: 'Your team is',
              trailing: _Segment(
                left: 'Home',
                right: 'Away',
                leftSelected: _homeAway == 'home',
                onChanged: (left) =>
                    setState(() => _homeAway = left ? 'home' : 'away'),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        SettingsGroup(
          children: [
            SettingsRow(
              key: const Key('row-lineup'),
              title: 'Lineup',
              value: _lineupFromLast > 0
                  ? '$_lineupFromLast from last game'
                  : 'Pick in the game',
            ),
            SettingsRow(
              key: const Key('row-competitions'),
              title: 'Counts toward',
              value: compNames.isEmpty ? 'Nothing' : compNames.join(', '),
              onTap: _pickCompetitions,
            ),
            SettingsRow(
              key: const Key('row-park'),
              title: 'Park',
              value: _park ?? 'Add',
              onTap: _pickPark,
            ),
          ],
        ),
        SizedBox(height: spacing.lg),
        SizedBox(
          height: 54,
          child: FilledButton(
            key: const Key('start'),
            onPressed: _loaded ? _start : null,
            child: const Text('Start'),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- pickers

/// Recent names first, then a keyboard. Returns the name, an empty string to
/// clear, or null if dismissed.
Future<String?> showOpponentPicker(BuildContext context, {required List<String> recent}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _OpponentPicker(recent: recent),
  );
}

class _OpponentPicker extends StatefulWidget {
  const _OpponentPicker({required this.recent});

  final List<String> recent;

  @override
  State<_OpponentPicker> createState() => _OpponentPickerState();
}

class _OpponentPickerState extends State<_OpponentPicker> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    return _Frame(
      title: 'Opponent',
      subtitle: widget.recent.isEmpty ? 'Who did you play?' : 'Recent first, or type a new one.',
      keyboard: true,
      children: [
        for (final name in widget.recent)
          ListTile(
            key: Key('recent-$name'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history),
            title: Text(name),
            onTap: () => Navigator.pop(context, name),
          ),
        if (widget.recent.isNotEmpty) const Divider(),
        AppTextField(
          key: const Key('opponent-name'),
          label: 'Team name',
          controller: _name,
          placeholder: 'Rockets',
        ),
        SizedBox(height: spacing.sm),
        AppButton(
          label: 'Use this name',
          onPressed: () => Navigator.pop(context, _name.text),
        ),
      ],
    );
  }
}

Future<Set<String>?> showCompetitionPicker(
  BuildContext context, {
  required List<Competition> all,
  required Set<String> selected,
}) {
  return showModalBottomSheet<Set<String>>(
    context: context,
    useSafeArea: true,
    builder: (_) => _CompetitionPicker(all: all, selected: selected),
  );
}

class _CompetitionPicker extends StatefulWidget {
  const _CompetitionPicker({required this.all, required this.selected});

  final List<Competition> all;
  final Set<String> selected;

  @override
  State<_CompetitionPicker> createState() => _CompetitionPickerState();
}

class _CompetitionPickerState extends State<_CompetitionPicker> {
  late final Set<String> _picked = {...widget.selected};

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: 'Counts toward',
      subtitle: widget.all.isEmpty ? 'No seasons or tournaments yet.' : null,
      children: [
        for (final c in widget.all)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(c.name),
            subtitle: Text(c.type),
            value: _picked.contains(c.id),
            onChanged: (v) => setState(() {
              if (v == true) {
                _picked.add(c.id);
              } else {
                _picked.remove(c.id);
              }
            }),
          ),
        SizedBox(height: context.themeSpacing.sm),
        AppButton(label: 'Done', onPressed: () => Navigator.pop(context, _picked)),
      ],
    );
  }
}

Future<String?> showTextPrompt(BuildContext context, {required String title, String? initial}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _TextPrompt(title: title, initial: initial),
  );
}

class _TextPrompt extends StatefulWidget {
  const _TextPrompt({required this.title, this.initial});

  final String title;
  final String? initial;

  @override
  State<_TextPrompt> createState() => _TextPromptState();
}

class _TextPromptState extends State<_TextPrompt> {
  late final _text = TextEditingController(text: widget.initial ?? '');

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: widget.title,
      keyboard: true,
      children: [
        AppTextField(label: widget.title, controller: _text),
        SizedBox(height: context.themeSpacing.sm),
        AppButton(label: 'Done', onPressed: () => Navigator.pop(context, _text.text)),
      ],
    );
  }
}

// --------------------------------------------------------------- pieces

/// A compact two-way switch, the way iOS puts one on the right of a row.
class _Segment extends StatelessWidget {
  const _Segment({
    required this.left,
    required this.right,
    required this.leftSelected,
    required this.onChanged,
  });

  final String left;
  final String right;
  final bool leftSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget cell(String label, bool on, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: on ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(context.themeRadii.sm + 2),
            boxShadow: on
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: context.text.labelMedium?.copyWith(
              color: on ? colors.text : colors.muted,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(context.themeRadii.sm + 4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          cell(left, leftSelected, () => onChanged(true)),
          cell(right, !leftSelected, () => onChanged(false)),
        ],
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({
    required this.title,
    this.subtitle,
    required this.children,
    this.keyboard = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool keyboard;

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.md,
          spacing.sm,
          spacing.md,
          (keyboard ? MediaQuery.of(context).viewInsets.bottom : 0) + spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetGrabber(),
            SizedBox(height: spacing.md),
            Text(title, style: context.text.headlineSmall),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(subtitle!, style: context.text.bodySmall),
              ),
            SizedBox(height: spacing.md),
            ...children,
          ],
        ),
      ),
    );
  }
}
