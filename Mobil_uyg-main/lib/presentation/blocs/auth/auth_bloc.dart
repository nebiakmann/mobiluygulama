import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:spor_salonu/data/repositories/auth_repository.dart';
import 'package:spor_salonu/data/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<CheckAuthState>((event, emit) async {
      emit(AuthLoading());
      try {
        // Check if Firebase is properly initialized first
        if (!authRepository.isFirebaseAuthInitialized()) {
          debugPrint('Firebase Auth is not properly initialized');
          emit(const AuthError('Firebase Authentication is not available'));
          return;
        }
        
        final currentUser = FirebaseAuth.instance.currentUser;
        debugPrint('Current user: ${currentUser?.email}');
        
        if (currentUser != null) {
          emit(Authenticated(currentUser));
        } else {
          emit(Unauthenticated());
        }
      } catch (e) {
        debugPrint('Error checking auth state: $e');
        emit(AuthError(e.toString()));
      }
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await authRepository.signInWithEmailAndPassword(
          event.email,
          event.password,
        );
        emit(Authenticated(userCredential.user!));
      } on FirebaseAuthException catch (e) {
        debugPrint('Firebase auth error: ${e.code} - ${e.message}');
        String errorMessage = 'An error occurred during sign in';
        
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address';
            break;
          case 'user-disabled':
            errorMessage = 'This user account has been disabled';
            break;
          default:
            errorMessage = e.message ?? 'Authentication failed';
        }
        
        emit(AuthError(errorMessage));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignUpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await authRepository.createUserWithEmailAndPassword(
          event.email,
          event.password,
        );
        emit(Authenticated(userCredential.user!));
      } on FirebaseAuthException catch (e) {
        debugPrint('Firebase auth error: ${e.code} - ${e.message}');
        String errorMessage = 'An error occurred during sign up';
        
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Email is already in use';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password accounts are not enabled';
            break;
          default:
            errorMessage = e.message ?? 'Registration failed';
        }
        
        emit(AuthError(errorMessage));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signOut();
        emit(Unauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}