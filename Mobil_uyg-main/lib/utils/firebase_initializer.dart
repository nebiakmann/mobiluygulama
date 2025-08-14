import 'package:flutter/material.dart';
import 'package:spor_salonu/data/repositories/facility_repository.dart';
import 'package:spor_salonu/utils/firebase_config_handler.dart';

/// A utility class to handle Firebase initialization and data setup
class FirebaseInitializer {
  /// Initialize Firebase and return whether it was successful
  static Future<bool> initializeFirebase() async {
    try {
      final initialized = await FirebaseConfigHandler.initializeWithFallback();
      if (initialized) {
        debugPrint('Firebase initialization succeeded');
      } else {
        debugPrint('Firebase initialization failed');
      }
      return initialized;
    } catch (e) {
      debugPrint('Failed to initialize Firebase: $e');
      return false;
    }
  }

  /// Create sample facility data
  static Future<void> createSampleData() async {
    try {
      final facilityRepository = FacilityRepository();

      // Create sample facilities
      await facilityRepository.createMockFacilities();
      debugPrint('Sample facility data creation complete');
    } catch (e) {
      debugPrint('Error creating sample data: $e');
    }
  }

  /// Comprehensive initialization method that handles both Firebase setup and data creation
  static Future<bool> initializeAppWithData() async {
    final isInitialized = await initializeFirebase();
    
    if (isInitialized) {
      await createSampleData();
    }
    
    return isInitialized;
  }
} 