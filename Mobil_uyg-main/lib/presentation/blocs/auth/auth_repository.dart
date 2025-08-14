import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spor_salonu/data/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if user is signed in
  Future<bool> isSignedIn() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  // Get current user
  Future<UserModel> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    
    if (currentUser == null) {
      throw Exception('No user is currently signed in');
    }
    
    final userDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();
    
    if (!userDoc.exists) {
      throw Exception('User document does not exist');
    }
    
    return UserModel.fromMap({
      'id': currentUser.uid,
      ...userDoc.data()!,
    });
  }

  // Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = userCredential.user!.uid;
      final userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (!userDoc.exists) {
        throw Exception('User document does not exist');
      }
      
      return UserModel.fromMap({
        'id': uid,
        ...userDoc.data()!,
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided');
      } else {
        throw Exception(e.message ?? 'Authentication failed');
      }
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    required String studentOrStaffId,
    required UserRole role,
    String? department,
    String? phoneNumber,
  }) async {
    try {
      // Validate student/staff ID
      final idCheckResult = await _firestore
          .collection('users')
          .where('studentOrStaffId', isEqualTo: studentOrStaffId)
          .get();
      
      if (idCheckResult.docs.isNotEmpty) {
        throw Exception('This student/staff ID is already registered');
      }
      
      // Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = userCredential.user!.uid;
      final now = DateTime.now();
      
      // Create user model
      final userModel = UserModel(
        id: uid,
        email: email,
        fullName: fullName,
        role: role,
        studentOrStaffId: studentOrStaffId,
        department: department,
        phoneNumber: phoneNumber,
        createdAt: now,
        updatedAt: now,
      );
      
      // Save user data in Firestore
      await _firestore.collection('users').doc(uid).set(userModel.toMap());
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email');
      } else {
        throw Exception(e.message ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  
  // Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? fullName,
    String? photoUrl,
    String? department,
    String? phoneNumber,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        throw Exception('User document does not exist');
      }
      
      final userData = userDoc.data()!;
      final updatedData = {
        ...userData,
        if (fullName != null) 'fullName': fullName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (department != null) 'department': department,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      
      await _firestore.collection('users').doc(userId).update(updatedData);
      
      return UserModel.fromMap({
        'id': userId,
        ...updatedData,
      });
    } catch (e) {
      throw Exception('Update profile failed: $e');
    }
  }
}