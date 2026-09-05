import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/features/me/presentation/widgets/personal_team_picker.dart';

/// Start a personal game. The first question is what to keep; only the fields
/// that choice needs appear.
class LogPersonalGameScreen extends ConsumerStatefulWidget {
  const LogPersonalGameScreen({super.key});

  @override
  ConsumerState<LogPersonalGameScreen> createState() => _LogPersonalGameScreenState();
}

class _LogPersonalGameScreenState extends ConsumerState<LogPersonalGameScreen> {
  final _opponent = TextEditingController();
  final _playedFor = TextEditingController();
  String _scope = GameScope.bat;
  String _homeAway = 'home';

  /// Set only when the name came from a saved team. Typing clears it.
  String? _playedForTeamId;

  @override
  void dispose() {
    _opponent.dispose();
    _playedFor.dispose();
    super.dispose();
  }

  Future<void> _pickTeam() async {
    final team = await showPersonalTeamPicker(context);
    if (team == null) return;
    setState(() {
      _playedFor.text = team.name;
      _playedForTeamId = team.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    final keepsScore = _scope == GameScope.game;

    return AppScaffold(
      title: 'Log my game',
      body: ListView(
        padding: EdgeInsets.all(spacing.md),
        children: [
          Text(
            'WHAT DO YOU WANT TO KEEP?',
            style: context.text.labelSmall?.copyWith(letterSpacing: 1.4),
          ),
          SizedBox(height: spacing.sm),
          _ModeCard(
            key: const Key('scope-bat'),
            title: 'My At-Bats Only',
            body: 'Just what you do at the plate. No score, no innings.',
            detail: 'hits · walks · outs · RBI',
            selected: _scope == GameScope.bat,
            onTap: () => setState(() => _scope = GameScope.bat),
          ),
          SizedBox(height: spacing.sm),
          _ModeCard(
            key: const Key('scope-game'),
            title: 'My At-Bats and Team Scores',
            body: "Your at-bats plus both teams' scores. Tap runs as they "
                'happen and end each half; you get a line score inning by inning.',
            detail: 'everything above · scores · innings',
            selected: keepsScore,
            onTap: () => setState(() => _scope = GameScope.game),
          ),
          SizedBox(height: spacing.lg),
          AppTextField(
            label: 'Opponent (optional)',
            controller: _opponent,
            placeholder: 'Who you played',
          ),
          SizedBox(height: spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Playing with (optional)',
                  controller: _playedFor,
                  placeholder: 'Pickup team name',
                  onChanged: (_) {
                    if (_playedForTeamId != null) {
                      setState(() => _playedForTeamId = null);
                    }
                  },
                ),
              ),
              SizedBox(width: spacing.sm),
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  key: const Key('pick-team'),
                  onPressed: _pickTeam,
                  child: const Text('Pick team'),
                ),
              ),
            ],
          ),
          if (_playedForTeamId != null)
            Padding(
              padding: EdgeInsets.only(top: spacing.xs, left: spacing.xs),
              child: Text(
                'Tagged to your saved team',
                key: const Key('tagged'),
                style: context.text.bodySmall?.copyWith(color: context.colors.accent),
              ),
            ),
          if (keepsScore) ...[
            SizedBox(height: spacing.lg),
            Text(
              'YOUR TEAM IS',
              style: context.text.labelSmall?.copyWith(letterSpacing: 1.4),
            ),
            SizedBox(height: spacing.sm),
            SegmentedButton<String>(
              key: const Key('home-away'),
              segments: const [
                ButtonSegment(value: 'home', label: Text('Home')),
                ButtonSegment(value: 'away', label: Text('Away')),
              ],
              selected: {_homeAway},
              onSelectionChanged: (s) => setState(() => _homeAway = s.first),
            ),
            SizedBox(height: spacing.xs),
            Text(
              _homeAway == 'home'
                  ? 'They bat the top of the first.'
                  : 'You bat the top of the first.',
              style: context.text.bodySmall,
            ),
          ],
          SizedBox(height: spacing.lg),
          AppButton(
            label: 'Start scoring',
            onPressed: () async {
              final id = await ref.read(meRepositoryProvider).createPersonalGame(
                    opponentName: _opponent.text,
                    playedForName: _playedFor.text,
                    playedForTeamId: _playedForTeamId,
                    scope: _scope,
                    homeAway: _homeAway,
                  );
              if (context.mounted) context.go('/games/$id/play');
            },
          ),
          SizedBox(height: spacing.sm),
          Text(
            'You can switch modes from the game menu later.',
            textAlign: TextAlign.center,
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    super.key,
    required this.title,
    required this.body,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String body;
  final String detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(context.themeRadii.lg);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? colors.accent : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.all(context.themeSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: context.text.titleMedium),
                    ),
                    Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      size: 20,
                      color: selected ? colors.accent : colors.border,
                    ),
                  ],
                ),
                SizedBox(height: context.themeSpacing.xs),
                Text(body, style: context.text.bodySmall),
                SizedBox(height: context.themeSpacing.xs),
                Text(
                  detail,
                  style: context.text.labelSmall?.copyWith(color: colors.accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
