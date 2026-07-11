import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for the al-quran project.
///
/// Generated from `android/app/google-services.json`.
/// Run `flutterfire configure` to add iOS/web targets.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web Firebase options are not configured yet.');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Add GoogleService-Info.plist and run flutterfire configure.',
        );
      default:
        throw UnsupportedError(
          'Firebase is not supported on this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_Z046U5aSMesd6NlobuUUS6nqMkyeroc',
    appId: '1:438868741822:android:129b0cf63ec223c72758ef',
    messagingSenderId: '438868741822',
    projectId: 'al-quran-f9fc5',
    storageBucket: 'al-quran-f9fc5.firebasestorage.app',
  );
}
