// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAIIW_37iXYxGEP97kLyOFl2aKn9XQvOiw',
    appId: '1:740726719587:web:9b4c2178a9c2481328a456',
    messagingSenderId: '740726719587',
    projectId: 'quiz-master-432cc',
    authDomain: 'quiz-master-432cc.firebaseapp.com',
    storageBucket: 'quiz-master-432cc.firebasestorage.app',
    measurementId: 'G-ZLLQTVJKC8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5PyLaTYjT8jeO6VQWefDiV4MsePgVESs',
    appId: '1:740726719587:android:2a5cd62c4ad7b43728a456',
    messagingSenderId: '740726719587',
    projectId: 'quiz-master-432cc',
    storageBucket: 'quiz-master-432cc.firebasestorage.app',
  );
}
