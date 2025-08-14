import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default FirebaseOptions for use with your Firebase apps.
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
        return web; // Use web config for Windows as fallback
      case TargetPlatform.linux:
        return web; // Use web config for Linux as fallback
      default:
        return web; // Use web as default fallback
    }
  }

  // Configuration for Web platform
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBVOXKehQhTiMm0jC5pGiIbvzxCVVz0KWI",
    authDomain: "spor-salonu-c1621.firebaseapp.com",
    projectId: "spor-salonu-c1621",
    storageBucket: "spor-salonu-c1621.appspot.com",
    messagingSenderId: "825861658125",
    appId: "1:825861658125:web:abcdef1234567890",
  );

  // Configuration for Android platform
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBVOXKehQhTiMm0jC5pGiIbvzxCVVz0KWI",
    appId: "1:825861658125:android:abcdef1234567890",
    messagingSenderId: "825861658125",
    projectId: "spor-salonu-c1621",
    storageBucket: "spor-salonu-c1621.appspot.com",
  );

  // Configuration for iOS platform
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyBVOXKehQhTiMm0jC5pGiIbvzxCVVz0KWI",
    appId: "1:825861658125:ios:abcdef1234567890",
    messagingSenderId: "825861658125",
    projectId: "spor-salonu-c1621",
    storageBucket: "spor-salonu-c1621.appspot.com",
    iosClientId: "825861658125-abcdef1234567890.apps.googleusercontent.com",
    iosBundleId: "com.example.sporSalonu",
  );

  // Configuration for macOS platform
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyBVOXKehQhTiMm0jC5pGiIbvzxCVVz0KWI",
    appId: "1:825861658125:ios:abcdef1234567890",
    messagingSenderId: "825861658125",
    projectId: "spor-salonu-c1621",
    storageBucket: "spor-salonu-c1621.appspot.com",
    iosClientId: "825861658125-abcdef1234567890.apps.googleusercontent.com",
    iosBundleId: "com.example.sporSalonu",
  );
} 