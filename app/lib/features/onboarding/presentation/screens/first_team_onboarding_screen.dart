import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../teams/domain/team.dart';
import '../../../teams/presentation/controllers/team_edit_controller.dart';

/// First-run step 2: create your first team. Shown when the user has a
/// display name but no teams yet. Reuses [TeamEditController] so the
/// create path is identical to in-app team creation.
class FirstTeamOnboardingScreen extends ConsumerStatefulWidget {
  const FirstTeamOnboardingScreen({super.key});

  @override
  ConsumerState<FirstTeamOnboardingScreen> createState() =>
      _FirstTeamOnboardingScreenState();
}

class _FirstTeamOnboardingScreenState
    extends ConsumerState<FirstTeamOnboardingScreen> {
  final _name = TextEditingController();
  TeamType _type = TeamType.coed;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(_recheck);
  }

  @override
  void dispose() {
    _name.removeListener(_recheck);
    _name.dispose();
    ref.invalidate(teamEditControllerProvider);
    super.dispose();
  }

  void _recheck() {
    final has = _name.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  Future<void> _create() async {
    await ref
        .read(teamEditControllerProvider.notifier)
        .save(name: _name.text, teamType: _type);
    // Router redirect moves to the Teams tab once teamsStream becomes non-empty.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamEditControllerProvider);
    final spacing = context.themeSpacing;
    final busy = state.isSaving;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Set up your first team',
                    textAlign: TextAlign.center,
                    style: context.text.titleL,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    "You'll add players and games next. You can rename or add "
                    'more teams anytime.',
                    textAlign: TextAlign.center,
                    style: context.text.body.copyWith(
                      color: context.colors.secondaryText,
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                  AppTextField(
                    label: 'Team name',
                    controller: _name,
                    hint: 'e.g. Sandlot Sluggers',
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                    enabled: !busy,
                    onSubmitted: (_) {
                      if (_hasText && !busy) _create();
                    },
                  ),
                  SizedBox(height: spacing.lg),
                  Text('Team type', style: context.text.label),
                  SizedBox(height: spacing.sm),
                  Wrap(
                    spacing: spacing.sm,
                    children: [
                      for (final type in TeamType.values)
                        ChoiceChip(
                          label: Text(type.label),
                          selected: _type == type,
                          onSelected: (_) => setState(() => _type = type),
                        ),
                    ],
                  ),
                  SizedBox(height: spacing.xl),
                  AppButton(
                    label: 'Create team',
                    isBusy: busy,
                    onPressed: (_hasText && !busy) ? _create : null,
                  ),
                  if (state.errorMessage != null) ...[
                    SizedBox(height: spacing.md),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: context.text.caption.copyWith(
                        color: context.colors.danger,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
