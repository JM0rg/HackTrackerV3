import 'package:hacktracker/core/theme/field_preferences.dart';
import 'package:hacktracker/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/routing/app_router.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/core/theme/theme_controller.dart';

class HackTrackerApp extends ConsumerWidget {
  const HackTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final preferences = ref.watch(fieldPreferencesProvider);
    ThemeData fieldTheme(ThemeData theme) {
      if (!preferences.outdoor) return theme;
      return theme.copyWith(
        extensions: [
          ...theme.extensions.values.where((value) => value is! AppColors),
          theme.extension<AppColors>()!.copyWith(
            field: FieldPalette.outdoor,
            fieldBg: FieldPalette.outdoor.bg,
            fieldOn: FieldPalette.outdoor.on,
          ),
        ],
      );
    }

    return MaterialApp.router(
      title: 'HackTracker',
      theme: fieldTheme(AppTheme.light()),
      darkTheme: fieldTheme(AppTheme.dark()),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations:
              preferences.reduceMotion ||
              MediaQuery.disableAnimationsOf(context),
        ),
        child: child!,
      ),
    );
  }
}
