// File generated manually from the Firebase console app configs.
// If you later add iOS/macOS/etc apps, regenerate this with `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        // Only web and Android apps have been registered so far. Run
        // `flutterfire configure` once tooling for these platforms is
        // needed, or register the platform in the Firebase console and
        // fill in its options here.
        throw UnsupportedError(
          'DefaultFirebaseOptions have only been configured for web and Android so far.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDswlrxMtzCg1henxlatcJyixIkFCqLvqE',
    authDomain: 'fixnow-80779.firebaseapp.com',
    databaseURL: 'https://fixnow-80779-default-rtdb.firebaseio.com',
    projectId: 'fixnow-80779',
    storageBucket: 'fixnow-80779.firebasestorage.app',
    messagingSenderId: '1082220904456',
    appId: '1:1082220904456:web:1c33de0066eb97bfa211bd',
    measurementId: 'G-2VE31PN5YD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBLSBVu0izCPm2AGChOg-W7TWh596pc0pc',
    databaseURL: 'https://fixnow-80779-default-rtdb.firebaseio.com',
    projectId: 'fixnow-80779',
    storageBucket: 'fixnow-80779.firebasestorage.app',
    messagingSenderId: '1082220904456',
    appId: '1:1082220904456:android:912d3ac94764b1ffa211bd',
  );
}
