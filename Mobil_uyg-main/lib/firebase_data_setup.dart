import 'package:flutter/material.dart';
import 'package:spor_salonu/utils/firebase_initializer.dart';

/// This file can be run directly to populate Firebase with sample data
/// Run with: flutter run -d chrome lib/firebase_data_setup.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('Starting Firebase initialization and data setup...');
  
  final success = await FirebaseInitializer.initializeAppWithData();
  
  if (success) {
    print('✅ Firebase initialized and data setup complete!');
    print('You should now see sample facilities in your Firestore database');
  } else {
    print('❌ Firebase initialization failed');
    print('Please check your Firebase configuration');
  }
} 