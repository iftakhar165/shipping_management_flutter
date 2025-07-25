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
    apiKey: 'AIzaSyD8E_9mN_p2Q3r4S5t6U7v8W9x0Y1z2A3b',
    appId: '1:123456789012:web:abcdef0123456789abcdef',
    messagingSenderId: '123456789012',
    projectId: 'shipping-management-app',
    authDomain: 'shipping-management-app.firebaseapp.com',
    storageBucket: 'shipping-management-app.appspot.com',
    measurementId: 'G-ABCDEFGHIJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8E_9mN_p2Q3r4S5t6U7v8W9x0Y1z2A3b',
    appId: '1:123456789012:android:abcdef0123456789abcdef',
    messagingSenderId: '123456789012',
    projectId: 'shipping-management-app',
    storageBucket: 'shipping-management-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD8E_9mN_p2Q3r4S5t6U7v8W9x0Y1z2A3b',
    appId: '1:123456789012:ios:abcdef0123456789abcdef',
    messagingSenderId: '123456789012',
    projectId: 'shipping-management-app',
    storageBucket: 'shipping-management-app.appspot.com',
    iosBundleId: 'com.example.shippingManagementApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD8E_9mN_p2Q3r4S5t6U7v8W9x0Y1z2A3b',
    appId: '1:123456789012:ios:abcdef0123456789abcdef',
    messagingSenderId: '123456789012',
    projectId: 'shipping-management-app',
    storageBucket: 'shipping-management-app.appspot.com',
    iosBundleId: 'com.example.shippingManagementApp',
  );
}