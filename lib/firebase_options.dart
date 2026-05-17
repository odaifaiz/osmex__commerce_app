// ⚠️  IMPORTANT — PLACEHOLDER FILE
// This file contains dummy values. You MUST run:
//   flutterfire configure
// in your project directory to generate the real firebase_options.dart
// with your actual Firebase project credentials.
//
// Until you run that command, the app will throw a Firebase initialization error.

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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Linux is not supported by this app.');
      default:
        throw UnsupportedError('Unsupported platform: $defaultTargetPlatform');
    }
  }

  // ── REPLACE ALL VALUES BELOW BY RUNNING: flutterfire configure ──

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBD_z0gDeGj15jGYpuM5H-qaMUeCG7q2-0',
    appId: '1:827871468249:web:294f3636202e40b239bcc8',
    messagingSenderId: '827871468249',
    projectId: 'assignment-de1ae',
    authDomain: 'assignment-de1ae.firebaseapp.com',
    storageBucket: 'assignment-de1ae.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOwJnEjdjOOvBhwVIvDXXFG4hm1L2s4u0',
    appId: '1:827871468249:android:f7685ad6c845793739bcc8',
    messagingSenderId: '827871468249',
    projectId: 'assignment-de1ae',
    storageBucket: 'assignment-de1ae.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBuQq3sMXOhqgZTeauTtU4SEdZxWVdodVc',
    appId: '1:827871468249:ios:63f0294de9a7f38f39bcc8',
    messagingSenderId: '827871468249',
    projectId: 'assignment-de1ae',
    storageBucket: 'assignment-de1ae.firebasestorage.app',
    iosBundleId: 'com.samana.samanaBakery',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBuQq3sMXOhqgZTeauTtU4SEdZxWVdodVc',
    appId: '1:827871468249:ios:63f0294de9a7f38f39bcc8',
    messagingSenderId: '827871468249',
    projectId: 'assignment-de1ae',
    storageBucket: 'assignment-de1ae.firebasestorage.app',
    iosBundleId: 'com.samana.samanaBakery',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_API_KEY',
    appId: 'REPLACE_WITH_YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    authDomain: 'REPLACE_WITH_YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'REPLACE_WITH_YOUR_PROJECT_ID.firebasestorage.app',
  );
}