import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/config/env.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  var _sent = false;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Sign in',
      body: Padding(
        padding: EdgeInsets.all(context.themeSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connect your account. Your local scorebook stays available offline.',
              style: context.text.bodyMedium,
            ),
            SizedBox(height: context.themeSpacing.md),
            AppTextField(
              label: 'Email',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
            ),
            if (_sent) ...[
              SizedBox(height: context.themeSpacing.sm),
              AppTextField(
                label: 'Code',
                controller: _otp,
                keyboardType: TextInputType.number,
              ),
            ],
            if (_error != null) ...[
              SizedBox(height: context.themeSpacing.sm),
              Text(_error!, style: TextStyle(color: context.colors.danger)),
            ],
            SizedBox(height: context.themeSpacing.md),
            AppButton(
              label: _sent ? 'Verify' : 'Send code',
              onPressed: !Env.hasSupabase || _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final client = Supabase.instance.client;
      if (!_sent) {
        await client.auth.signInWithOtp(email: _email.text.trim());
        if (!mounted) return;
        setState(() {
          _sent = true;
          _error = null;
        });
      } else {
        await client.auth.verifyOTP(
          email: _email.text.trim(),
          token: _otp.text.trim(),
          type: OtpType.email,
        );
        final user = client.auth.currentUser;
        if (user != null) {
          if (!mounted) return;
          try {
            await ref.read(meRepositoryProvider).linkToUser(user.id);
          } catch (_) {
            await client.auth.signOut();
            rethrow;
          }
        }
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
