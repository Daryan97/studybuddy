import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDUpdh8naNTjF02zFfdksNJXOcrQ3nUeSo',
    appId: '1:839012075264:web:286f4c19a34bcf4f67d5e5',
    messagingSenderId: '839012075264',
    projectId: 'study-buddy-d83c8',
    authDomain: 'study-buddy-d83c8.firebaseapp.com',
    storageBucket: 'study-buddy-d83c8.firebasestorage.app',
    measurementId: 'G-XSCJSW53FB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANPc7UFcKaoEi9LiG1ztbmt9mlnjLsqxQ',
    appId: '1:839012075264:android:b3f3e165a938bba567d5e5',
    messagingSenderId: '839012075264',
    projectId: 'study-buddy-d83c8',
    storageBucket: 'study-buddy-d83c8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-DbWUEmdnFx9NGXo7e66b4z9PcDsUaAw',
    appId: '1:839012075264:ios:8de002e2924bc0ef67d5e5',
    messagingSenderId: '839012075264',
    projectId: 'study-buddy-d83c8',
    storageBucket: 'study-buddy-d83c8.firebasestorage.app',
    iosBundleId: 'com.example.studybuddy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA-DbWUEmdnFx9NGXo7e66b4z9PcDsUaAw',
    appId: '1:839012075264:ios:8de002e2924bc0ef67d5e5',
    messagingSenderId: '839012075264',
    projectId: 'study-buddy-d83c8',
    storageBucket: 'study-buddy-d83c8.firebasestorage.app',
    iosBundleId: 'com.example.studybuddy',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDUpdh8naNTjF02zFfdksNJXOcrQ3nUeSo',
    appId: '1:839012075264:web:a1fb46086fc1858d67d5e5',
    messagingSenderId: '839012075264',
    projectId: 'study-buddy-d83c8',
    authDomain: 'study-buddy-d83c8.firebaseapp.com',
    storageBucket: 'study-buddy-d83c8.firebasestorage.app',
    measurementId: 'G-Q92MGPRCVS',
  );
}
