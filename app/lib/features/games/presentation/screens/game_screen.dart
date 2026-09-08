import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/games/presentation/screens/wrap_screen.dart';
import 'package:hacktracker/features/scoring/presentation/screens/field_mode_screen.dart';

/// One route for a game. A game still going is Field Mode; a finished one is
/// its wrap-up. Ending or reopening a game just re-renders in place.
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameStreamProvider(gameId));
    return game.when(
      data: (g) {
        if (g == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('That game is gone.'),
                  SizedBox(height: context.themeSpacing.md),
                  OutlinedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          );
        }
        if (g.status == 'final') return WrapScreen(gameId: gameId);
        return FieldModeScreen(gameId: gameId);
      },
      loading: () => Scaffold(backgroundColor: context.colors.field.bg),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }
}
