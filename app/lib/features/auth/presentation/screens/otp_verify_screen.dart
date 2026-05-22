import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Enters the one-time code emailed to the user. On success the auth-state
/// stream fires and the router redirects to home automatically.
class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final ok = await ref
        .read(authControllerProvider.notifier)
        .verifyCode(_code.text.trim());
    // Router redirect handles navigation on success; just pop on failure stay.
    if (ok && mounted && context.mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final spacing = context.themeSpacing;

    return AppScaffold(
      title: 'Enter code',
      body: ListView(
        children: [
          SizedBox(height: spacing.lg),
          Text(
            'We sent a code to ${state.pendingEmail ?? 'your email'}.',
            style: context.text.body,
          ),
          SizedBox(height: spacing.lg),
          AppTextField(
            label: 'Verification code',
            controller: _code,
            hint: '123456',
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          SizedBox(height: spacing.md),
          AppButton(
            label: 'Verify',
            isBusy: state.isSaving,
            onPressed: state.isSaving ? null : _verify,
          ),
          if (state.errorMessage != null) ...[
            SizedBox(height: spacing.md),
            Text(
              state.errorMessage!,
              style: context.text.caption.copyWith(
                color: context.colors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
