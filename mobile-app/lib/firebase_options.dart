import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
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
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDummy0000000000000000000000000000',
    appId: '1:000000000000:web:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'afrigo-dev',
    authDomain: 'afrigo-dev.firebaseapp.com',
    databaseURL: 'https://afrigo-dev.firebaseio.com',
    storageBucket: 'afrigo-dev.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummy0000000000000000000000000000',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'afrigo-dev',
    databaseURL: 'https://afrigo-dev.firebaseio.com',
    storageBucket: 'afrigo-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummy0000000000000000000000000000',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'afrigo-dev',
    databaseURL: 'https://afrigo-dev.firebaseio.com',
    storageBucket: 'afrigo-dev.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummy0000000000000000000000000000',
    appId: '1:000000000000:macos:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'afrigo-dev',
    databaseURL: 'https://afrigo-dev.firebaseio.com',
    storageBucket: 'afrigo-dev.appspot.com',
  );
}
