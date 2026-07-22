import 'package:after_firebase/after_firebase.dart';

/// Replace via `flutterfire configure` when Firebase app is registered.
abstract final class DefaultFirebaseOptions {
  static const isPlaceholder = AfterPlaceholderFirebaseOptions.isPlaceholder;

  static FirebaseOptions get currentPlatform =>
      AfterPlaceholderFirebaseOptions.currentPlatform;
}
