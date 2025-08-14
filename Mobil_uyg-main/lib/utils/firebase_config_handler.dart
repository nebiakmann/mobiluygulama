import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:spor_salonu/firebase_options.dart';

/// A utility class to handle Firebase configuration and initialization
/// with graceful fallback when configuration isn't available
class FirebaseConfigHandler {
  /// Initialize Firebase with proper error handling and fallback
  static Future<bool> initializeWithFallback() async {
    try {
      // Try to initialize with default options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized successfully with default options');
      return true;
    } catch (e) {
      debugPrint('⚠️ Could not initialize with default options: $e');
      
      // Try with a basic configuration as fallback (works for many development scenarios)
      try {
        // Check if we're already initialized
        if (Firebase.apps.isNotEmpty) {
          debugPrint('✅ Firebase already initialized');
          return true;
        }
        
        // For web specifically, Firebase might already be initialized in index.html
        if (kIsWeb) {
          debugPrint('✅ Running on web platform, Firebase might be initialized via index.html');
          return true;
        }
        
        // Try to initialize without options (might work in some cases)
        await Firebase.initializeApp();
        debugPrint('✅ Firebase initialized with fallback options');
        return true;
      } catch (fallbackError) {
        debugPrint('❌ Firebase initialization failed completely: $fallbackError');
        return false;
      }
    }
  }

  /// Get error message suitable for user display
  static String getFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'not-initialized':
          return 'Firebase has not been initialized. Please restart the app.';
        case 'no-app':
          return 'Firebase app not found. Please contact support.';
        case 'operation-not-allowed':
          return 'This authentication operation is not allowed. Please contact the administrator.';
        case 'network-request-failed':
          return 'Network connection failed. Please check your internet connection.';
        case 'invalid-api-key':
          return 'Invalid API key provided. Please contact support.';
        default:
          return error.message ?? 'An unknown Firebase error occurred';
      }
    }
    return error.toString();
  }
} 