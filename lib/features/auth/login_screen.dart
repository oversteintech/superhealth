import 'package:after_core/after_core.dart';
import 'package:after_design_system/after_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/errors/error_handler.dart';
import '../../app/l10n/app_strings.dart';
import '../common/branding/app_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController(text: 'member@afterartificial.com');
  final _password = TextEditingController(text: 'superhealth');
  var _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _busy = true);
    try {
      final auth = ref.read(afterAuthRepositoryProvider);
      await auth.signInWithEmailPassword(
        AfterEmailPasswordCredentials(
          email: _email.text.trim(),
          password: _password.text,
        ),
      );
      await ref.read(afterAnalyticsProvider).logLogin('email');
    } on Object catch (error, stack) {
      ErrorHandler.report(error, stack);
      if (mounted) {
        ErrorHandler.showSnackBar(context, ErrorHandler.userMessage(error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _busy = true);
    try {
      await ref.read(afterAuthRepositoryProvider).signInWithGoogle();
      await ref.read(afterAnalyticsProvider).logLogin('google');
    } on Object catch (error, stack) {
      ErrorHandler.report(error, stack);
      if (mounted) {
        ErrorHandler.showSnackBar(context, ErrorHandler.userMessage(error));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = ref.tr('auth.welcome_title');
    final subtitle = ref.tr('auth.welcome_subtitle');

    return Scaffold(
      body: AfterScaffoldBody(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 48),
            const Center(child: AppLogo(size: 88)),
            const SizedBox(height: 16),
            Text(
              'SuperHealth',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 32),
            AfterTextField(
              controller: _email,
              label: ref.tr('auth.email'),
              hint: 'you@email.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AfterTextField(
              controller: _password,
              label: ref.tr('auth.password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            AfterButton(
              label: ref.tr('auth.sign_in'),
              expand: true,
              loading: _busy,
              onPressed: _busy ? null : _signIn,
            ),
            const SizedBox(height: 12),
            AfterButton(
              label: ref.tr('auth.continue_google'),
              expand: true,
              variant: AfterButtonVariant.secondary,
              onPressed: _busy ? null : _signInWithGoogle,
            ),
            const SizedBox(height: 12),
            Text(
              ref.tr('auth.superadmin_hint'),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}