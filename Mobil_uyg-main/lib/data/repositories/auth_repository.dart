import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:spor_salonu/data/repositories/mock_auth_repository.dart';
import 'package:spor_salonu/utils/firebase_config_handler.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final MockAuthRepository _mockAuthRepository = MockAuthRepository();
  bool _useMock = false;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    // Check if Firebase is available, if not use mock
    try {
      _firebaseAuth.authStateChanges();
    } catch (e) {
      _useMock = true;
      debugPrint('Firebase Auth not available, using mock: $e');
    }
  }

  // Get the current user
  User? getCurrentUser() {
    try {
      if (_useMock) {
        return _mockAuthRepository.getCurrentUser();
      }
      return _firebaseAuth.currentUser;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      _useMock = true;
      return _mockAuthRepository.getCurrentUser();
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (_useMock) {
        return await _mockAuthRepository.signInWithEmailAndPassword(email, password);
      }
      
      _checkFirebaseAvailability();
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth exception: ${e.code} - ${e.message}');
      throw Exception(FirebaseConfigHandler.getFirebaseErrorMessage(e));
    } catch (e) {
      debugPrint('Failed to sign in with Firebase, trying mock: $e');
      _useMock = true;
      return await _mockAuthRepository.signInWithEmailAndPassword(email, password);
    }
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      if (_useMock) {
        return await _mockAuthRepository.createUserWithEmailAndPassword(email, password);
      }
      
      _checkFirebaseAvailability();
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase auth exception: ${e.code} - ${e.message}');
      throw Exception(FirebaseConfigHandler.getFirebaseErrorMessage(e));
    } catch (e) {
      debugPrint('Failed to create user with Firebase, trying mock: $e');
      _useMock = true;
      return await _mockAuthRepository.createUserWithEmailAndPassword(email, password);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      if (_useMock) {
        await _mockAuthRepository.signOut();
        return;
      }
      
      _checkFirebaseAvailability();
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Failed to sign out with Firebase, trying mock: $e');
      _useMock = true;
      await _mockAuthRepository.signOut();
    }
  }
  
  // Check if Firebase Auth is properly initialized
  bool isFirebaseAuthInitialized() {
    if (_useMock) return true; // Mock is always "initialized"
    
    try {
      _firebaseAuth.authStateChanges();
      return true;
    } catch (e) {
      debugPrint('Firebase Auth not initialized: $e');
      _useMock = true;
      return false;
    }
  }
  
  // Throw an exception if Firebase is not available
  void _checkFirebaseAvailability() {
    if (!isFirebaseAuthInitialized() && !_useMock) {
      throw FirebaseAuthException(
        code: 'not-initialized',
        message: 'Firebase Auth is not properly initialized',
      );
    }
  }
} 