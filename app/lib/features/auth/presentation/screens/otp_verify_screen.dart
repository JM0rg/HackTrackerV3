import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// "Check your email" — enter the 6-digit code. Single-field layout (with
/// monospace + letter-spacing for that segmented look) is preferred because
/// iOS auto-fills it from email/SMS notifications when the `oneTimeCode`
/// autofill hint is set. Auto-submits as soon as 6 digits are entered.
class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key});

  static const Duration resendCooldown = Duration(seconds: 30);

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _code = TextEditingController();
  final _focus = FocusNode();
  Timer? _ticker;
  int _secondsRemaining = 0;
  bool _submitInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recomputeCooldown();
      _startTicker();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _recomputeCooldown();
    });
  }

  void _recomputeCooldown() {
    final last = ref.read(authControllerProvider).lastSentAt;
    final remaining = last == null
        ? 0
        : (OtpVerifyScreen.resendCooldown - DateTime.now().difference(last))
              .inSeconds
              .clamp(0, OtpVerifyScreen.resendCooldown.inSeconds);
    if (remaining != _secondsRemaining) {
      setState(() => _secondsRemaining = remaining);
    }
  }

  Future<void> _onChanged(String value) async {
    // Auto-submit once we have a full 6-digit code, and only once at a time.
    if (value.length == 6 && !_submitInFlight) {
      _submitInFlight = true;
      unawaited(HapticFeedback.lightImpact());
      final ok = await ref
          .read(authControllerProvider.notifier)
          .verifyCode(value);
      if (!mounted) return;
      _submitInFlight = false;
      if (ok) {
        unawaited(HapticFeedback.mediumImpact());
        // Router redirect takes over once auth state changes.
      } else {
        unawaited(HapticFeedback.heavyImpact());
        _code.clear();
        _focus.requestFocus();
      }
    }
  }

  Future<void> _resend() async {
    final email = ref.read(authControllerProvider).pendingEmail;
    if (email == null) return;
    final ok = await ref.read(authControllerProvider.notifier).sendCode(email);
    if (!mounted || !ok) return;
    _recomputeCooldown();
    _code.clear();
    _focus.requestFocus();
  }

  void _changeEmail() {
    ref.read(authControllerProvider.notifier).changeEmail();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final spacing = context.themeSpacing;
    final colors = context.colors;
    final email = state.pendingEmail ?? 'your email';
    final canResend = _secondsRemaining == 0 && !state.isSaving;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _changeEmail,
        ),
      ),
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
                    Icons.mark_email_unread_outlined,
                    size: 48,
                    color: colors.primary,
                  ),
                  SizedBox(height: spacing.md),
                  Text(
                    'Check your email',
                    textAlign: TextAlign.center,
                    style: context.text.titleL,
                  ),
                  SizedBox(height: spacing.xs),
                  Text.rich(
                    TextSpan(
                      style: context.text.body.copyWith(
                        color: colors.secondaryText,
                      ),
                      children: [
                        const TextSpan(text: 'We sent a 6-digit code to\n'),
                        TextSpan(
                          text: email,
                          style: context.text.body.copyWith(color: colors.text),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: spacing.xl),
                  AppTextField(
                    label: 'Verification code',
                    controller: _code,
                    focusNode: _focus,
                    hint: '••••••',
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    maxLength: 6,
                    autofocus: true,
                    enabled: !state.isSaving,
                    textAlign: TextAlign.center,
                    style: context.text.titleL.copyWith(
                      letterSpacing: 12,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    onChanged: _onChanged,
                  ),
                  SizedBox(height: spacing.md),
                  if (state.isSaving)
                    Text(
                      'Verifying…',
                      textAlign: TextAlign.center,
                      style: context.text.caption.copyWith(
                        color: colors.secondaryText,
                      ),
                    )
                  else if (state.errorMessage != null)
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: context.text.caption.copyWith(
                        color: colors.danger,
                      ),
                    )
                  else
                    Text(
                      'Auto-fills from your email if you tap the suggestion '
                      'above the keyboard.',
                      textAlign: TextAlign.center,
                      style: context.text.caption.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  SizedBox(height: spacing.xl),
                  TextButton(
                    onPressed: canResend ? _resend : null,
                    child: Text(
                      canResend
                          ? 'Resend code'
                          : 'Resend code in ${_secondsRemaining}s',
                      style: context.text.label.copyWith(
                        color: canResend
                            ? colors.primary
                            : colors.secondaryText,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _changeEmail,
                    child: Text(
                      'Use a different email',
                      style: context.text.label.copyWith(
                        color: colors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
