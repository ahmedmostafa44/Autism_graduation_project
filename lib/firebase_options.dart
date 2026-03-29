// ─────────────────────────────────────────────────────────────────────────────
//  firebase_options.dart
//
//  HOW TO GENERATE THIS FILE:
//  1. Install FlutterFire CLI:      dart pub global activate flutterfire_cli
//  2. Login to Firebase:            firebase login
//  3. Run in project root:          flutterfire configure
//  4. Choose your Firebase project  (or create one at console.firebase.google.com)
//  5. FlutterFire will auto-generate this file with your real keys.
//
//  The placeholder values below will cause Firebase to throw at runtime.
//  Replace them by running the command above.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Replace all values below with output of `flutterfire configure` ──

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBbfC4N5bpLnQ6FwKKNxUKfoSsc5DMiZSs',
    appId: '1:968730517795:android:f4b3267ffa3dbec2782c96',
    messagingSenderId: '968730517795',
    projectId: 'autismapp-50a04',
    storageBucket: 'autismapp-50a04.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBbfC4N5bpLnQ6FwKKNxUKfoSsc5DMiZSs',
    appId:
        '1:968730517795:ios:f4b3267ffa3dbec2782c96', // Placeholder but at least better than YOUR_...
    messagingSenderId: '968730517795',
    projectId: 'autismapp-50a04',
    storageBucket: 'autismapp-50a04.firebasestorage.app',
    iosBundleId: 'com.example.autismApp',
  );
}
