import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Passwordless entry point: Apple, Google, or email one-time code.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    await ref
        .read(authControllerProvider.notifier)
        .sendCode(_email.text.trim());
    if (mounted &&
        ref.read(authControllerProvider).codeSent &&
        context.mounted) {
      await context.push(Routes.verify);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
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
                  Icon(
                    Icons.sports_baseball_outlined,
                    size: 56,
                    color: context.colors.primary,
                  ),
                  SizedBox(height: spacing.md),
                  Text(
                    'HackTracker',
                    textAlign: TextAlign.center,
                    style: context.text.titleL,
                  ),
                  SizedBox(height: spacing.xs),
                  Text(
                    'Track your slowpitch hitting stats',
                    textAlign: TextAlign.center,
                    style: context.text.body.copyWith(
                      color: context.colors.secondaryText,
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                  AppButton(
                    label: 'Continue with Apple',
                    icon: Icons.apple,
                    onPressed: busy ? null : controller.signInWithApple,
                  ),
                  SizedBox(height: spacing.sm),
                  AppButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    variant: AppButtonVariant.secondary,
                    onPressed: busy ? null : controller.signInWithGoogle,
                  ),
                  SizedBox(height: spacing.lg),
                  Text(
                    'or use email',
                    textAlign: TextAlign.center,
                    style: context.text.caption,
                  ),
                  SizedBox(height: spacing.sm),
                  AppTextField(
                    label: 'Email',
                    controller: _email,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: spacing.sm),
                  AppButton(
                    label: 'Email me a code',
                    variant: AppButtonVariant.secondary,
                    isBusy: busy,
                    onPressed: busy ? null : _sendCode,
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
