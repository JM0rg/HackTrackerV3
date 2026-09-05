import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/config/env.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeamSettingsScreen extends ConsumerStatefulWidget {
  const TeamSettingsScreen({super.key});
  @override
  ConsumerState<TeamSettingsScreen> createState() => _TeamSettingsScreenState();
}

class _TeamSettingsScreenState extends ConsumerState<TeamSettingsScreen> {
  String? _invite;
  final _join = TextEditingController();

  @override
  void dispose() {
    _join.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(currentTeamIdProvider);
    final teams = ref.watch(teamsStreamProvider);
    final user = ref.watch(authUserProvider).valueOrNull;
    final signedIn = user != null;

    return AppScaffold(
      title: 'Team settings',
      body: ListView(
        padding: EdgeInsets.all(context.themeSpacing.md),
        children: [
          teams.when(
            data: (list) {
              if (list.isEmpty) {
                return Text(
                  'Create a team to edit rules and modules.',
                  style: context.text.bodySmall,
                );
              }
              final id = teamId ?? list.first.id;
              final team = list.where((t) => t.id == id).firstOrNull;
              if (team == null) return const SizedBox.shrink();
              final settings = jsonDecode(team.settings) as Map<String, dynamic>;
              final modules = (settings['modules'] as Map<String, dynamic>? ?? {});
              final rules = (settings['rules'] as Map<String, dynamic>? ?? {});
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scoring modules', style: context.text.titleMedium),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Spray chart'),
                    value: modules['spray'] == true,
                    onChanged: (v) => _set(team, settings, modules: {'spray': v}),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fielding'),
                    value: modules['fielding'] == true,
                    onChanged: (v) => _set(team, settings, modules: {'fielding': v}),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Quality of contact'),
                    value: modules['contact'] == true,
                    onChanged: (v) => _set(team, settings, modules: {'contact': v}),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hide leaderboard'),
                    value: rules['hideLeaderboard'] == true,
                    onChanged: (v) => _set(team, settings, rules: {'hideLeaderboard': v}),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Coed: male walk is two bases'),
                    value: rules['coedMaleWalkTwoBases'] == true,
                    onChanged: (v) => _set(team, settings, rules: {'coedMaleWalkTwoBases': v}),
                  ),
                  SizedBox(height: context.themeSpacing.md),
                  Text('Sync & invites', style: context.text.titleMedium),
                  SizedBox(height: context.themeSpacing.sm),
                  if (!signedIn)
                    AppCard(
                      onTap: Env.hasSupabase ? () => context.push('/sign-in') : null,
                      child: Text(
                        'Sign in to invite teammates and sync this team.',
                        style: context.text.bodyMedium,
                      ),
                    )
                  else ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Create player invite'),
                      subtitle: Text(_invite ?? 'Generates a code teammates can join with'),
                      onTap: () async {
                        final code = await ref.read(trackerRepositoryProvider).createInvite(
                              teamId: id,
                              role: 'player',
                            );
                        setState(() => _invite = code);
                      },
                    ),
                    AppTextField(label: 'Join a team with a code', controller: _join),
                    SizedBox(height: context.themeSpacing.sm),
                    AppButton(
                      label: 'Join',
                      onPressed: Env.hasSupabase
                          ? () async {
                              await Supabase.instance.client.rpc(
                                'join_team_with_code',
                                params: {'p_code': _join.text.trim()},
                              );
                            }
                          : null,
                    ),
                  ],
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('$e'),
          ),
        ],
      ),
    );
  }

  Future<void> _set(
    dynamic team,
    Map<String, dynamic> settings, {
    Map<String, dynamic>? modules,
    Map<String, dynamic>? rules,
  }) async {
    final next = Map<String, dynamic>.from(settings);
    if (modules != null) {
      next['modules'] = {
        ...(settings['modules'] as Map<String, dynamic>? ?? {}),
        ...modules,
      };
    }
    if (rules != null) {
      next['rules'] = {
        ...(settings['rules'] as Map<String, dynamic>? ?? {}),
        ...rules,
      };
    }
    await ref.read(trackerRepositoryProvider).updateTeamSettings(team.id as String, next);
  }
}
