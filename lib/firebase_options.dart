// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDHb6KwkTAB6yOEDuV3Cd8bEEVOcRD0FPo',
    appId: '1:1095777374248:web:7574d5bcb790e0ab2c651d',
    messagingSenderId: '1095777374248',
    projectId: 'reciperadar-e3526',
    authDomain: 'reciperadar-e3526.firebaseapp.com',
    storageBucket: 'reciperadar-e3526.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDlY8Ca9UkAKfCucVP8hjebzYJnPKfJ46A',
    appId: '1:1095777374248:android:a4b1c7d4e84a733b2c651d',
    messagingSenderId: '1095777374248',
    projectId: 'reciperadar-e3526',
    storageBucket: 'reciperadar-e3526.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAY56fjzZ7_SH3FB5J98Ag7wrD9ulez-FI',
    appId: '1:1095777374248:ios:b84c6da0ba4e1f872c651d',
    messagingSenderId: '1095777374248',
    projectId: 'reciperadar-e3526',
    storageBucket: 'reciperadar-e3526.appspot.com',
    iosBundleId: 'com.example.recipeRadar',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAY56fjzZ7_SH3FB5J98Ag7wrD9ulez-FI',
    appId: '1:1095777374248:ios:bef2078502232e572c651d',
    messagingSenderId: '1095777374248',
    projectId: 'reciperadar-e3526',
    storageBucket: 'reciperadar-e3526.appspot.com',
    iosBundleId: 'com.example.recipeRadar.RunnerTests',
  );
}
