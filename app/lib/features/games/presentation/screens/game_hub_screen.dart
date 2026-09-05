import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/config/env.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/models/game_kind.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GameHubScreen extends ConsumerWidget {
  const GameHubScreen({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameStreamProvider(gameId));
    return game.when(
      data: (g) {
        if (g == null) {
          return const AppScaffold(title: 'Game', body: Center(child: Text('Missing')));
        }
        final personal = g.kind == GameKind.personal;
        final live = g.status == 'live';
        return AppScaffold(
          title: '${g.ourRuns}–${g.theirRuns}',
          body: ListView(
            padding: EdgeInsets.all(context.themeSpacing.md),
            children: [
              Text(
                g.opponentName ?? 'Game',
                style: context.text.titleMedium,
              ),
              SizedBox(height: context.themeSpacing.xs),
              Text(
                personal
                    ? 'Personal game'
                    : '${g.homeAway == 'home' ? 'Home' : 'Away'} · ${g.status}',
                style: context.text.bodySmall,
              ),
              SizedBox(height: context.themeSpacing.md),
              if (!personal) ...[
                AppButton(
                  label: 'Lineup',
                  onPressed: () => context.push('/games/$gameId/lineup'),
                ),
                SizedBox(height: context.themeSpacing.sm),
              ],
              AppButton(
                label: live ? 'Back to scoring' : 'Play / score',
                onPressed: () async {
                  final userId = Env.hasSupabase
                      ? Supabase.instance.client.auth.currentUser?.id
                      : null;
                  await ref
                      .read(scoringRepositoryProvider)
                      .enterFieldMode(g, userId: userId);
                  if (context.mounted) context.push('/games/$gameId/play');
                },
              ),
              SizedBox(height: context.themeSpacing.sm),
              AppButton(
                label: 'Box score',
                onPressed: () => context.push('/games/$gameId/box'),
              ),
            ],
          ),
        );
      },
      loading: () => const AppScaffold(title: 'Game', body: SizedBox.shrink()),
      error: (e, _) => AppScaffold(title: 'Game', body: Text('$e')),
    );
  }
}
