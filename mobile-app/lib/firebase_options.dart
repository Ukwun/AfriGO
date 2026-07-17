import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

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
      default:
        throw UnsupportedError('Firebase is not configured for this platform');
    }
  }

  static const _apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyDy9SvL78XvIeGyDmqvz3QWhyFtP7v7RN0',
  );
  static const _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'afrigo-62e9b',
  );
  static const _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '238875658843',
  );
  static const _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'afrigo-62e9b.firebasestorage.app',
  );

  static const web = FirebaseOptions(
    apiKey: _apiKey,
    appId: String.fromEnvironment('FIREBASE_WEB_APP_ID'),
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    storageBucket: _storageBucket,
    measurementId: String.fromEnvironment('FIREBASE_MEASUREMENT_ID'),
  );

  static const android = FirebaseOptions(
    apiKey: _apiKey,
    appId: String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
      defaultValue: '1:238875658843:android:b8b171a4d65db42a838d7e',
    ),
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );

  static const ios = FirebaseOptions(
    apiKey: _apiKey,
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID'),
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosBundleId: String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID'),
  );

  static const macos = FirebaseOptions(
    apiKey: _apiKey,
    appId: String.fromEnvironment('FIREBASE_MACOS_APP_ID'),
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosBundleId: String.fromEnvironment('FIREBASE_MACOS_BUNDLE_ID'),
  );
}
