import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDummy_replace_with_actual_key',
    appId: '1:000000000000:web:00000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'afrigo-dev',
    authDomain: 'afrigo-dev.firebaseapp.com',
    databaseURL: 'https://afrigo-dev.firebaseio.com',
    storageBucket: 'afrigo-dev.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummy_replace_with_actual_key',
    appId: '1:000000000000:android:00000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'afrigo-dev',
    databaseURL: 'https://afrigo-dev.firebaseio.com',
    storageBucket: 'afrigo-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummy_replace_with_actual_key',
    appId: '1:000000000000:ios:00000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'afrigo-dev',
    databaseURL: 'https://afrigo-dev.firebaseio.com',
    storageBucket: 'afrigo-dev.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummy_replace_with_actual_key',
    appId: '1:000000000000:macos:00000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'afrigo-dev',
    databaseURL: 'https://afrigo-dev.firebaseio.com',
    storageBucket: 'afrigo-dev.appspot.com',
  );
}
