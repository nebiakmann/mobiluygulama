import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A mock repository that simulates Firebase Auth functionality for testing
class MockAuthRepository {
  // Singleton pattern
  static final MockAuthRepository _instance = MockAuthRepository._internal();
  factory MockAuthRepository() => _instance;
  MockAuthRepository._internal();

  // Mock user data
  final Map<String, String> _mockUsers = {};

  // Mock current user
  User? _mockCurrentUser;

  // Check if a user is signed in
  bool isSignedIn() {
    return _mockCurrentUser != null;
  }

  // Get the current user
  User? getCurrentUser() {
    return _mockCurrentUser;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    if (_mockUsers.containsKey(email) && _mockUsers[email] == password) {
      debugPrint('Mock sign in successful: $email');
      _mockCurrentUser = _createMockUser(email);
      return _createMockUserCredential(_mockCurrentUser!);
    } else {
      debugPrint('Mock sign in failed: $email');
      throw FirebaseAuthException(
        code: 'wrong-password',
        message: 'The password is invalid or the user does not exist.',
      );
    }
  }

  // Create a new account
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    if (_mockUsers.containsKey(email)) {
      debugPrint('Mock create user failed - email already exists: $email');
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use by another account.',
      );
    } else {
      debugPrint('Mock create user successful: $email');
      _mockUsers[email] = password;
      _mockCurrentUser = _createMockUser(email);
      return _createMockUserCredential(_mockCurrentUser!);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    debugPrint('Mock sign out successful');
    _mockCurrentUser = null;
  }

  // Create a mock User object
  User _createMockUser(String email) {
    return _MockUser(
      uid: 'mock-user-${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
    );
  }

  // Create a mock UserCredential
  UserCredential _createMockUserCredential(User user) {
    return _MockUserCredential(user);
  }
}

// Mock implementations for Firebase User
class _MockUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  _MockUser({
    required this.uid,
    this.email,
    this.displayName,
  });
  
  // Implement all required methods with mock behavior
  @override
  Future<void> delete() async {}
  
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    return 'mock-id-token';
  }
  
  @override
  bool get emailVerified => true;
  
  @override
  Future<void> reload() async {}
  
  // Implement all other required properties and methods...
  @override
  dynamic noSuchMethod(Invocation invocation) {
    debugPrint('Mock User: Method called: ${invocation.memberName}');
    return null;
  }
}

// Mock implementation for UserCredential
class _MockUserCredential implements UserCredential {
  @override
  final User user;

  _MockUserCredential(this.user);

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    debugPrint('Mock UserCredential: Method called: ${invocation.memberName}');
    return null;
  }
} 