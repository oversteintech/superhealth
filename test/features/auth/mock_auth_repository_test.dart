import 'package:after_core/after_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('email/password sign-in persists across a fresh repo instance', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 'superhealth',
    );

    final user = await auth.signInWithEmailPassword(
      const AfterEmailPasswordCredentials(
        email: 'member@overstein.com',
        password: 'any',
      ),
    );
    expect(user.email, 'member@overstein.com');

    final restored = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 'superhealth',
    );
    final session = await restored.getCurrentSession();
    expect(session.isAuthenticated, isTrue);
    expect(session.user?.email, 'member@overstein.com');

    await restored.signOut();
    expect((await restored.getCurrentSession()).isAuthenticated, isFalse);
  });

  test('signing in with an Overstein admin email grants superadmin claim',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 'superhealth',
      mockGoogleEmailForTests: 'ayhanuzundal@gmail.com',
    );

    final user = await auth.signInWithGoogle();
    expect(user.email, 'ayhanuzundal@gmail.com');
    expect(user.providers, contains(AfterAuthProvider.google));
    expect(user.claims['superadmin'], isTrue);
    expect(AfterSuperAdmin.isSuperAdminEmail(user.email), isTrue);
  });

  test('regular Google emails do not become superadmin', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = PrefsGoogleAuthRepository(
      prefs,
      prefsKeyPrefix: 'superhealth',
      mockGoogleEmailForTests: 'member@gmail.com',
    );

    final user = await auth.signInWithGoogle();
    expect(user.claims['superadmin'], isNull);
    expect(AfterSuperAdmin.isSuperAdminEmail(user.email), isFalse);
  });
}
