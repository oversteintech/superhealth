import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_health/app/l10n/app_strings.dart';
import 'package:super_health/app/l10n/string_catalog.dart';
import 'package:super_health/app/platform/after_framework.dart';
import 'package:super_health/app/theme/app_theme.dart';
import 'package:super_health/features/auth/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login screen renders SuperHealth branding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final catalog = StringCatalog.forTest({
      'en': {
        'auth.welcome_title': 'Welcome back',
        'auth.welcome_subtitle': 'Sign in to continue your health journey.',
        'auth.email': 'Email',
        'auth.password': 'Password',
        'auth.sign_in': 'Sign in',
        'auth.continue_google': 'Continue with Google',
        'auth.superadmin_hint':
            'Signing in with an Overstein admin email unlocks Super Admin.',
      },
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stringCatalogProvider.overrideWithValue(catalog),
          ...AfterFramework.createSuperHealthAfterOverrides(prefs),
        ],
        child: MaterialApp(
          theme: SuperHealthTheme.light(),
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('SuperHealth'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}