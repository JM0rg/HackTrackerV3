import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/utils/email_validator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Single-screen passwordless entry: type your email, get a code. Unified
/// sign-up and sign-in — first-timers are created automatically on verify.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  bool _isValidEmail = false;

  @override
  void initState() {
    super.initState();
    _email.addListener(_recheck);
  }

  @override
  void dispose() {
    _email.removeListener(_recheck);
    _email.dispose();
    super.dispose();
  }

  void _recheck() {
    final valid = EmailValidator.isValid(_email.text);
    if (valid != _isValidEmail) setState(() => _isValidEmail = valid);
  }

  Future<void> _continue() async {
    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendCode(_email.text.trim());
    if (ok && mounted && context.mounted) {
      await context.push(Routes.verify);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final spacing = context.themeSpacing;
    final busy = state.isSaving;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.sports_baseball_outlined,
                      size: 56,
                      color: context.colors.primary,
                    ),
                    SizedBox(height: spacing.md),
                    Text(
                      'Get started',
                      textAlign: TextAlign.center,
                      style: context.text.titleL,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      "Enter your email and we'll send a 6-digit code. "
                      'New here? Your account is created automatically.',
                      textAlign: TextAlign.center,
                      style: context.text.body.copyWith(
                        color: context.colors.secondaryText,
                      ),
                    ),
                    SizedBox(height: spacing.xl),
                    AppTextField(
                      label: 'Email',
                      controller: _email,
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.go,
                      autofocus: true,
                      enabled: !busy,
                      onSubmitted: (_) {
                        if (_isValidEmail && !busy) _continue();
                      },
                    ),
                    SizedBox(height: spacing.md),
                    AppButton(
                      label: 'Continue',
                      isBusy: busy,
                      onPressed: (_isValidEmail && !busy) ? _continue : null,
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
                    SizedBox(height: spacing.xl),
                    Text(
                      "We'll never share your email. By continuing you agree "
                      "to HackTracker's Terms and Privacy Policy.",
                      textAlign: TextAlign.center,
                      style: context.text.caption.copyWith(
                        color: context.colors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
