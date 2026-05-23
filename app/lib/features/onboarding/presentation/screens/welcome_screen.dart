import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/welcome_controller.dart';

/// First-run step 1: "What should we call you?" — only shown when the user
/// has no `profiles.display_name` yet. The router redirect advances onward
/// once this saves.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _name = TextEditingController();
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
    super.dispose();
  }

  void _recheck() {
    final has = _name.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  Future<void> _continue() async {
    await ref
        .read(welcomeControllerProvider.notifier)
        .saveDisplayName(_name.text);
    // Router redirect picks up the profile update and moves to the next step.
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(welcomeControllerProvider);
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
                    'Welcome to HackTracker 👋',
                    textAlign: TextAlign.center,
                    style: context.text.titleL,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    'What should we call you?',
                    textAlign: TextAlign.center,
                    style: context.text.body.copyWith(
                      color: context.colors.secondaryText,
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                  AppTextField(
                    label: 'Your name',
                    controller: _name,
                    hint: 'e.g. Casey Morgan',
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                    enabled: !busy,
                    onSubmitted: (_) {
                      if (_hasText && !busy) _continue();
                    },
                  ),
                  SizedBox(height: spacing.md),
                  AppButton(
                    label: 'Continue',
                    isBusy: busy,
                    onPressed: (_hasText && !busy) ? _continue : null,
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
