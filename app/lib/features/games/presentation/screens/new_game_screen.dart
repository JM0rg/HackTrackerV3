import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';

class NewGameScreen extends ConsumerStatefulWidget {
  const NewGameScreen({super.key});

  @override
  ConsumerState<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends ConsumerState<NewGameScreen> {
  String? _opponentId;
  final _park = TextEditingController();
  String _homeAway = 'home';
  final _selected = <String>{};

  @override
  void dispose() {
    _park.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(currentTeamIdProvider);
    if (teamId == null) {
      return const AppScaffold(
        title: 'New game',
        body: Center(child: Text('Create a team first.')),
      );
    }
    final opponents = ref.watch(opponentsStreamProvider(teamId));
    final comps = ref.watch(competitionsStreamProvider(teamId));
    return AppScaffold(
      title: 'New game',
      body: ListView(
        padding: EdgeInsets.all(context.themeSpacing.md),
        children: [
          opponents.when(
            data: (list) => DropdownButtonFormField<String?>(
              initialValue: _opponentId,
              decoration: const InputDecoration(labelText: 'Opponent'),
              items: [
                const DropdownMenuItem(value: null, child: Text('None yet')),
                for (final o in list)
                  DropdownMenuItem(value: o.id, child: Text(o.name)),
              ],
              onChanged: (v) => setState(() => _opponentId = v),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('$e'),
          ),
          TextButton(
            onPressed: () => context.push('/opponents'),
            child: const Text('Add opponent'),
          ),
          AppTextField(label: 'Park', controller: _park),
          SizedBox(height: context.themeSpacing.md),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'home', label: Text('Home')),
              ButtonSegment(value: 'away', label: Text('Away')),
            ],
            selected: {_homeAway},
            onSelectionChanged: (s) => setState(() => _homeAway = s.first),
          ),
          SizedBox(height: context.themeSpacing.xs),
          Text(
            _homeAway == 'home'
                ? 'They bat the top of the first.'
                : 'You bat the top of the first.',
            style: context.text.bodySmall,
          ),
          SizedBox(height: context.themeSpacing.md),
          Text('Counts toward', style: context.text.titleSmall),
          comps.when(
            data: (list) => Column(
              children: [
                for (final c in list)
                  CheckboxListTile(
                    title: Text(c.name),
                    subtitle: Text(c.type),
                    value: _selected.contains(c.id),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selected.add(c.id);
                        } else {
                          _selected.remove(c.id);
                        }
                      });
                    },
                  ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('$e'),
          ),
          SizedBox(height: context.themeSpacing.lg),
          AppButton(
            label: 'Create game',
            onPressed: () async {
              final id = await ref.read(trackerRepositoryProvider).createGame(
                    teamId: teamId,
                    opponentId: _opponentId,
                    park: _park.text.trim().isEmpty ? null : _park.text.trim(),
                    startsAt: DateTime.now(),
                    homeAway: _homeAway,
                    competitionIds: _selected.toList(),
                  );
              if (context.mounted) context.go('/games/$id');
            },
          ),
        ],
      ),
    );
  }
}
