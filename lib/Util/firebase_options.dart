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
    apiKey: 'AIzaSyCt_WHKMZVwmktFLsL7OGq6QUgSg-LJLwY',
    appId: '1:180177377861:web:f67666dce8482da01aa12c',
    messagingSenderId: '180177377861',
    projectId: 'wordlegame-59ecf',
    authDomain: 'wordlegame-59ecf.firebaseapp.com',
    storageBucket: 'wordlegame-59ecf.firebasestorage.app',
    measurementId: 'G-5SVB2DLQNV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBS2mAcLovwlkwWWij8AccfcksVsXTJfYE',
    appId: '1:180177377861:android:a309a338005f19ba1aa12c',
    messagingSenderId: '180177377861',
    projectId: 'wordlegame-59ecf',
    storageBucket: 'wordlegame-59ecf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBBFyWy5GQvEZRtGlGyb6Nd3LM-tEbnoeA',
    appId: '1:180177377861:ios:15689856d646aec51aa12c',
    messagingSenderId: '180177377861',
    projectId: 'wordlegame-59ecf',
    storageBucket: 'wordlegame-59ecf.firebasestorage.app',
    androidClientId:
        '180177377861-7df1qdl1jkulian63bn51faolo45ga6j.apps.googleusercontent.com',
    iosClientId:
        '180177377861-59ra6o6ioega6sgqv6qk8qs2nl0b4qeg.apps.googleusercontent.com',
    iosBundleId: 'com.example.gmaeWordle',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBBFyWy5GQvEZRtGlGyb6Nd3LM-tEbnoeA',
    appId: '1:180177377861:ios:15689856d646aec51aa12c',
    messagingSenderId: '180177377861',
    projectId: 'wordlegame-59ecf',
    storageBucket: 'wordlegame-59ecf.firebasestorage.app',
    androidClientId:
        '180177377861-7df1qdl1jkulian63bn51faolo45ga6j.apps.googleusercontent.com',
    iosClientId:
        '180177377861-59ra6o6ioega6sgqv6qk8qs2nl0b4qeg.apps.googleusercontent.com',
    iosBundleId: 'com.example.gmaeWordle',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCt_WHKMZVwmktFLsL7OGq6QUgSg-LJLwY',
    appId: '1:180177377861:web:16c805d0b67152621aa12c',
    messagingSenderId: '180177377861',
    projectId: 'wordlegame-59ecf',
    authDomain: 'wordlegame-59ecf.firebaseapp.com',
    storageBucket: 'wordlegame-59ecf.firebasestorage.app',
    measurementId: 'G-4L8GE3XC2R',
  );
}
