part of 'auth_bloc.dart';

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String studentOrStaffId;
  final UserRole role;
  final String? department;
  final String? phoneNumber;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.studentOrStaffId,
    required this.role,
    this.department,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        fullName,
        studentOrStaffId,
        role,
        department,
        phoneNumber,
      ];
}

class SignOutRequested extends AuthEvent {}

class UserUpdated extends AuthEvent {
  final UserModel user;

  const UserUpdated({required this.user});

  @override
  List<Object> get props => [user];
}

// New event to check auth state
class CheckAuthState extends AuthEvent {}